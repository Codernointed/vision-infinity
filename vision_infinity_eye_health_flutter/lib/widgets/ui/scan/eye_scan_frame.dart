import 'package:flutter/material.dart';
import 'dart:math' as math;

class EyeScanFrame extends StatefulWidget {
  const EyeScanFrame({super.key});

  @override
  State<EyeScanFrame> createState() => _EyeScanFrameState();
}

class _EyeScanFrameState extends State<EyeScanFrame> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: _EyeScanFramePainter(
                  pulseValue: _pulseAnimation.value,
                  rotationValue: _rotationAnimation.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Position your eyes within the frame',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Keep eyes fully open',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EyeScanFramePainter extends CustomPainter {
  final double pulseValue;
  final double rotationValue;
  
  _EyeScanFramePainter({
    required this.pulseValue,
    required this.rotationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35 * pulseValue;

    // Draw glow effect with animated opacity
    final glowOpacity = 0.1 + (math.sin(rotationValue * 2) + 1) / 2 * 0.2;
    final glowPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(glowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(center, radius * 1.3, glowPaint);

    // Draw outer circle with gradient and animation
    final outerCirclePaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF3B82F6).withOpacity(0.8),
          const Color(0xFF3B82F6).withOpacity(0.4),
          const Color(0xFF3B82F6).withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(rotationValue),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, outerCirclePaint);

    // Draw grid pattern with animation
    final gridPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Horizontal and vertical lines
    for (var i = -5; i <= 5; i++) {
      final offset = i * (radius / 5);
      
      // Horizontal line
      canvas.drawLine(
        Offset(center.dx - radius, center.dy + offset),
        Offset(center.dx + radius, center.dy + offset),
        gridPaint,
      );
      
      // Vertical line
      canvas.drawLine(
        Offset(center.dx + offset, center.dy - radius),
        Offset(center.dx + offset, center.dy + radius),
        gridPaint,
      );
    }

    // Draw inner circle with gradient
    final innerCirclePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3B82F6).withOpacity(0.9),
          const Color(0xFF3B82F6).withOpacity(0.5),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.3))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.3, innerCirclePaint);

    // Draw rotating corner brackets
    final cornerPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cornerLength = radius * 0.2;
    
    // Draw corners with rotation
    for (var i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + rotationValue / 4;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      
      // First line of corner
      canvas.drawLine(
        Offset(center.dx + x, center.dy + y),
        Offset(center.dx + x - math.cos(angle) * cornerLength, 
               center.dy + y - math.sin(angle) * cornerLength),
        cornerPaint,
      );
      
      // Second line of corner
      canvas.drawLine(
        Offset(center.dx + x, center.dy + y),
        Offset(center.dx + x - math.cos(angle + math.pi/2) * cornerLength, 
               center.dy + y - math.sin(angle + math.pi/2) * cornerLength),
        cornerPaint,
      );
    }

    // Draw scanning line animation
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF3B82F6).withOpacity(0.8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
        center.dx - radius,
        center.dy - radius + (radius * 2 * rotationValue % (radius * 4)),
        radius * 2,
        10,
      ))
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - radius,
        center.dy - radius + (radius * 2 * rotationValue % (radius * 4)),
        radius * 2,
        2,
      ),
      scanPaint,
    );

    // Add pulsing corner dots
    final dotSize = 3 + math.sin(rotationValue * 3) * 1;
    final dotPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final x = center.dx + math.cos(angle) * radius * 1.1;
      final y = center.dy + math.sin(angle) * radius * 1.1;
      canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
    }
    
    // Draw focus guides
    final focusGuidePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    // Draw focus circle
    canvas.drawCircle(
      center,
      radius * 0.6,
      focusGuidePaint,
    );
  }

  @override
  bool shouldRepaint(_EyeScanFramePainter oldDelegate) => 
      pulseValue != oldDelegate.pulseValue ||
      rotationValue != oldDelegate.rotationValue;
}
