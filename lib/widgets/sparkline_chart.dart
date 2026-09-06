import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SparklineChart extends StatelessWidget {
  final List<double> data;
  final bool isPositive;
  final Color? customColor;
  final double width;
  final double height;
  final bool showFill;

  const SparklineChart({
    super.key,
    required this.data,
    required this.isPositive,
    this.customColor,
    this.width = 72,
    this.height = 32,
    this.showFill = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    final lineColor = customColor ?? (isPositive ? AppColors.gain : AppColors.loss);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          lineColor: lineColor,
          showFill: showFill,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final bool showFill;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.showFill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    double minY = data.reduce((a, b) => a < b ? a : b);
    double maxY = data.reduce((a, b) => a > b ? a : b);

    // Prevent divide by zero if all values are identical
    if (maxY == minY) {
      maxY += 1.0;
      minY -= 1.0;
    }

    final dx = size.width / (data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final normalizedY = (data[i] - minY) / (maxY - minY);
      // Invert Y so highest price is at top
      final y = size.height - (normalizedY * (size.height - 4)) - 2;
      points.add(Offset(i * dx, y));
    }

    // Build smooth bezier spline
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Optional gradient fill under curve
    if (showFill) {
      final fillPath = Path.from(path);
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withOpacity(0.28),
            lineColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw main stroke with slight glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = lineColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
