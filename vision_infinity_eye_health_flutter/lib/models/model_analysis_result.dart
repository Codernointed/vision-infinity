import 'package:json_annotation/json_annotation.dart';

part 'model_analysis_result.g.dart';

@JsonSerializable()
class ModelAnalysisResult {
  @JsonKey(name: 'BASIC_MODE')
  final BasicMode basicMode;
  @JsonKey(name: 'ADVANCED_MODE')
  final AdvancedMode advancedMode;
  final String? error;
  final String? errorDetails;

  const ModelAnalysisResult({
    required this.basicMode,
    required this.advancedMode,
    this.error,
    this.errorDetails,
  });

  factory ModelAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$ModelAnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$ModelAnalysisResultToJson(this);

  bool get hasError => error != null;
}

@JsonSerializable()
class BasicMode {
  @JsonKey(name: 'overall_assessment')
  final String overallAssessment;
  @JsonKey(name: 'explanation_of_conditions')
  final String explanationOfConditions;
  @JsonKey(name: 'general_recommendations')
  final String generalRecommendations;
  @JsonKey(name: 'when_to_seek_professional_help')
  final String whenToSeekProfessionalHelp;
  @JsonKey(name: 'confidence_level')
  final String confidenceLevel;
  @JsonKey(name: 'severity_level')
  final String severityLevel;

  const BasicMode({
    required this.overallAssessment,
    required this.explanationOfConditions,
    required this.generalRecommendations,
    required this.whenToSeekProfessionalHelp,
    required this.confidenceLevel,
    required this.severityLevel,
  });

  factory BasicMode.fromJson(Map<String, dynamic> json) =>
      _$BasicModeFromJson(json);

  Map<String, dynamic> toJson() => _$BasicModeToJson(this);
}

@JsonSerializable()
class AdvancedMode {
  @JsonKey(name: 'clinical_findings')
  final String clinicalFindings;
  @JsonKey(name: 'specific_diagnosis')
  final String specificDiagnosis;
  @JsonKey(name: 'diagnosis_confidence')
  final String diagnosisConfidence;
  @JsonKey(name: 'differential_diagnoses')
  final List<String> differentialDiagnoses;
  @JsonKey(name: 'detailed_metrics')
  final DetailedMetrics detailedMetrics;
  @JsonKey(name: 'treatment_recommendations')
  final String treatmentRecommendations;
  @JsonKey(name: 'follow_up_protocol_suggestions')
  final String followUpProtocolSuggestions;
  @JsonKey(name: 'precision_metrics')
  final PrecisionMetrics precisionMetrics;

  const AdvancedMode({
    required this.clinicalFindings,
    required this.specificDiagnosis,
    required this.diagnosisConfidence,
    required this.differentialDiagnoses,
    required this.detailedMetrics,
    required this.treatmentRecommendations,
    required this.followUpProtocolSuggestions,
    required this.precisionMetrics,
  });

  factory AdvancedMode.fromJson(Map<String, dynamic> json) =>
      _$AdvancedModeFromJson(json);

  Map<String, dynamic> toJson() => _$AdvancedModeToJson(this);
}

@JsonSerializable()
class DetailedMetrics {
  @JsonKey(name: 'Tear Film Analysis')
  final TearFilmAnalysis tearFilmAnalysis;
  @JsonKey(name: 'Corneal Assessment')
  final CornealAssessment cornealAssessment;
  @JsonKey(name: 'Predictive Analysis')
  final PredictiveAnalysis predictiveAnalysis;

  const DetailedMetrics({
    required this.tearFilmAnalysis,
    required this.cornealAssessment,
    required this.predictiveAnalysis,
  });

  factory DetailedMetrics.fromJson(Map<String, dynamic> json) =>
      _$DetailedMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$DetailedMetricsToJson(this);
}

@JsonSerializable()
class TearFilmAnalysis {
  @JsonKey(name: 'TBUT (Left)')
  final String tbutLeft;
  @JsonKey(name: 'TBUT (Right)')
  final String tbutRight;
  @JsonKey(name: 'Tear Meniscus')
  final String tearMeniscus;
  @JsonKey(name: 'Osmolarity (Est.)')
  final String osmolarityEst;

  const TearFilmAnalysis({
    required this.tbutLeft,
    required this.tbutRight,
    required this.tearMeniscus,
    required this.osmolarityEst,
  });

  factory TearFilmAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TearFilmAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$TearFilmAnalysisToJson(this);
}

@JsonSerializable()
class CornealAssessment {
  @JsonKey(name: 'Corneal Thickness (Est.)')
  final String cornealThicknessEst;
  @JsonKey(name: 'Corneal Surface Regularity')
  final String cornealSurfaceRegularity;

  const CornealAssessment({
    required this.cornealThicknessEst,
    required this.cornealSurfaceRegularity,
  });

  factory CornealAssessment.fromJson(Map<String, dynamic> json) =>
      _$CornealAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$CornealAssessmentToJson(this);
}

@JsonSerializable()
class PredictiveAnalysis {
  @JsonKey(name: 'Dry Eye Progression Risk')
  final String dryEyeProgressionRisk;

  const PredictiveAnalysis({required this.dryEyeProgressionRisk});

  factory PredictiveAnalysis.fromJson(Map<String, dynamic> json) =>
      _$PredictiveAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$PredictiveAnalysisToJson(this);
}

@JsonSerializable()
class PrecisionMetrics {
  @JsonKey(name: 'sensitivity_estimate')
  final String sensitivityEstimate;
  @JsonKey(name: 'specificity_estimate')
  final String specificityEstimate;

  const PrecisionMetrics({
    required this.sensitivityEstimate,
    required this.specificityEstimate,
  });

  factory PrecisionMetrics.fromJson(Map<String, dynamic> json) =>
      _$PrecisionMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$PrecisionMetricsToJson(this);
}
