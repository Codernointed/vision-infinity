import 'package:flutter/material.dart';
import 'dart:math' as math;

class EyeScanFrame extends StatelessWidget {
  const EyeScanFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          CustomPaint(painter: _EyeScanFramePainter(), size: Size.infinite),
          Center(
            child: Text(
              'Position your eyes within the frame',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EyeScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;

    // Draw glow effect
    final glowPaint =
        Paint()
          ..color = const Color(0xFF3B82F6).withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius * 1.2, glowPaint);

    // Draw outer circle with gradient
    final outerCirclePaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF3B82F6).withOpacity(0.6),
              const Color(0xFF3B82F6).withOpacity(0.3),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerCirclePaint);

    // Draw cross lines
    final linePaint =
        Paint()
          ..color = const Color(0xFF3B82F6).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      linePaint,
    );

    // Draw inner circle with gradient
    final innerCirclePaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF3B82F6).withOpacity(0.8),
              const Color(0xFF3B82F6).withOpacity(0.4),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 0.3))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.3, innerCirclePaint);

    // Draw rotating arcs
    final arcPaint =
        Paint()
          ..shader = SweepGradient(
            colors: [
              const Color(0xFF3B82F6).withOpacity(0.6),
              const Color(0xFF3B82F6).withOpacity(0.2),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    for (var i = 0; i < 4; i++) {
      final startAngle = (i * math.pi / 2) + math.pi / 6;
      const sweepAngle = math.pi / 3;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 1.2),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // Add subtle pulse effect dots
    final dotPaint =
        Paint()
          ..color = const Color(0xFF3B82F6).withOpacity(0.6)
          ..style = PaintingStyle.fill;

    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final x = center.dx + math.cos(angle) * radius * 1.3;
      final y = center.dy + math.sin(angle) * radius * 1.3;
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_EyeScanFramePainter oldDelegate) => false;
}
