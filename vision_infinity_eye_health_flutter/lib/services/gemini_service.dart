import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class GeminiService {
  static const String apiKey = 'AIzaSyDyhUhn4VrgUBzqZAXPuOgV5m2LQX6xnFc';
  static const String endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<Map<String, dynamic>> analyzeEyeImage(Uint8List imageBytes) async {
    final String base64Image = base64Encode(imageBytes);
    
    try {
      print('Sending image to Gemini API ...');
      final response = await http.post(
        Uri.parse('$endpoint?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "contents": [{
            "parts": [
              {
                "text": '''Act as an ophthalmologist and analyze this eye image to detect any possible eye diseases or conditions and provide a structured response in this exact JSON format:
{
  "basic_analysis": "Simple explanation for patients in non-technical language",
  "advanced_analysis": "Detailed clinical findings for healthcare professionals",
  "condition_status": "healthy/mild/moderate/severe",
  "recommendations": ["List", "of", "recommendations"],
  "symptoms": ["List", "of", "observed", "symptoms"],
  "metrics": {
    "pressure": 0-100,
    "redness": 0-100,
    "dryness": 0-100
  },
  "confidence_score": 0-100,
  "follow_up": "Recommended follow-up timeline",
  "risk_factors": ["List", "of", "identified", "risks"]
  Important: 
- Always include a confidence percentage (0-100%) for your assessment in both modes
- Be honest about limitations in image quality or diagnostic certainty
- If you detect any abnormality, even minor, clearly indicate it as a concern
- Use appropriate severity terminology (Healthy, Mild Concern, Moderate Concern, Severe Concern, or Critical)
- Only use "Healthy" or "Good" status with green indicators when the eye is completely normal
- Do not downplay potential issues - err on the side of caution
- Provide the overall assessment as a complete sentence without ellipses`
}'''
              },
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }],
          "safety_settings": {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_NONE"
          },
          "generation_config": {
            "temperature": 0.4,
            "top_p": 1,
            "top_k": 32
          }
        }),
      );

      print('Gemini API Response Status: ${response.statusCode}');
      print('Gemini API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        try {
          String text = data['candidates'][0]['content']['parts'][0]['text'];
          
          // Clean up markdown formatting
          text = text.replaceAll('```json\n', '')  // Remove opening markdown
                    .replaceAll('\n```', '')       // Remove closing markdown
                    .trim();                       // Clean up whitespace
          
          print('Cleaned JSON text: $text');
          
          try {
            final analysisData = jsonDecode(text);
            
            // Create metrics with default values if missing or invalid
            Map<String, double> metrics = {
              'pressure': 0.0,
              'redness': 0.0,
              'dryness': 0.0,
            };

            // Try to parse metrics if they exist
            if (analysisData['metrics'] != null) {
              try {
                final rawMetrics = analysisData['metrics'] as Map<String, dynamic>;
                metrics = rawMetrics.map((key, value) {
                  // Convert any numeric value to double
                  if (value is num) {
                    return MapEntry(key, value.toDouble());
                  }
                  // Try to parse string to double
                  if (value is String) {
                    return MapEntry(key, double.tryParse(value) ?? 0.0);
                  }
                  return MapEntry(key, 0.0);
                });
              } catch (e) {
                print('Error parsing metrics: $e');
                // Keep default metrics if parsing fails
              }
            }
            
            // Return complete analysis
            return {
              'basic_analysis': analysisData['basic_analysis'] ?? 'Analysis not available',
              'advanced_analysis': analysisData['advanced_analysis'] ?? 'Detailed analysis not available',
              'condition_status': analysisData['condition_status'] ?? 'unknown',
              'recommendations': List<String>.from(analysisData['recommendations'] ?? []),
              'symptoms': List<String>.from(analysisData['symptoms'] ?? []),
              'metrics': metrics,
            };
          } catch (e) {
            print('JSON parsing error: $e');
            print('Failed JSON string: $text');
            throw Exception('Invalid JSON format in AI response');
          }
        } catch (e) {
          print('Error extracting text from response: $e');
          throw Exception('Failed to extract analysis from AI response');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        print('Gemini API error: $errorMessage');
        throw Exception('Failed to analyze image: $errorMessage');
      }
    } catch (e) {
      print('Error in analyzeEyeImage: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format from AI service');
      }
      throw Exception('Error analyzing image: $e');
    }
  }
}
