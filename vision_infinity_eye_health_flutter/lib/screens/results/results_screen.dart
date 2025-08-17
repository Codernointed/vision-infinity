import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_infinity_eye_health_flutter/models/model_analysis_result.dart';
import '../../core/providers/app_state_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/audio_button.dart';
import 'package:vision_infinity_eye_health_flutter/models/model_analysis_result.dart';
import 'dart:io';

class ResultsScreen extends ConsumerWidget {
  static const routeName = '/results';
  final Map<String, dynamic>? scanData;

  const ResultsScreen({super.key, this.scanData});

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'normal_eye':
        return const Color(0xFF22C55E);
      case 'cataract':
        return const Color(0xFFF59E0B);
      case 'conjunctivitis':
        return const Color(0xFFF97316);
      case 'mild dryness':
        return const Color(0xFFF59E0B);
      case 'moderate redness':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF22C55E);
    }
  }

  double _getHealthPercentage(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'normal_eye':
        return 20.0; // Low concern - healthy
      case 'cataract':
        return 80.0; // High concern
      case 'conjunctivitis':
        return 70.0; // Medium-high concern
      case 'mild dryness':
        return 40.0; // Medium concern
      case 'moderate redness':
        return 60.0; // Medium-high concern
      default:
        return 50.0; // Medium concern
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAdvancedMode = ref.watch(isAdvancedModeProvider);

    // Parse the scan data to get Model analysis result
    ModelAnalysisResult? analysisResult;
    try {
      if (scanData != null && scanData!.containsKey('BASIC_MODE')) {
        // Check if the data is already parsed objects or raw Maps
        if (scanData!['BASIC_MODE'] is BasicMode) {
          // The data is already parsed objects - use them directly
          analysisResult = ModelAnalysisResult(
            basicMode: scanData!['BASIC_MODE'] as BasicMode,
            advancedMode: scanData!['ADVANCED_MODE'] as AdvancedMode,
            error: scanData!['error'] as String?,
            errorDetails: scanData!['errorDetails'] as String?,
          );
        } else {
          // The data is raw Maps - parse them
          analysisResult = ModelAnalysisResult.fromJson(scanData!);
        }
      }
    } catch (e) {
      print('Error parsing analysis result: $e');
      // If parsing fails, try to create a fallback result
      if (scanData != null && scanData!.containsKey('BASIC_MODE')) {
        try {
          // Check if we have parsed objects
          if (scanData!['BASIC_MODE'] is BasicMode) {
            analysisResult = ModelAnalysisResult(
              basicMode: scanData!['BASIC_MODE'] as BasicMode,
              advancedMode: scanData!['ADVANCED_MODE'] as AdvancedMode,
              error: scanData!['error'] as String?,
              errorDetails: scanData!['errorDetails'] as String?,
            );
          } else {
            // Create a fallback result using the raw Map data
            analysisResult = ModelAnalysisResult(
              basicMode: BasicMode(
                overallAssessment:
                    scanData!['BASIC_MODE']['overall_assessment'] ??
                    'Analysis completed',
                explanationOfConditions:
                    scanData!['BASIC_MODE']['explanation_of_conditions'] ??
                    'Analysis completed successfully',
                generalRecommendations:
                    scanData!['BASIC_MODE']['general_recommendations'] ??
                    'Please consult with an eye care professional',
                whenToSeekProfessionalHelp:
                    scanData!['BASIC_MODE']['when_to_seek_professional_help'] ??
                    'If symptoms persist, seek professional help',
                confidenceLevel:
                    scanData!['BASIC_MODE']['confidence_level'] ?? 'High',
                severityLevel:
                    scanData!['BASIC_MODE']['severity_level'] ?? 'Unknown',
              ),
              advancedMode: AdvancedMode(
                clinicalFindings:
                    scanData!['ADVANCED_MODE']?['clinical_findings'] ??
                    'Analysis completed',
                specificDiagnosis:
                    scanData!['ADVANCED_MODE']?['specific_diagnosis'] ??
                    'Analysis completed',
                diagnosisConfidence:
                    scanData!['ADVANCED_MODE']?['diagnosis_confidence'] ??
                    'High',
                differentialDiagnoses: List<String>.from(
                  scanData!['ADVANCED_MODE']?['differential_diagnoses'] ?? [],
                ),
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
                    scanData!['ADVANCED_MODE']?['treatment_recommendations'] ??
                    'Consult with an eye care professional',
                followUpProtocolSuggestions:
                    scanData!['ADVANCED_MODE']?['follow_up_protocol_suggestions'] ??
                    'Follow standard protocols',
                precisionMetrics: PrecisionMetrics(
                  sensitivityEstimate: 'N/A',
                  specificityEstimate: 'N/A',
                ),
              ),
            );
          }
        } catch (fallbackError) {
          print('Error creating fallback result: $fallbackError');
        }
      }
    }

    // Parse the timestamp or use current time as fallback
    final DateTime timestamp =
        DateTime.tryParse(scanData?['timestamp'] ?? '') ?? DateTime.now();
    final String date = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final String time =
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    // Get status and description based on analysis result
    String status = 'Unknown';
    Color statusColor = theme.colorScheme.onSurface;
    String description = 'Analysis not available';

    if (analysisResult != null) {
      if (isAdvancedMode) {
        status = analysisResult.advancedMode.specificDiagnosis;
        description = analysisResult.advancedMode.clinicalFindings;
      } else {
        status = analysisResult.basicMode.overallAssessment;
        description = analysisResult.basicMode.explanationOfConditions;
      }
      statusColor = _getStatusColor(status, theme);
    }

    return Material(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Scan Results',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scanData?['image_path'] != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(scanData!['image_path'])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Advanced Mode Toggle
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analysis Mode',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              isAdvancedMode
                                  ? 'Advanced (Professional)'
                                  : 'Simple (Basic)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isAdvancedMode,
                        onChanged: (value) {
                          ref.read(isAdvancedModeProvider.notifier).state =
                              value;
                        },
                      ),
                    ],
                  ),
                ),

                // Eye Health Analysis Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.remove_red_eye_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Eye Health Analysis',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '$date • $time',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AudioButton(
                        text: description,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Overall Health Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.health_and_safety_outlined,
                              color: statusColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Overall Health Assessment',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Health Status Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      status,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Confidence',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    analysisResult?.basicMode.confidenceLevel ??
                                        'N/A',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Health Meter Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Level of Concern',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${_getHealthPercentage(status)}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _getHealthPercentage(status) / 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: statusColor.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Low',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF22C55E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'High',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFEF4444),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tabs Section
                DefaultTabController(
                  length: isAdvancedMode ? 3 : 2,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          tabs: [
                            const Tab(text: 'Diagnosis'),
                            const Tab(text: 'Recommendations'),
                            if (isAdvancedMode) const Tab(text: 'Metrics'),
                          ],
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor:
                              theme.colorScheme.onSurfaceVariant,
                          labelStyle: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                          indicator: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 4,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildDiagnosis(
                                  theme,
                                  analysisResult: analysisResult,
                                  isAdvancedMode: isAdvancedMode,
                                  description: description,
                                  symptoms:
                                      [], // No longer available in new structure
                                  metrics:
                                      {}, // No longer available in new structure
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildRecommendations(
                                  theme,
                                  analysisResult: analysisResult,
                                  isAdvancedMode: isAdvancedMode,
                                  recommendations:
                                      [], // No longer available in new structure
                                ),
                              ),
                            ),
                            if (isAdvancedMode)
                              SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildMetrics(
                                    theme,
                                    analysisResult: analysisResult,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Download Full Report (PDF)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface,
                            side: BorderSide(color: theme.colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Scan Again',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      ),
    );
  }

  Widget _buildDiagnosis(
    ThemeData theme, {
    required ModelAnalysisResult? analysisResult,
    required bool isAdvancedMode,
    required String description,
    required List<String> symptoms,
    required Map<String, dynamic> metrics,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic findings
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          // Show confidence level if available
          if (analysisResult != null) ...[
            _buildDiagnosisItem(
              theme,
              title: 'Confidence Level',
              description: analysisResult!.basicMode.confidenceLevel,
              status: analysisResult!.basicMode.severityLevel,
              statusColor: _getStatusColor(
                analysisResult!.basicMode.severityLevel,
                theme,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Advanced mode specific findings
          if (analysisResult != null && isAdvancedMode) ...[
            _buildDiagnosisItem(
              theme,
              title: 'Specific Diagnosis',
              description: analysisResult!.advancedMode.specificDiagnosis,
              status: analysisResult!.advancedMode.diagnosisConfidence,
              statusColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),

            if (analysisResult!
                .advancedMode
                .differentialDiagnoses
                .isNotEmpty) ...[
              Text(
                'Differential Diagnoses',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...analysisResult!.advancedMode.differentialDiagnoses.map(
                (diagnosis) => _buildBulletPoint(theme, diagnosis),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendations(
    ThemeData theme, {
    required ModelAnalysisResult? analysisResult,
    required bool isAdvancedMode,
    required List<String> recommendations,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic mode recommendations
          if (analysisResult != null) ...[
            Text(
              'General Recommendations',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              analysisResult!.basicMode.generalRecommendations,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'When to Seek Professional Help',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              analysisResult!.basicMode.whenToSeekProfessionalHelp,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],

          // Advanced mode recommendations
          if (analysisResult != null && isAdvancedMode) ...[
            const SizedBox(height: 24),
            Text(
              'Treatment Recommendations',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              analysisResult!.advancedMode.treatmentRecommendations,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Follow-up Protocol',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              analysisResult!.advancedMode.followUpProtocolSuggestions,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetrics(
    ThemeData theme, {
    required ModelAnalysisResult? analysisResult,
  }) {
    if (analysisResult == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Advanced metrics not available')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clinical Metrics',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // Tear Film Analysis
          Text(
            'Tear Film Analysis',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'TBUT (Left)',
                  analysisResult!
                      .advancedMode
                      .detailedMetrics
                      .tearFilmAnalysis
                      .tbutLeft,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'TBUT (Right)',
                  analysisResult!
                      .advancedMode
                      .detailedMetrics
                      .tearFilmAnalysis
                      .tbutRight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Tear Meniscus',
                  analysisResult!
                      .advancedMode
                      .detailedMetrics
                      .tearFilmAnalysis
                      .tearMeniscus,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Osmolarity (Est.)',
                  analysisResult!
                      .advancedMode
                      .detailedMetrics
                      .tearFilmAnalysis
                      .osmolarityEst,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Corneal Assessment
          Text(
            'Corneal Assessment',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Corneal Thickness (Est.)',
                  analysisResult!
                      .advancedMode
                      .detailedMetrics
                      .cornealAssessment
                      .cornealThicknessEst,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Surface Regularity',
                  analysisResult!
                      .advancedMode
                      .detailedMetrics
                      .cornealAssessment
                      .cornealSurfaceRegularity,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Predictive Analysis
          Text(
            'Predictive Analysis',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetricItem(
            theme,
            'Dry Eye Progression Risk',
            analysisResult!
                .advancedMode
                .detailedMetrics
                .predictiveAnalysis
                .dryEyeProgressionRisk,
          ),
          const SizedBox(height: 24),

          // Precision Metrics
          Text(
            'Precision Metrics',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Sensitivity Estimate',
                  analysisResult!
                      .advancedMode
                      .precisionMetrics
                      .sensitivityEstimate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Specificity Estimate',
                  analysisResult!
                      .advancedMode
                      .precisionMetrics
                      .specificityEstimate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderMetric(
    ThemeData theme, {
    required String label,
    required String value,
    required String minLabel,
    required String maxLabel,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        if (minLabel.isNotEmpty || maxLabel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  maxLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRiskMetric(
    ThemeData theme, {
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisItem(
    ThemeData theme, {
    required String title,
    required String description,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: statusColor.withOpacity(0.2)),
          ),
          child: Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
