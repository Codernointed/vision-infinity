import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vision_infinity_eye_health_flutter/models/model_analysis_result.dart';
import 'package:vision_infinity_eye_health_flutter/services/model_service.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> captureImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Optimize for API while maintaining quality
        preferredCameraDevice:
            CameraDevice.front, // Front camera for selfie-style eye photos
      );
    } catch (e) {
      print('Camera capture error: $e');
      return null;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    } catch (e) {
      print('Gallery pick error: $e');
      return null;
    }
  }

  Future<ModelAnalysisResult?> analyzeImage(XFile image) async {
    try {
      // Convert XFile to Uint8List for Gemini API
      final File file = File(image.path);
      final Uint8List imageBytes = await file.readAsBytes();

      // Send to Gemini API for analysis
      print('📸 Sending image to Gemini API for analysis...');
      final Map<String, dynamic> rawResult = await ModelService.analyzeEyeImage(
        imageBytes,
      );

      print('📸 Raw result received from Gemini service:');
      print('📸 Raw result type: ${rawResult.runtimeType}');
      print('📸 Raw result keys: ${rawResult.keys.toList()}');
      print('📸 Raw result contains error: ${rawResult.containsKey('error')}');
      if (rawResult.containsKey('error')) {
        print('📸 Error field: ${rawResult['error']}');
        print('📸 Error details: ${rawResult['error_details']}');
      }
      print(
        '📸 Raw result contains BASIC_MODE: ${rawResult.containsKey('BASIC_MODE')}',
      );
      print(
        '📸 Raw result contains ADVANCED_MODE: ${rawResult.containsKey('ADVANCED_MODE')}',
      );

      // Parse the structured response
      ModelAnalysisResult analysisResult;
      try {
        analysisResult = ModelAnalysisResult.fromJson(rawResult);
        print('📸 Successfully parsed GeminiAnalysisResult');
      } catch (parseError) {
        print('📸 Failed to parse GeminiAnalysisResult: $parseError');
        print('📸 Raw result was: $rawResult');

        // Return a fallback result with error information
        analysisResult = ModelAnalysisResult(
          basicMode: BasicMode(
            overallAssessment: 'Analysis failed',
            explanationOfConditions: 'Unable to process the image analysis',
            generalRecommendations: 'Please try again or contact support',
            whenToSeekProfessionalHelp:
                'If symptoms persist, consult an eye care professional',
            confidenceLevel: 'Low',
            severityLevel: 'Unknown',
          ),
          advancedMode: AdvancedMode(
            clinicalFindings: 'Analysis could not be completed',
            specificDiagnosis: 'Unable to determine',
            diagnosisConfidence: 'Low',
            differentialDiagnoses: ['Analysis failed'],
            detailedMetrics: DetailedMetrics(
              tearFilmAnalysis: TearFilmAnalysis(
                tbutLeft: 'N/A',
                tbutRight: 'N/A',
                tearMeniscus: 'N/A',
                osmolarityEst: 'N/A',
              ),
              cornealAssessment: CornealAssessment(
                cornealThicknessEst: 'N/A',
                cornealSurfaceRegularity: 'N/A',
              ),
              predictiveAnalysis: PredictiveAnalysis(
                dryEyeProgressionRisk: 'N/A',
              ),
            ),
            treatmentRecommendations:
                'Unable to provide specific recommendations',
            followUpProtocolSuggestions:
                'Consult with an eye care professional',
            precisionMetrics: PrecisionMetrics(
              sensitivityEstimate: 'N/A',
              specificityEstimate: 'N/A',
            ),
          ),
          error: 'Analysis failed',
          errorDetails: rawResult['error_details'] ?? 'Unknown error',
        );
      }

      print('📸 Successfully created GeminiAnalysisResult');
      print('📸 Result has error: ${analysisResult.hasError}');
      print(
        '📸 Basic mode assessment: ${analysisResult.basicMode.overallAssessment}',
      );
      print(
        '📸 Advanced mode diagnosis: ${analysisResult.advancedMode.specificDiagnosis}',
      );

      return analysisResult;
    } catch (e) {
      print('❌ Image analysis error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error stack trace: ${StackTrace.current}');

      // Return a fallback result instead of null so user can still see results
      return ModelAnalysisResult(
        basicMode: BasicMode(
          overallAssessment: 'Analysis temporarily unavailable',
          explanationOfConditions:
              'Due to a technical issue, we were unable to complete the AI analysis. Please try again or contact support.',
          generalRecommendations:
              'Please try the scan again. If the issue persists, contact our support team.',
          whenToSeekProfessionalHelp:
              'If you have concerns about your eye health, please consult an eye care professional.',
          confidenceLevel: 'N/A',
          severityLevel: 'Unknown',
        ),
        advancedMode: AdvancedMode(
          clinicalFindings: 'Analysis failed due to technical error',
          specificDiagnosis: 'Unknown',
          diagnosisConfidence: 'N/A',
          differentialDiagnoses: [],
          detailedMetrics: DetailedMetrics(
            tearFilmAnalysis: TearFilmAnalysis(
              tbutLeft: 'N/A',
              tbutRight: 'N/A',
              tearMeniscus: 'N/A',
              osmolarityEst: 'N/A',
            ),
            cornealAssessment: CornealAssessment(
              cornealThicknessEst: 'N/A',
              cornealSurfaceRegularity: 'N/A',
            ),
            predictiveAnalysis: PredictiveAnalysis(
              dryEyeProgressionRisk: 'N/A',
            ),
          ),
          treatmentRecommendations: 'Please try the analysis again',
          followUpProtocolSuggestions: 'N/A',
          precisionMetrics: PrecisionMetrics(
            sensitivityEstimate: 'N/A',
            specificityEstimate: 'N/A',
          ),
        ),
        error: 'Analysis failed',
        errorDetails: e.toString(),
      );
    }
  }

  Future<ModelAnalysisResult?> analyzeImageFromPath(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found: $imagePath');
      }

      final Uint8List imageBytes = await file.readAsBytes();
      final Map<String, dynamic> rawResult = await ModelService.analyzeEyeImage(
        imageBytes,
      );

      return ModelAnalysisResult.fromJson(rawResult);
    } catch (e) {
      print('Image analysis error: $e');

      // Return a fallback result instead of null
      return ModelAnalysisResult(
        basicMode: BasicMode(
          overallAssessment: 'Analysis temporarily unavailable',
          explanationOfConditions:
              'Due to a technical issue, we were unable to complete the AI analysis. Please try again or contact support.',
          generalRecommendations:
              'Please try the scan again. If the issue persists, contact our support team.',
          whenToSeekProfessionalHelp:
              'If you have concerns about your eye health, please consult an eye care professional.',
          confidenceLevel: 'N/A',
          severityLevel: 'Unknown',
        ),
        advancedMode: AdvancedMode(
          clinicalFindings: 'Analysis failed due to technical error',
          specificDiagnosis: 'Unknown',
          diagnosisConfidence: 'N/A',
          differentialDiagnoses: [],
          detailedMetrics: DetailedMetrics(
            tearFilmAnalysis: TearFilmAnalysis(
              tbutLeft: 'N/A',
              tbutRight: 'N/A',
              tearMeniscus: 'N/A',
              osmolarityEst: 'N/A',
            ),
            cornealAssessment: CornealAssessment(
              cornealThicknessEst: 'N/A',
              cornealSurfaceRegularity: 'N/A',
            ),
            predictiveAnalysis: PredictiveAnalysis(
              dryEyeProgressionRisk: 'N/A',
            ),
          ),
          treatmentRecommendations: 'Please try the analysis again',
          followUpProtocolSuggestions: 'N/A',
          precisionMetrics: PrecisionMetrics(
            sensitivityEstimate: 'N/A',
            specificityEstimate: 'N/A',
          ),
        ),
        error: 'Analysis failed',
        errorDetails: e.toString(),
      );
    }
  }

  // Helper method to get image dimensions
  Future<Map<String, int>> getImageDimensions(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (!await file.exists()) {
        return {'width': 0, 'height': 0};
      }

      // For now, return placeholder dimensions
      // In a real implementation, you'd use image package to get actual dimensions
      return {'width': 1080, 'height': 1920};
    } catch (e) {
      print('Error getting image dimensions: $e');
      return {'width': 0, 'height': 0};
    }
  }

  // Validate image quality before sending to API
  bool validateImageQuality(XFile image) {
    // Basic validation - check file size
    final File file = File(image.path);
    final int fileSize = file.lengthSync();

    // Ensure image is not too small (less than 100KB) or too large (more than 10MB)
    if (fileSize < 100 * 1024 || fileSize > 10 * 1024 * 1024) {
      return false;
    }

    return true;
  }
}
