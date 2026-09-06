import 'dart:math';
import 'package:flutter/material.dart';

class StylizedQrPainter extends CustomPainter {
  final String data;
  final Color primaryColor;
  final Color backgroundColor;

  StylizedQrPainter({
    required this.data,
    this.primaryColor = const Color(0xFF6366F1),
    this.backgroundColor = const Color(0xFF0F1422),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );
    canvas.drawRRect(rrect, bgPaint);

    const int modules = 21;
    final double moduleSize = (size.width - 40) / modules;
    final double offset = 20.0;

    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final random = Random(data.hashCode);

    // Draw grid modules
    for (int r = 0; r < modules; r++) {
      for (int c = 0; c < modules; c++) {
        // Skip corner detection squares and center logo area
        if ((r < 7 && c < 7) ||
            (r < 7 && c >= modules - 7) ||
            (r >= modules - 7 && c < 7) ||
            (r >= 8 && r <= 12 && c >= 8 && c <= 12)) {
          continue;
        }

        if (random.nextBool() || (r + c) % 3 == 0) {
          final x = offset + c * moduleSize + moduleSize * 0.15;
          final y = offset + r * moduleSize + moduleSize * 0.15;
          final dSize = moduleSize * 0.7;

          final dotRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, dSize, dSize),
            Radius.circular(dSize * 0.35),
          );
          canvas.drawRRect(dotRect, dotPaint);
        }
      }
    }

    // Draw the three finder patterns (corners)
    _drawFinderPattern(canvas, offset, offset, moduleSize * 7);
    _drawFinderPattern(canvas, size.width - offset - moduleSize * 7, offset, moduleSize * 7);
    _drawFinderPattern(canvas, offset, size.height - offset - moduleSize * 7, moduleSize * 7);

    // Draw center logo circle
    final center = Offset(size.width / 2, size.height / 2);
    final logoBgPaint = Paint()..color = backgroundColor;
    final logoBorderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, 22, logoBgPaint);
    canvas.drawCircle(center, 22, logoBorderPaint);

    // Center icon glow
    final iconGlowPaint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 12, iconGlowPaint);
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double size) {
    final outerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final outerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, size, size),
      const Radius.circular(12),
    );
    canvas.drawRRect(outerRRect, outerPaint);

    final innerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final innerSize = size * 0.45;
    final innerOffset = (size - innerSize) / 2;
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + innerOffset, y + innerOffset, innerSize, innerSize),
      const Radius.circular(6),
    );
    canvas.drawRRect(innerRRect, innerPaint);
  }

  @override
  bool shouldRepaint(covariant StylizedQrPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.primaryColor != primaryColor;
}
