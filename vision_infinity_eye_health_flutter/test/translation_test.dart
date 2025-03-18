import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Test phrases with both complex and simplified versions
  final testPhrases = [
    {
      'complex':
          'Your eyes appear healthy with mild signs of dryness. No serious conditions detected.',
      'simple':
          'your eye is slightly yellow, consider hydrating, and keeping a consistent sleep time',
    },
    {
      'complex': 'Please blink three times and look straight ahead.',
      'simple':
          'Please close and open your eyes three times slowly. After that, look straight to the front.',
    },
    {
      'complex': 'Regular eye check-up indicates normal vision conditions.',
      'simple':
          'We have checked your eyes today. Your eyes can see very well. Everything looks normal with your vision.',
    },
    {
      'complex':
          'Maintain proper eye hygiene and take regular breaks from screen.',
      'simple':
          'You should keep your eyes very clean every day. When you use your phone or computer, take many small breaks to rest your eyes.',
    },
  ];

  print('Testing English to Twi Translation\n');
  print('=' * 50);

  for (final phrase in testPhrases) {
    try {
      print('\nComplex English: ${phrase['complex']}');
      final complexTranslation = await translateToTwi(phrase['complex']!);
      print('Twi (Complex): $complexTranslation');

      print('\nSimple English: ${phrase['simple']}');
      final simpleTranslation = await translateToTwi(phrase['simple']!);
      print('Twi (Simple): $simpleTranslation');
      print('-' * 50);
    } catch (e) {
      print('\nError translating: $e');
      print('-' * 50);
    }
  }
}

Future<String> translateToTwi(String englishText) async {
  try {
    final uri = Uri.parse(
      'https://translate.googleapis.com/translate_a/single'
      '?client=gtx&sl=en&tl=ak&dt=t&q=${Uri.encodeComponent(englishText)}',
    );

    final response = await http.get(uri);

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

          return result.toString();
        }
        throw Exception('Invalid translation response format');
      } catch (e) {
        throw Exception('Failed to parse translation response: $e');
      }
    } else {
      throw Exception(
        'Translation failed: ${response.statusCode}\n${response.body}',
      );
    }
  } catch (e) {
    throw Exception('Error translating text: $e');
  }
}
