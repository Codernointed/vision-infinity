import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/audio_button.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
            label: const Text('Filter'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHistoryItem(
            context,
            theme,
            date: 'May 4, 2025',
            time: '6:24 PM',
            status: 'Healthy',
            description:
                'Your eyes are in excellent condition. No issues detected.',
            scanData: {
              'date': 'May 4, 2025',
              'time': '6:24 PM',
              'status': 'Good',
              'description':
                  'Your eyes appear healthy with mild signs of dryness. No serious conditions detected.',
            },
          ),
          _buildHistoryItem(
            context,
            theme,
            date: 'April 28, 2025',
            time: '9:15 AM',
            status: 'Mild Dryness',
            description: 'Slight dryness detected. Consider using eye drops.',
            statusColor: const Color(0xFFF59E0B),
            scanData: {
              'date': 'April 28, 2025',
              'time': '9:15 AM',
              'status': 'Mild Dryness',
              'description':
                  'Slight dryness detected. Consider using eye drops.',
            },
          ),
          _buildHistoryItem(
            context,
            theme,
            date: 'April 15, 2025',
            time: '2:30 PM',
            status: 'Healthy',
            description: 'Your eye health is good. Keep up the good habits.',
            scanData: {
              'date': 'April 15, 2025',
              'time': '2:30 PM',
              'status': 'Good',
              'description':
                  'Your eye health is good. Keep up the good habits.',
            },
          ),
          _buildHistoryItem(
            context,
            theme,
            date: 'March 30, 2025',
            time: '11:45 AM',
            status: 'Moderate Redness',
            description:
                'Moderate redness detected. Rest your eyes and avoid screens for a while.',
            statusColor: const Color(0xFFF97316),
            scanData: {
              'date': 'March 30, 2025',
              'time': '11:45 AM',
              'status': 'Moderate Redness',
              'description':
                  'Moderate redness detected. Rest your eyes and avoid screens for a while.',
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    ThemeData theme, {
    required String date,
    required String time,
    required String status,
    required String description,
    Color statusColor = Colors.green,
    required Map<String, dynamic> scanData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/results', extra: scanData);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          Row(
                            children: [
                              Text(
                                'Eye Scan',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.2),
                                  ),
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
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$date • $time',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              AudioButton(
                                text: description,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  context.push('/results', extra: scanData);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'View Details',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
