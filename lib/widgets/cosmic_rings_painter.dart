import 'dart:math';
import 'package:flutter/material.dart';

class CosmicRingsPainter extends CustomPainter {
  final double animationValue;

  CosmicRingsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final maxRadius = min(size.width, size.height) * 0.7;

    // Background radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6366F1).withOpacity(0.32),
          const Color(0xFF8B5CF6).withOpacity(0.18),
          const Color(0xFF06B6D4).withOpacity(0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 1.2));

    canvas.drawCircle(center, maxRadius * 1.2, glowPaint);

    // Multiple concentric orbits
    final ringRadii = [
      maxRadius * 0.35,
      maxRadius * 0.55,
      maxRadius * 0.78,
      maxRadius * 1.02,
      maxRadius * 1.25,
    ];

    for (int i = 0; i < ringRadii.length; i++) {
      final radius = ringRadii[i];
      final opacity = (0.28 - (i * 0.04)).clamp(0.06, 0.4);

      // Ring stroke with subtle gradient
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 2 ? 1.6 : 1.0
        ..color = i % 2 == 0
            ? const Color(0xFF818CF8).withOpacity(opacity)
            : const Color(0xFF06B6D4).withOpacity(opacity);

      // Draw oval tilted orbit
      canvas.save();
      canvas.translate(center.dx, center.dy);
      // Slight perspective tilt
      final tilt = (i.isEven ? 0.25 : -0.25) + (sin(animationValue * 2 * pi + i) * 0.05);
      canvas.rotate(tilt);
      canvas.scale(1.0, 0.65 + (i * 0.05));
      canvas.drawCircle(Offset.zero, radius, ringPaint);

      // Orbiting planetary satellite node
      final angle = (animationValue * 2 * pi * (i % 2 == 0 ? 1 : -1) * (0.8 + i * 0.2)) + (i * pi / 3);
      final nodeX = radius * cos(angle);
      final nodeY = radius * sin(angle);

      final nodePaint = Paint()
        ..color = i % 2 == 0 ? const Color(0xFF818CF8) : const Color(0xFF22D3EE);

      // Node glow
      final nodeGlowPaint = Paint()
        ..color = (i % 2 == 0 ? const Color(0xFF818CF8) : const Color(0xFF22D3EE)).withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(Offset(nodeX, nodeY), 6.0, nodeGlowPaint);
      canvas.drawCircle(Offset(nodeX, nodeY), 2.8, nodePaint);

      canvas.restore();
    }

    // Floating starlight particles
    final random = Random(42);
    final starPaint = Paint()..color = Colors.white.withOpacity(0.6);
    for (int j = 0; j < 30; j++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.8;
      final twinkle = sin(animationValue * 2 * pi * 2 + j) * 0.5 + 0.5;
      starPaint.color = Colors.white.withOpacity(0.2 + 0.5 * twinkle);
      canvas.drawCircle(Offset(x, y), 1.0 + twinkle * 1.2, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CosmicRingsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
