import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/tts_service.dart';
import '../../services/audio_cache_service.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

class AudioButton extends ConsumerWidget {
  final String text;
  final Color? color;
  final double size;

  const AudioButton({
    super.key,
    required this.text,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlaying = ref.watch(isPlayingProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final ttsService = ref.watch(ttsServiceProvider);
    final audioCache = ref.watch(audioCacheProvider);
    final isCached = audioCache.hasAudio(text);

    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap:
          isLoading
              ? null
              : () async {
                try {
                  print('AudioButton: Button pressed');
                  if (isPlaying) {
                    print('AudioButton: Stopping current audio');
                    await ttsService.stopAudio(ref);
                  } else {
                    print('AudioButton: Starting new audio process');
                    ref.read(isLoadingProvider.notifier).state = true;
                    
                    if (isCached) {
                      print('AudioButton: Using cached audio');
                      final cachedAudio = audioCache.getAudio(text);
                      if (cachedAudio != null) {
                        print('AudioButton: Playing cached audio');
                        await ttsService.playAudio(cachedAudio, ref);
                        return;
                      }
                    }
                    
                    print('AudioButton: No cache found, generating new audio');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Translating and generating audio...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    print('AudioButton: Calling convertTextToSpeech');
                    final audioData = await ttsService.convertTextToSpeech(
                      text,
                    );
                    print('AudioButton: Audio data received, length: ${audioData.length} bytes');
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Playing audio in Twi...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    print('AudioButton: Starting audio playback');
                    await ttsService.playAudio(audioData, ref);
                    print('AudioButton: Playback started successfully');
                  }
                } catch (e) {
                  print('AudioButton ERROR: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceAll('Exception: ', ''),
                        ),
                        backgroundColor: theme.colorScheme.error,
                        duration: const Duration(seconds: 4),
                        action: SnackBarAction(
                          label: 'Dismiss',
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    ref.read(isLoadingProvider.notifier).state = false;
                  }
                }
              },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isPlaying
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color ?? theme.colorScheme.primary,
                    ),
                  ),
                )
                : Icon(
                  isPlaying 
                    ? Icons.stop_rounded 
                    : isCached 
                      ? Icons.play_circle_outline
                      : Icons.volume_up_outlined,
                  size: size,
                  color: color ?? theme.colorScheme.primary,
                ),
      ),
    );
  }
}
