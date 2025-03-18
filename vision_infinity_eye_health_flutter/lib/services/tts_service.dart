import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import 'audio_cache_service.dart';

final ttsServiceProvider = Provider((ref) => TTSService(ref.watch(audioCacheProvider)));
final audioPlayerProvider = Provider((ref) => AudioPlayer());
final isPlayingProvider = StateProvider<bool>((ref) => false);

class TTSService {
  static final Uri ttsEndpoint = Uri.parse(
    '${ApiConstants.ghanaNlpBaseUrl}${ApiConstants.ghanaNlpTtsEndpoint}',
  );
  static const double voiceRate = 0.85; // Add voice rate control (0.5 to 1.5, default is 1.0)

  final AudioCacheService _audioCache;
  
  TTSService(this._audioCache);

  String _simplifyText(String text) {
    // Convert medical terms and complex phrases to simpler ones
    final Map<RegExp, String> simplifications = {
      RegExp(r'appears? healthy'): 'is good',
      RegExp(r'mild signs of'): 'small',
      RegExp(r'dryness'): 'dry feeling',
      RegExp(r'no serious conditions detected'):
          'no big problems with your eyes',
      RegExp(r'indicates'): 'shows',
      RegExp(r'maintain proper'): 'keep good',
      RegExp(r'hygiene'): 'clean',
      RegExp(r'take regular breaks'): 'rest often',
      RegExp(r'vision conditions'): 'ability to see',
      RegExp(r'normal'): 'good',
    };

    String simplified = text;
    simplifications.forEach((pattern, replacement) {
      simplified = simplified.replaceAll(pattern, replacement);
    });

    // Break long sentences into shorter ones
    simplified = simplified.replaceAll(RegExp(r';\s*'), '. ');
    simplified = simplified.replaceAll(RegExp(r',\s*and\s*'), '. ');
    simplified = simplified.replaceAll(RegExp(r',\s*'), '. ');

    return simplified;
  }

  Future<String> translateToTwi(String englishText) async {
    try {
      // Simplify text before translation
      final simplifiedText = _simplifyText(englishText);
      print('Simplified text for translation: $simplifiedText');

      final uri = Uri.parse(
        '${ApiConstants.translateBaseUrl}${ApiConstants.translateEndpoint}'
        '?client=gtx&sl=en&tl=ak&dt=t&q=${Uri.encodeComponent(simplifiedText)}',
      );

      final response = await http.get(uri);
      print('Translation response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = json.decode(response.body);
          if (data.isNotEmpty && data[0] is List && data[0].isNotEmpty) {
            final List<dynamic> translations = data[0];
            final StringBuffer result = StringBuffer();

            for (var translation in translations) {
              if (translation is List && translation.isNotEmpty) {
                result.write(translation[0]);
              }
            }

            final translatedText = result.toString();
            print('Translated text: $translatedText');
            return translatedText;
          }
          throw Exception('Invalid translation response format');
        } catch (e) {
          print('Translation parsing error: $e');
          throw Exception('Failed to parse translation response: $e');
        }
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Translation error: $e');
      throw Exception('Error translating text: $e');
    }
  }

  Future<Uint8List> convertTextToSpeech(String text) async {
    print('TTS Service: Starting convertTextToSpeech');
    
    // Check cache first
    final cachedAudio = _audioCache.getAudio(text);
    if (cachedAudio != null) {
      print('TTS Service: Found cached audio, returning immediately');
      return cachedAudio;
    }
    print('TTS Service: No cache found, proceeding with translation');

    try {
      final simplifiedText = _simplifyText(text);
      print('TTS Service: Simplified text result: $simplifiedText');

      final twiText = await translateToTwi(simplifiedText);
      print('TTS Service: Translation completed: $twiText');

      print('TTS Service: Making TTS API request');
      final response = await http.post(
        ttsEndpoint,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'audio/wav',  // Change accept header
          'Ocp-Apim-Subscription-Key': ApiConstants.ghanaNlpSubscriptionKey,
        },
        body: jsonEncode({
          'text': twiText,
          'language': 'tw',
          'speaker_id': 'twi_speaker_9',
          'rate': voiceRate,
        }),
      );

      if (response.statusCode == 200) {
        // Handle direct WAV response
        if (response.headers['content-type']?.contains('audio/wav') == true) {
          final audioData = response.bodyBytes;
          _audioCache.cacheAudio(text, audioData);
          return audioData;
        }
        throw Exception('Invalid audio response format');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid subscription key');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('TTS API error: $errorMessage');
      }
    } catch (e) {
      print('TTS Service ERROR: $e');
      throw Exception('Error converting text to speech: $e');
    }
  }

  Future<void> playAudio(Uint8List audioData, WidgetRef ref) async {
    print('TTS Service: Starting playAudio');
    try {
      final player = ref.read(audioPlayerProvider);
      print('TTS Service: Got audio player instance');

      print('TTS Service: Stopping any current audio');
      await stopAudio(ref);

      print('TTS Service: Creating audio source from bytes');
      final audioSource = AudioSource.uri(
        Uri.dataFromBytes(audioData, mimeType: 'audio/wav'),
      );

      print('TTS Service: Setting audio source');
      await player.setAudioSource(audioSource);
      await player.setSpeed(voiceRate); // Add playback speed control
      
      print('TTS Service: Starting playback');
      await player.play();
      ref.read(isPlayingProvider.notifier).state = true;
      print('TTS Service: Playback started successfully');

      // Listen for playback completion
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          ref.read(isPlayingProvider.notifier).state = false;
        }
      });
    } catch (e) {
      print('TTS Service ERROR in playAudio: $e');
      ref.read(isPlayingProvider.notifier).state = false;
      throw Exception('Error playing audio: $e');
    }
  }

  Future<void> stopAudio(WidgetRef ref) async {
    try {
      final player = ref.read(audioPlayerProvider);
      await player.stop();
      ref.read(isPlayingProvider.notifier).state = false;
    } catch (e) {
      throw Exception('Error stopping audio: $e');
    }
  }

  void dispose(WidgetRef ref) {
    ref.read(audioPlayerProvider).dispose();
  }
}
