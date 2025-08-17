// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelAnalysisResult _$ModelAnalysisResultFromJson(Map<String, dynamic> json) =>
    ModelAnalysisResult(
      basicMode: BasicMode.fromJson(json['BASIC_MODE'] as Map<String, dynamic>),
      advancedMode: AdvancedMode.fromJson(
        json['ADVANCED_MODE'] as Map<String, dynamic>,
      ),
      error: json['error'] as String?,
      errorDetails: json['errorDetails'] as String?,
    );

Map<String, dynamic> _$ModelAnalysisResultToJson(
  ModelAnalysisResult instance,
) => <String, dynamic>{
  'BASIC_MODE': instance.basicMode,
  'ADVANCED_MODE': instance.advancedMode,
  'error': instance.error,
  'errorDetails': instance.errorDetails,
};

BasicMode _$BasicModeFromJson(Map<String, dynamic> json) => BasicMode(
  overallAssessment: json['overall_assessment'] as String,
  explanationOfConditions: json['explanation_of_conditions'] as String,
  generalRecommendations: json['general_recommendations'] as String,
  whenToSeekProfessionalHelp: json['when_to_seek_professional_help'] as String,
  confidenceLevel: json['confidence_level'] as String,
  severityLevel: json['severity_level'] as String,
);

Map<String, dynamic> _$BasicModeToJson(BasicMode instance) => <String, dynamic>{
  'overall_assessment': instance.overallAssessment,
  'explanation_of_conditions': instance.explanationOfConditions,
  'general_recommendations': instance.generalRecommendations,
  'when_to_seek_professional_help': instance.whenToSeekProfessionalHelp,
  'confidence_level': instance.confidenceLevel,
  'severity_level': instance.severityLevel,
};

AdvancedMode _$AdvancedModeFromJson(Map<String, dynamic> json) => AdvancedMode(
  clinicalFindings: json['clinical_findings'] as String,
  specificDiagnosis: json['specific_diagnosis'] as String,
  diagnosisConfidence: json['diagnosis_confidence'] as String,
  differentialDiagnoses:
      (json['differential_diagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  detailedMetrics: DetailedMetrics.fromJson(
    json['detailed_metrics'] as Map<String, dynamic>,
  ),
  treatmentRecommendations: json['treatment_recommendations'] as String,
  followUpProtocolSuggestions: json['follow_up_protocol_suggestions'] as String,
  precisionMetrics: PrecisionMetrics.fromJson(
    json['precision_metrics'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AdvancedModeToJson(AdvancedMode instance) =>
    <String, dynamic>{
      'clinical_findings': instance.clinicalFindings,
      'specific_diagnosis': instance.specificDiagnosis,
      'diagnosis_confidence': instance.diagnosisConfidence,
      'differential_diagnoses': instance.differentialDiagnoses,
      'detailed_metrics': instance.detailedMetrics,
      'treatment_recommendations': instance.treatmentRecommendations,
      'follow_up_protocol_suggestions': instance.followUpProtocolSuggestions,
      'precision_metrics': instance.precisionMetrics,
    };

DetailedMetrics _$DetailedMetricsFromJson(Map<String, dynamic> json) =>
    DetailedMetrics(
      tearFilmAnalysis: TearFilmAnalysis.fromJson(
        json['Tear Film Analysis'] as Map<String, dynamic>,
      ),
      cornealAssessment: CornealAssessment.fromJson(
        json['Corneal Assessment'] as Map<String, dynamic>,
      ),
      predictiveAnalysis: PredictiveAnalysis.fromJson(
        json['Predictive Analysis'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$DetailedMetricsToJson(DetailedMetrics instance) =>
    <String, dynamic>{
      'Tear Film Analysis': instance.tearFilmAnalysis,
      'Corneal Assessment': instance.cornealAssessment,
      'Predictive Analysis': instance.predictiveAnalysis,
    };

TearFilmAnalysis _$TearFilmAnalysisFromJson(Map<String, dynamic> json) =>
    TearFilmAnalysis(
      tbutLeft: json['TBUT (Left)'] as String,
      tbutRight: json['TBUT (Right)'] as String,
      tearMeniscus: json['Tear Meniscus'] as String,
      osmolarityEst: json['Osmolarity (Est.)'] as String,
    );

Map<String, dynamic> _$TearFilmAnalysisToJson(TearFilmAnalysis instance) =>
    <String, dynamic>{
      'TBUT (Left)': instance.tbutLeft,
      'TBUT (Right)': instance.tbutRight,
      'Tear Meniscus': instance.tearMeniscus,
      'Osmolarity (Est.)': instance.osmolarityEst,
    };

CornealAssessment _$CornealAssessmentFromJson(Map<String, dynamic> json) =>
    CornealAssessment(
      cornealThicknessEst: json['Corneal Thickness (Est.)'] as String,
      cornealSurfaceRegularity: json['Corneal Surface Regularity'] as String,
    );

Map<String, dynamic> _$CornealAssessmentToJson(CornealAssessment instance) =>
    <String, dynamic>{
      'Corneal Thickness (Est.)': instance.cornealThicknessEst,
      'Corneal Surface Regularity': instance.cornealSurfaceRegularity,
    };

PredictiveAnalysis _$PredictiveAnalysisFromJson(Map<String, dynamic> json) =>
    PredictiveAnalysis(
      dryEyeProgressionRisk: json['Dry Eye Progression Risk'] as String,
    );

Map<String, dynamic> _$PredictiveAnalysisToJson(PredictiveAnalysis instance) =>
    <String, dynamic>{
      'Dry Eye Progression Risk': instance.dryEyeProgressionRisk,
    };

PrecisionMetrics _$PrecisionMetricsFromJson(Map<String, dynamic> json) =>
    PrecisionMetrics(
      sensitivityEstimate: json['sensitivity_estimate'] as String,
      specificityEstimate: json['specificity_estimate'] as String,
    );

Map<String, dynamic> _$PrecisionMetricsToJson(PrecisionMetrics instance) =>
    <String, dynamic>{
      'sensitivity_estimate': instance.sensitivityEstimate,
      'specificity_estimate': instance.specificityEstimate,
    };
