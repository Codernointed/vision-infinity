import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import '../../../services/camera_service.dart';
import '../../../models/model_analysis_result.dart';
import 'dart:io';

enum ScanState {
  preparation,
  aligning,
  preview,
  scanning,
  processing,
  complete,
}

final scanStateProvider = StateProvider<ScanState>(
  (ref) => ScanState.preparation,
);

class ImagePreviewDialog extends StatelessWidget {
  final XFile image;
  final VoidCallback onConfirm;
  final VoidCallback onRetake;

  const ImagePreviewDialog({
    required this.image,
    required this.onConfirm,
    required this.onRetake,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.file(File(image.path), fit: BoxFit.contain, height: 300),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onRetake();
                  },
                  child: const Text('Retake'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Particle effect painter for scanning animation
class _ParticleEffectPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles = [];
  
  _ParticleEffectPainter(this.progress) {
    // Initialize particles if empty
    if (particles.isEmpty) {
      for (var i = 0; i < 20; i++) {
        particles.add(
          _Particle(
          angle: math.Random().nextDouble() * 2 * math.pi,
          distance: math.Random().nextDouble() * 0.5 + 0.2,
          size: math.Random().nextDouble() * 2 + 1,
          speed: math.Random().nextDouble() * 0.02 + 0.01,
          ),
        );
      }
    }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;
    
    for (var particle in particles) {
      // Update particle position based on progress
      final angle = particle.angle + progress * particle.speed * 10;
      final distance =
          particle.distance + (math.sin(progress * 2 * math.pi) * 0.05);
      
      final x = center.dx + math.cos(angle) * radius * distance;
      final y = center.dy + math.sin(angle) * radius * distance;
      
      // Draw particle
      final particlePaint =
          Paint()
            ..color = Colors.blue.withOpacity(
              0.3 + 0.3 * math.sin(progress * 2 * math.pi + particle.angle),
            )
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), particle.size, particlePaint);
    }
  }
  
  @override
  bool shouldRepaint(_ParticleEffectPainter oldDelegate) => true;
}

// Particle class for animation
class _Particle {
  double angle;
  double distance;
  double size;
  double speed;
  
  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.speed,
  });
}

// Scanner line painter
class _ScannerLinePainter extends CustomPainter {
  final double progress;
  
  _ScannerLinePainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Draw horizontal scanning line
    final scanY = center.dy + math.sin(progress * 2 * math.pi) * radius * 0.7;
    
    final scanLinePaint =
        Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.blue.withOpacity(0.8),
          Colors.white.withOpacity(0.9),
          Colors.blue.withOpacity(0.8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
          ).createShader(
            Rect.fromLTWH(center.dx - radius, scanY - 1, radius * 2, 2),
          )
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(center.dx - radius, scanY - 1, radius * 2, 2),
      scanLinePaint,
    );
    
    // Draw vertical scanning line
    final scanX =
        center.dx +
        math.cos(progress * 2 * math.pi + math.pi / 2) * radius * 0.7;
    
    final verticalScanPaint =
        Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.blue.withOpacity(0.8),
          Colors.white.withOpacity(0.9),
          Colors.blue.withOpacity(0.8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
          ).createShader(
            Rect.fromLTWH(scanX - 1, center.dy - radius, 2, radius * 2),
          )
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(scanX - 1, center.dy - radius, 2, radius * 2),
      verticalScanPaint,
    );
  }
  
  @override
  bool shouldRepaint(_ScannerLinePainter oldDelegate) => true;
}

class ScanModal extends ConsumerWidget {
  const ScanModal({super.key});

  static Map<String, dynamic>? _lastAnalysis;
  static String? _lastImagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanStateProvider);
    final theme = Theme.of(context);
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.999,
          maxHeight: MediaQuery.of(context).size.height * 0.89,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Eye Scan',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: _getProgressValue(scanState),
                              backgroundColor: theme.colorScheme.primary,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref.read(scanStateProvider.notifier).state =
                              ScanState.preparation;
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                // Main Content
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E40AF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          if (scanState == ScanState.scanning)
                            const _ScanningAnimation(),
                          _buildScanContent(scanState, theme),
                        ],
                      ),
                    ),
                  ),
                ),

                // Instructions and Controls
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Step indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getStepIcon(scanState),
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getStepTitle(scanState),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getInstructionText(scanState),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (scanState == ScanState.preparation)
                        Row(
                          children: [
                            Expanded(
                              child: _buildPreparationStep(
                                theme,
                                icon: Icons.wb_sunny_outlined,
                                title: 'Good Lighting',
                                subtitle: 'Find a well-lit area',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPreparationStep(
                                theme,
                                icon: Icons.remove_red_eye_outlined,
                                title: 'Eye Position',
                                subtitle: 'Keep eyes fully open',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildPreparationStep(
                                theme,
                                icon: Icons.stay_current_portrait,
                                title: 'Hold Steady',
                                subtitle: 'Keep device stable',
                              ),
                            ),
                          ],
                        ),
                      if (_shouldShowButton(scanState))
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed:
                                () =>
                                    _handleButtonPress(ref, context, scanState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(_getButtonText(scanState)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildPreparationStep(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _getProgressValue(ScanState state) {
    switch (state) {
      case ScanState.preparation:
        return 0.2;
      case ScanState.aligning:
        return 0.4;
      case ScanState.preview:
        return 0.5; // Add preview state
      case ScanState.scanning:
        return 0.6;
      case ScanState.processing:
        return 0.8;
      case ScanState.complete:
        return 1.0;
    }
  }

  IconData _getStepIcon(ScanState state) {
    switch (state) {
      case ScanState.preparation:
        return Icons.checklist_outlined;
      case ScanState.aligning:
        return Icons.center_focus_strong_outlined;
      case ScanState.preview:
        return Icons.preview_outlined; // Add preview state
      case ScanState.scanning:
        return Icons.camera_outlined;
      case ScanState.processing:
        return Icons.analytics_outlined;
      case ScanState.complete:
        return Icons.check_circle_outline;
    }
  }

  String _getStepTitle(ScanState state) {
    switch (state) {
      case ScanState.preparation:
        return 'Preparation';
      case ScanState.aligning:
        return 'Alignment';
      case ScanState.preview:
        return 'Preview'; // Add preview state
      case ScanState.scanning:
        return 'Scanning';
      case ScanState.processing:
        return 'Processing';
      case ScanState.complete:
        return 'Complete';
    }
  }

  String _getInstructionText(ScanState state) {
    switch (state) {
      case ScanState.preparation:
        return 'Please ensure you follow these guidelines for the best results';
      case ScanState.aligning:
        return 'Position your face within the frame and keep your eyes open';
      case ScanState.preview:
        return 'Review the image and confirm or retake'; // Add preview state
      case ScanState.scanning:
        return 'Please remain still while we scan your eyes';
      case ScanState.processing:
        return 'Our AI is analyzing your eye health...';
      case ScanState.complete:
        return 'Scan completed successfully!';
    }
  }

  String _getButtonText(ScanState state) {
    switch (state) {
      case ScanState.preparation:
        return 'Begin Scan';
      case ScanState.aligning:
        return 'Take Photo';
      case ScanState.preview:
        return 'Confirm'; // Add preview state
      case ScanState.scanning:
      case ScanState.processing:
        return '';
      case ScanState.complete:
        return 'View Results';
    }
  }

  bool _shouldShowButton(ScanState state) {
    return state == ScanState.preparation ||
        state == ScanState.aligning ||
        state == ScanState.preview || // Add preview state
        state == ScanState.complete;
  }

  void _handleButtonPress(
    WidgetRef ref,
    BuildContext context,
    ScanState state,
  ) async {
    if (state == ScanState.preparation) {
      ref.read(scanStateProvider.notifier).state = ScanState.aligning;
    } else if (state == ScanState.aligning) {
      try {
        final cameraService = CameraService();

        final option = await showDialog<String>(
          context: context,
          builder:
              (BuildContext context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  'Choose Image Source',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
              ],
            ),
          ),
        );

        if (option == null) return;

        XFile? image;
        if (option == 'camera') {
          image = await cameraService.captureImage();
        } else {
          image = await cameraService.pickImageFromGallery();
        }

        if (image == null) return;

        // // Validate image quality
        // if (!cameraService.validateImageQuality(image)) {
        //   if (context.mounted) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(
        //         content: Text(
        //           'Image quality is too low. Please try again with a clearer image.',
        //         ),
        //         backgroundColor: Colors.orange,
        //         behavior: SnackBarBehavior.fixed,
        //         duration: Duration(seconds: 3),
        //       ),
        //     );
        //   }
        //   return;
        // }

        if (!context.mounted) return;

        final bool? shouldProceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                  child: Image.file(
                        File(image!.path),
                    fit: BoxFit.cover,
                    height: 300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Confirm Image',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Is this image clear and well-lit?',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Retake'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Proceed'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (shouldProceed != true) {
          ref.read(scanStateProvider.notifier).state = ScanState.aligning;
          return;
        }

        // Show loading indicator
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Analyzing eye image with AI...'),
                behavior: SnackBarBehavior.fixed,
                duration: Duration(seconds: 2),
              ),
            );
        }

        ref.read(scanStateProvider.notifier).state = ScanState.processing;
        
        // Use the camera service to analyze the image
        final ModelAnalysisResult? analysis = await cameraService.analyzeImage(
          image,
        );

        print(
          '🔍 Analysis result received: ${analysis != null ? 'SUCCESS' : 'NULL'}',
        );
        if (analysis != null) {
          print('🔍 Analysis has error: ${analysis.hasError}');
          print(
            '🔍 Basic mode assessment: ${analysis.basicMode.overallAssessment}',
          );
        }

        if (analysis == null) {
          throw Exception(
            'Failed to analyze image - camera service returned null',
          );
        }
        
        // Store analysis results
        _lastAnalysis = analysis.toJson();
        _lastImagePath = image!.path;

        print(
          '💾 Stored analysis results: ${_lastAnalysis != null ? 'SUCCESS' : 'FAILED'}',
        );
        print('💾 Image path stored: $_lastImagePath');
        
        ref.read(scanStateProvider.notifier).state = ScanState.complete;

        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'AI analysis complete! Click View Results to continue',
                ),
                behavior: SnackBarBehavior.fixed,
                duration: Duration(seconds: 2),
              ),
            );
        }
      } catch (e) {
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.fixed,
              duration: const Duration(seconds: 3),
            ),
          );
        ref.read(scanStateProvider.notifier).state = ScanState.preparation;
      }
    } else if (state == ScanState.complete) {
      // Clear any existing snackbars before navigation
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      print('🚀 View Results button clicked!');
      print(
        '🚀 Last analysis data: ${_lastAnalysis != null ? 'AVAILABLE' : 'NULL'}',
      );
      print('🚀 Last image path: $_lastImagePath');
      
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (context.mounted && _lastAnalysis != null && _lastImagePath != null) {
        print('🚀 Navigating to results page...');
        final navigationData = {
          ..._lastAnalysis!,
          'image_path': _lastImagePath,
          'timestamp': DateTime.now().toIso8601String(),
        };
        print('🚀 Navigation data: $navigationData');

        context.push('/results', extra: navigationData);
      } else {
        print('❌ Cannot navigate - missing data:');
        print('❌ Analysis: ${_lastAnalysis != null ? 'OK' : 'NULL'}');
        print('❌ Image path: ${_lastImagePath != null ? 'OK' : 'NULL'}');
        print('❌ Context mounted: ${context.mounted}');
      }
    }
  }

  Widget _buildScanContent(ScanState state, ThemeData theme) {
    switch (state) {
      case ScanState.preparation:
      case ScanState.aligning:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                state == ScanState.preparation
                    ? 'Getting Ready'
                    : 'Align Your Eyes',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case ScanState.scanning:
        return const Center(child: _ScannerOverlay());
      case ScanState.processing:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Processing scan...',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case ScanState.complete:
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan Complete!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      case ScanState.preview:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

class _ScanningAnimation extends StatefulWidget {
  const _ScanningAnimation();

  @override
  State<_ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<_ScanningAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background glow effect
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2 + 0.1 * _pulseAnimation.value),
                    Colors.transparent,
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            );
          },
        ),
        // Main scanning animation
        AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ScanningPainter(_mainController.value),
              size: Size.infinite,
            );
          },
        ),
        // Particle effects
        AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticleEffectPainter(_mainController.value),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class _ScanningPainter extends CustomPainter {
  final double progress;

  _ScanningPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;

    // Draw scanning lines with improved gradient
    final scanPaint =
        Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.blue.withOpacity(0),
          Colors.blue.withOpacity(0.1),
          Colors.blue.withOpacity(0.6),
          Colors.blue.withOpacity(0.1),
          Colors.blue.withOpacity(0),
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, scanPaint);

    // Draw hexagonal grid pattern
    final gridPaint =
        Paint()
      ..color = Colors.blue.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Horizontal and vertical grid lines
    for (var i = -4; i <= 4; i += 2) {
      final offset = i * (radius / 4);
      
      // Horizontal line
      canvas.drawLine(
        Offset(center.dx - radius * 0.8, center.dy + offset),
        Offset(center.dx + radius * 0.8, center.dy + offset),
        gridPaint,
      );
      
      // Vertical line
      canvas.drawLine(
        Offset(center.dx + offset, center.dy - radius * 0.8),
        Offset(center.dx + offset, center.dy + radius * 0.8),
        gridPaint,
      );
    }

    // Draw diagonal grid lines
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 + progress * math.pi / 2;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(angle) * radius * 0.8,
          center.dy + math.sin(angle) * radius * 0.8,
        ),
        gridPaint,
      );
    }

    // Draw scanning circle
    final scanCirclePaint =
        Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Animated scanning circle that moves up and down
    final scanY = math.sin(progress * 2 * math.pi) * radius * 0.5;
    canvas.drawCircle(
      Offset(center.dx, center.dy + scanY),
      radius * 0.3,
      scanCirclePaint,
    );

    // Draw pulsing circles with improved effect
    final pulsePaint =
        Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.blue.withOpacity(0.7),
          Colors.blue.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Multiple pulsing circles
    final pulseRadius1 = radius * (0.3 + 0.7 * ((progress * 2) % 1.0));
    final pulseRadius2 = radius * (0.3 + 0.7 * (((progress * 2) + 0.5) % 1.0));
    
    canvas.drawCircle(center, pulseRadius1, pulsePaint);
    canvas.drawCircle(center, pulseRadius2, pulsePaint);
    
    // Draw targeting brackets at corners
    final bracketPaint =
        Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final bracketSize = radius * 0.15;
    
    // Draw brackets at four corners
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final x = center.dx + math.cos(angle) * radius * 0.7;
      final y = center.dy + math.sin(angle) * radius * 0.7;
      
      // First line of bracket
      canvas.drawLine(
        Offset(x, y),
        Offset(
          x - math.cos(angle) * bracketSize,
          y - math.sin(angle) * bracketSize,
        ),
        bracketPaint,
      );
      
      // Second line of bracket
      canvas.drawLine(
        Offset(x, y),
        Offset(
          x - math.cos(angle + math.pi / 2) * bracketSize,
          y - math.sin(angle + math.pi / 2) * bracketSize,
        ),
        bracketPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScanningPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

class _ScannerOverlay extends StatefulWidget {
  const _ScannerOverlay();

  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.linear));
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background glow effect
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1 + 0.05 * _pulseAnimation.value),
                    Colors.transparent,
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            );
          },
        ),
        
        // Rotating elements
        AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return Stack(
              children: [
                // Outer rotating circle
                Center(
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.6),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(110),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        // Corner markers
                        child: Stack(
                          children: List.generate(4, (index) {
                            final angle = index * (math.pi / 2);
                            return Positioned(
                              left: 110 + 100 * math.cos(angle) - 10,
                              top: 110 + 100 * math.sin(angle) - 10,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.8),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Inner static circle with scanning text
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(90),
                      gradient: RadialGradient(
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.1, 1.0],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scanning...',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 100,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: AnimatedBuilder(
                              animation: _mainController,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _mainController.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Scanning lines
                Center(
                  child: CustomPaint(
                    painter: _ScannerLinePainter(_mainController.value),
                    size: const Size(220, 220),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
