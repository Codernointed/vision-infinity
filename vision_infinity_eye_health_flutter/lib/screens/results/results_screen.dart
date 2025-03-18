import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_state_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/audio_button.dart';
import 'dart:io';

class ResultsScreen extends ConsumerWidget {
  static const routeName = '/results';
  final Map<String, dynamic>? scanData;

  const ResultsScreen({super.key, this.scanData});

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return const Color(0xFF22C55E);
      case 'mild dryness':
        return const Color(0xFFF59E0B);
      case 'moderate redness':
        return const Color(0xFFF97316);
      case 'normal':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF22C55E);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAdvancedMode = ref.watch(isAdvancedModeProvider);
    final analysis = scanData as Map<String, dynamic>;

    // Parse the timestamp or use current time as fallback 
    final DateTime timestamp = DateTime.tryParse(analysis['timestamp'] ?? '') ?? DateTime.now();
    final String date = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final String time = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    
    final String status = analysis['condition_status'] ?? 'healthy';
    final Color statusColor = _getStatusColor(status, theme);
    final String description = isAdvancedMode 
        ? analysis['advanced_analysis'] 
        : analysis['basic_analysis'];

    final List<String> recommendations = List<String>.from(analysis['recommendations'] ?? []);
    final List<String> symptoms = List<String>.from(analysis['symptoms'] ?? []);
    final Map<String, dynamic> metrics = analysis['metrics'] as Map<String, dynamic>;

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
            IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Advanced Mode',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'For healthcare professionals',
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
                        ref.read(isAdvancedModeProvider.notifier).state = value;
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
                    Column(
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
                    const Spacer(),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Overall Health',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
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
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TabBar(
                        tabs: [
                          const Tab(text: 'Diagnosis'),
                          const Tab(text: 'Recommendations'),
                          if (isAdvancedMode) const Tab(text: 'Metrics'),
                        ],
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
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
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildDiagnosis(
                                theme,
                                description: description,
                                symptoms: symptoms,
                                metrics: metrics,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildRecommendations(
                                theme,
                                recommendations: recommendations,
                              ),
                            ),
                          ),
                          if (isAdvancedMode)
                            SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildMetrics(theme),
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
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      ),
    );
  }

  Widget _buildDiagnosis(
    ThemeData theme, {
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
          Text(description),
          const SizedBox(height: 24),
          
          // Symptoms if any
          if (symptoms.isNotEmpty) ...[
            Text(
              'Observed Symptoms',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...symptoms.map((symptom) => _buildBulletPoint(theme, symptom)),
            const SizedBox(height: 24),
          ],

          // Metrics visualization
          _buildMetricsPreview(theme, metrics),
        ],
      ),
    );
  }

  Widget _buildRecommendations(
    ThemeData theme, {
    required List<String> recommendations,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...recommendations.map((rec) => _buildBulletPoint(theme, rec)),
        ],
      ),
    );
  }

  Widget _buildMetricsPreview(ThemeData theme, Map<String, dynamic> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                theme,
                'Pressure',
                '${(metrics['pressure'] as num).toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                theme,
                'Redness',
                '${(metrics['redness'] as num).toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                theme,
                'Dryness',
                '${(metrics['dryness'] as num).toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildMetrics(ThemeData theme) {
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
                child: _buildMetricItem(theme, 'TBUT (Left)', '8.2 seconds'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(theme, 'TBUT (Right)', '10.1 seconds'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(theme, 'Tear Meniscus', '0.22 mm'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  theme,
                  'Osmolarity (Est.)',
                  '310 mOsm/L',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Corneal Assessment',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSliderMetric(
            theme,
            label: 'Corneal Thickness (Est.)',
            value: '540 μm',
            minLabel: 'Thin',
            maxLabel: 'Thick',
            progress: 0.5,
          ),
          const SizedBox(height: 16),
          _buildSliderMetric(
            theme,
            label: 'Corneal Surface Regularity',
            value: '4/5 - Good',
            minLabel: '',
            maxLabel: '',
            progress: 0.8,
          ),
          const SizedBox(height: 24),
          Text(
            'Predictive Analysis',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildRiskMetric(
            theme,
            title: 'Dry Eye Progression Risk',
            value: '35%',
            description:
                'Based on environmental factors, screen time, and current symptoms',
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
}
