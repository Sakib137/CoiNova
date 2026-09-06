import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FearGreedMeter extends StatelessWidget {
  final int score; // 0 to 100
  final String sentiment;

  const FearGreedMeter({
    super.key,
    this.score = 78,
    this.sentiment = 'Extreme Greed',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Arc Gauge
          SizedBox(
            width: 72,
            height: 72,
            child: CustomPaint(
              painter: _GaugePainter(progress: score / 100.0),
              child: Center(
                child: Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Label and Insights
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.gain,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sentiment,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Crypto Market Sentiment Index',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.trending_up_rounded, size: 13, color: AppColors.cyan),
                    SizedBox(width: 4),
                    Text(
                      'Institutional Inflows: +\$1.42B (24h)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;

  _GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      trackPaint,
    );

    // Active progress arc with gradient
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: math.pi * 0.75,
        endAngle: math.pi * 2.25,
        colors: [
          AppColors.loss,
          AppColors.gold,
          AppColors.gain,
          AppColors.cyan,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (math.pi * 1.5) * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glowing tip indicator
    final currentAngle = math.pi * 0.75 + sweepAngle;
    final tipX = center.dx + radius * math.cos(currentAngle);
    final tipY = center.dy + radius * math.sin(currentAngle);

    final tipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

    canvas.drawCircle(Offset(tipX, tipY), 4, tipPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
