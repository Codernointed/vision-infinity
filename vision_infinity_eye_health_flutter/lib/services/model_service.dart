import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ModelService {
  static const String apiKey = 'AIzaSyBdGQXw8_k7AbsKBDas5Fw_XYXGtlyLaoA';
  static const String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  static const String systemInstruction = '''
You are an expert AI ophthalmologist and machine learning engineer. Your primary function is to analyze an eye image and classify it into ONE of three specific categories: 'Cataract', 'Conjunctivitis', or 'Normal_Eye'.

CRITICAL RULE: The `specific_diagnosis` field in your JSON response MUST BE one of those three exact strings. Do not diagnose any other condition like 'Dry Eye' or 'Glaucoma' as the primary diagnosis, but you may list them as possibilities in the `differential_diagnoses` array.

You must structure your response in two distinct sections, and STRICTLY adhere to the following JSON schema:

{
  "BASIC_MODE": {
    "overall_assessment": "string",
    "explanation_of_conditions": "string",
    "general_recommendations": "string",
    "when_to_seek_professional_help": "string",
    "confidence_level": "string",
    "severity_level": "string"
  },
  "ADVANCED_MODE": {
    "clinical_findings": "string",
    "specific_diagnosis": "string",
    "diagnosis_confidence": "string",
    "differential_diagnoses": ["string"],
    "detailed_metrics": {
      "Tear Film Analysis": {
        "TBUT (Left)": "string",
        "TBUT (Right)": "string",
        "Tear Meniscus": "string",
        "Osmolarity (Est.)": "string"
      },
      "Corneal Assessment": {
        "Corneal Thickness (Est.)": "string",
        "Corneal Surface Regularity": "string"
      },
      "Predictive Analysis": {
        "Dry Eye Progression Risk": "string"
      }
    },
    "treatment_recommendations": "string",
    "follow_up_protocol_suggestions": "string",
    "precision_metrics": {
      "sensitivity_estimate": "string",
      "specificity_estimate": "string"
    }
  }
}

---
**NEW & IMPORTANT STYLE RULES:**

1. **For the `BASIC_MODE.overall_assessment` field:** You MUST write a single, short, and easy-to-understand sentence. Use simple, non-technical language suitable for a patient.
   - **Good Example:** "The analysis shows the presence of a cataract."
   - **Good Example:** "This eye appears to be healthy."
   - **Good Example:** "This eye shows signs consistent with conjunctivitis."
   - **Good Example:** "This eye appears to be have Cataract."
   - **Bad Example:** "The image displays a significant redness and irritation of the ocular surface, primarily affecting the conjunctiva, consistent with an inflammatory process."
   - **Do NOT use overly clinical or descriptive language in this specific field.**

2. **For all other fields:** You can be detailed and clinical as appropriate, especially in ADVANCED_MODE.
---

Adhere to the schema strictly. Ensure that all required fields are present.

IMPORTANT: For the following fields, you CAN return "N/A", "NA", if the metrics are not applicable for the eye disease. For example:
- Tear Film Analysis
- Tear Meniscus
- Osmolarity (Est.)

Your response should be only the JSON object, with no other text or explanation.
''';

  static Future<Map<String, dynamic>> analyzeEyeImage(
    Uint8List imageBytes,
  ) async {
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
          'contents': [
            {
              'parts': [
                {'text': systemInstruction},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
              ],
            },
          ],
          'generationConfig': {'responseMimeType': 'application/json'},
        }),
      );

      print('Model API Response Status: ${response.statusCode}');
      print('Model API Response Body Length: ${response.body.length}');
      print('Model API Response Body: ${response.body}');

      // Also log the response headers to see if there are any content length issues
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed response data keys: ${data.keys.toList()}');

        if (data['candidates'] != null) {
          print('Candidates found: ${data['candidates'].length}');
          if (data['candidates'].isNotEmpty) {
            final candidate = data['candidates'][0];
            print('First candidate keys: ${candidate.keys.toList()}');

            if (candidate['content'] != null) {
              print('Content keys: ${candidate['content'].keys.toList()}');

              if (candidate['content']['parts'] != null) {
                print('Parts found: ${candidate['content']['parts'].length}');

                if (candidate['content']['parts'].isNotEmpty) {
                  final part = candidate['content']['parts'][0];
                  print('First part keys: ${part.keys.toList()}');

                  if (part['text'] != null) {
                    final textContent = part['text'];
                    print('Text content type: ${textContent.runtimeType}');
                    print('Text content length: ${textContent.length}');
                    print('Raw text content from Model: $textContent');

                    // Log the first and last 100 characters to see if it's truncated
                    if (textContent.length > 200) {
                      print(
                        'First 100 chars: ${textContent.substring(0, 100)}',
                      );
                      print(
                        'Last 100 chars: ${textContent.substring(textContent.length - 100)}',
                      );
                    }

                    try {
                      // Clean the text content - remove any extra characters
                      final cleanText = textContent.trim();
                      print('Cleaned text length: ${cleanText.length}');
                      print(
                        'Cleaned text starts with: ${cleanText.startsWith('{')}',
                      );
                      print(
                        'Cleaned text ends with: ${cleanText.endsWith('}')}',
                      );

                      // Check if the response is already valid JSON
                      if (cleanText.startsWith('{') &&
                          cleanText.endsWith('}')) {
                        print(
                          '✅ Text appears to be valid JSON, attempting to parse...',
                        );
                        final parsedAnalysis = jsonDecode(cleanText);
                        print(
                          '✅ Analysis complete. Successfully parsed JSON response.',
                        );
                        return parsedAnalysis;
                      }

                      // If not valid JSON, try to extract JSON content
                      print('Attempting to extract JSON from text...');

                      // Look for JSON content between curly braces
                      final jsonStart = cleanText.indexOf('{');
                      final jsonEnd = cleanText.lastIndexOf('}');
                      print(
                        'JSON start index: $jsonStart, JSON end index: $jsonEnd',
                      );

                      if (jsonStart != -1 &&
                          jsonEnd != -1 &&
                          jsonEnd > jsonStart) {
                        final jsonContent = cleanText.substring(
                          jsonStart,
                          jsonEnd + 1,
                        );
                        print(
                          'Extracted JSON content length: ${jsonContent.length}',
                        );
                        print('Extracted JSON content: $jsonContent');

                        final parsedAnalysis = jsonDecode(jsonContent);
                        print(
                          '✅ Successfully extracted and parsed JSON from text.',
                        );
                        return parsedAnalysis;
                      }

                      // If we still can't parse it, try to find the JSON in the middle
                      print('Attempting pattern matching...');
                      final jsonPattern = RegExp(r'\{.*\}', dotAll: true);
                      final match = jsonPattern.firstMatch(cleanText);

                      if (match != null) {
                        final jsonContent = match.group(0)!;
                        print(
                          'Found JSON pattern length: ${jsonContent.length}',
                        );
                        print('Found JSON pattern: $jsonContent');

                        final parsedAnalysis = jsonDecode(jsonContent);
                        print(
                          '✅ Successfully parsed JSON using pattern matching.',
                        );
                        return parsedAnalysis;
                      }

                      print('❌ All JSON extraction methods failed');
                      throw Exception(
                        'Could not extract valid JSON from response',
                      );
                    } catch (parseError) {
                      print('❌ JSON parsing error: $parseError');
                      print('Full text content for debugging: $textContent');

                      // Try one more approach - look for the actual JSON structure
                      try {
                        print('Attempting line-by-line parsing...');
                        // The response might have extra text before or after the JSON
                        final lines = textContent.split('\n');
                        print('Found ${lines.length} lines in response');

                        for (int i = 0; i < lines.length; i++) {
                          final line = lines[i];
                          final trimmedLine = line.trim();
                          print(
                            'Line $i: ${trimmedLine.length} chars, starts with {: ${trimmedLine.startsWith('{')}, ends with }: ${trimmedLine.endsWith('}')}',
                          );

                          if (trimmedLine.startsWith('{') &&
                              trimmedLine.endsWith('}')) {
                            print('✅ Found JSON in line $i: $trimmedLine');
                            final parsedAnalysis = jsonDecode(trimmedLine);
                            return parsedAnalysis;
                          }
                        }
                      } catch (lineError) {
                        print('❌ Line-by-line parsing also failed: $lineError');
                      }

                      // If all parsing attempts fail, throw the original error
                      throw Exception(
                        'Failed to parse Model response: $parseError',
                      );
                    }
                  } else {
                    throw Exception('Text content is null in response part');
                  }
                } else {
                  throw Exception('No parts found in content');
                }
              } else {
                throw Exception('Parts is null in content');
              }
            } else {
              throw Exception('Content is null in candidate');
            }
          } else {
            throw Exception('No candidates found in response');
          }
        } else {
          throw Exception('Candidates is null in response');
        }
      } else {
        throw Exception(
          'Model API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error during Model API call: $e');
      // Return a structured error response
      return {
        'error': 'Analysis failed',
        'error_details': e.toString(),
        'BASIC_MODE': {
          'overall_assessment': 'Unable to analyze image',
          'explanation_of_conditions': 'Analysis failed due to technical error',
          'general_recommendations': 'Please try again or contact support',
          'when_to_seek_professional_help':
              'If symptoms persist, consult an eye care professional',
          'confidence_level': 'N/A',
          'severity_level': 'Unknown',
        },
        'ADVANCED_MODE': {
          'clinical_findings': 'Analysis failed',
          'specific_diagnosis': 'Unknown',
          'diagnosis_confidence': 'N/A',
          'differential_diagnoses': [],
          'detailed_metrics': {
            'Tear Film Analysis': {
              'TBUT (Left)': 'N/A',
              'TBUT (Right)': 'N/A',
              'Tear Meniscus': 'N/A',
              'Osmolarity (Est.)': 'N/A',
            },
            'Corneal Assessment': {
              'Corneal Thickness (Est.)': 'N/A',
              'Corneal Surface Regularity': 'N/A',
            },
            'Predictive Analysis': {'Dry Eye Progression Risk': 'N/A'},
          },
          'treatment_recommendations': 'Please try the analysis again',
          'follow_up_protocol_suggestions': 'N/A',
          'precision_metrics': {
            'sensitivity_estimate': 'N/A',
            'specificity_estimate': 'N/A',
          },
        },
      };
    }
  }
}
