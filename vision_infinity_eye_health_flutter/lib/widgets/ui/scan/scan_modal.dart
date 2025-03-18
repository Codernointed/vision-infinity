import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import '../../../services/gemini_service.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

enum ScanState { preparation, aligning, preview, scanning, processing, complete }

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
          Image.file(
            File(image.path),
            fit: BoxFit.contain,
            height: 300,
          ),
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
                                  () => _handleButtonPress(
                                    ref,
                                    context,
                                    scanState,
                                  ),
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
        return 0.5;  // Add preview state
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
        return Icons.preview_outlined;  // Add preview state
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
        return 'Preview';  // Add preview state
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
        return 'Review the image and confirm or retake';  // Add preview state
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
        return 'Confirm';  // Add preview state
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
        state == ScanState.preview ||  // Add preview state
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
        final ImagePicker picker = ImagePicker();
        final option = await showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text('Choose Image Source',
                style: Theme.of(context).textTheme.titleLarge),
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

        final XFile? image = await picker.pickImage(
          source: option == 'camera' ? ImageSource.camera : ImageSource.gallery,
          preferredCameraDevice: CameraDevice.front,
          imageQuality: 100,
        );

        if (image == null) return;

        if (!context.mounted) return;

        final bool? shouldProceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.file(
                    File(image.path),
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
                content: Text('Analyzing eye image...'),
                behavior: SnackBarBehavior.fixed,
                duration: Duration(seconds: 2),
              ),
            );
        }

        ref.read(scanStateProvider.notifier).state = ScanState.processing;
        
        final imageBytes = await image.readAsBytes();
        final analysis = await GeminiService.analyzeEyeImage(imageBytes);
        
        // Store analysis results
        _lastAnalysis = analysis;
        _lastImagePath = image.path;
        
        ref.read(scanStateProvider.notifier).state = ScanState.complete;

        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Analysis complete! Click View Results to continue'),
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
      
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (context.mounted && _lastAnalysis != null && _lastImagePath != null) {
        context.push('/results', extra: {
          ..._lastAnalysis!,
          'image_path': _lastImagePath,
          'timestamp': DateTime.now().toIso8601String(),
        });
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanningPainter(_controller.value),
          size: Size.infinite,
        );
      },
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

    // Draw scanning lines
    final scanPaint =
        Paint()
          ..shader = SweepGradient(
            colors: [
              Colors.blue.withOpacity(0),
              Colors.blue.withOpacity(0.5),
              Colors.blue.withOpacity(0),
            ],
            stops: const [0.0, 0.5, 1.0],
            transform: GradientRotation(progress * 2 * math.pi),
          ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, scanPaint);

    // Draw grid pattern
    final gridPaint =
        Paint()
          ..color = Colors.blue.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + progress * 2 * math.pi;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        gridPaint,
      );
    }

    // Draw pulsing circles
    final pulsePaint =
        Paint()
          ..color = Colors.blue.withOpacity((1 - progress) * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, radius * progress, pulsePaint);
    canvas.drawCircle(center, radius * (1 - progress), pulsePaint);
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Center(
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
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
                ),
                child: Center(
                  child: Text(
                    'Scanning...',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
