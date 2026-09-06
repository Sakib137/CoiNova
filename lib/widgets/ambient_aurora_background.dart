import 'dart:math';
import 'package:flutter/material.dart';

class AmbientAuroraBackground extends StatefulWidget {
  final Widget child;

  const AmbientAuroraBackground({super.key, required this.child});

  @override
  State<AmbientAuroraBackground> createState() => _AmbientAuroraBackgroundState();
}

class _AmbientAuroraBackgroundState extends State<AmbientAuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid deep obsidian base
        Container(color: const Color(0xFF07090E)),

        // Animated ambient glow orbs
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _AuroraPainter(progress: _controller.value),
              );
            },
          ),
        ),

        // Foreground content
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;

  _AuroraPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * pi;

    // Orb 1: Neon Indigo / Electric Violet (Top Left to Center)
    final orb1Center = Offset(
      size.width * 0.25 + cos(t) * 40,
      size.height * 0.15 + sin(t) * 35,
    );
    final orb1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6366F1).withOpacity(0.22),
          const Color(0xFF8B5CF6).withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: orb1Center, radius: size.width * 0.75));

    canvas.drawCircle(orb1Center, size.width * 0.75, orb1Paint);

    // Orb 2: Cyber Cyan (Right Upper Center)
    final orb2Center = Offset(
      size.width * 0.85 - sin(t * 0.8) * 45,
      size.height * 0.32 + cos(t * 0.8) * 30,
    );
    final orb2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF06B6D4).withOpacity(0.15),
          const Color(0xFF3B82F6).withOpacity(0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: orb2Center, radius: size.width * 0.65));

    canvas.drawCircle(orb2Center, size.width * 0.65, orb2Paint);

    // Orb 3: Emerald Gold Flare (Bottom Left)
    final orb3Center = Offset(
      size.width * 0.15 + sin(t * 1.2) * 30,
      size.height * 0.75 - cos(t * 1.2) * 35,
    );
    final orb3Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF10B981).withOpacity(0.10),
          const Color(0xFFF59E0B).withOpacity(0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: orb3Center, radius: size.width * 0.7));

    canvas.drawCircle(orb3Center, size.width * 0.7, orb3Paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
