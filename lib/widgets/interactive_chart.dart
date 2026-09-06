import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InteractiveChart extends StatefulWidget {
  final List<double> data;
  final Color lineColor;
  final String activeTimeframe;
  final Function(String) onTimeframeChanged;
  final Function(double?)? onPriceScrubbed;

  const InteractiveChart({
    super.key,
    required this.data,
    required this.lineColor,
    required this.activeTimeframe,
    required this.onTimeframeChanged,
    this.onPriceScrubbed,
  });

  @override
  State<InteractiveChart> createState() => _InteractiveChartState();
}

class _InteractiveChartState extends State<InteractiveChart> {
  final timeframes = ['1H', '1D', '1W', '1M', '1Y', 'ALL'];
  double? _scrubNormalizedX;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chart Viewport with Touch Scrubbing
        SizedBox(
          height: 220,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onHorizontalDragStart: (details) => _handleScrub(details.localPosition.dx, constraints.maxWidth),
                onHorizontalDragUpdate: (details) => _handleScrub(details.localPosition.dx, constraints.maxWidth),
                onHorizontalDragEnd: (_) => _endScrub(),
                onTapDown: (details) => _handleScrub(details.localPosition.dx, constraints.maxWidth),
                onTapUp: (_) => _endScrub(),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 220),
                  painter: _InteractiveChartPainter(
                    data: widget.data,
                    lineColor: widget.lineColor,
                    scrubNormalizedX: _scrubNormalizedX,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Timeframe Selector Pills
        Container(
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: timeframes.map((tf) {
              final isSelected = tf == widget.activeTimeframe;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTimeframeChanged(tf),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected ? widget.lineColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: widget.lineColor.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tf,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (widget.lineColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _handleScrub(double localX, double totalWidth) {
    if (widget.data.isEmpty) return;

    final clampedX = localX.clamp(0.0, totalWidth);
    final normalized = (clampedX / totalWidth).clamp(0.0, 1.0);
    final index = (normalized * (widget.data.length - 1)).round().clamp(0, widget.data.length - 1);
    final price = widget.data[index];

    setState(() {
      _scrubNormalizedX = normalized;
    });

    widget.onPriceScrubbed?.call(price);
  }

  void _endScrub() {
    setState(() {
      _scrubNormalizedX = null;
    });
    widget.onPriceScrubbed?.call(null);
  }
}

class _InteractiveChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final double? scrubNormalizedX;

  _InteractiveChartPainter({
    required this.data,
    required this.lineColor,
    this.scrubNormalizedX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final topPadding = 20.0;
    final bottomPadding = 20.0;
    final availableHeight = size.height - topPadding - bottomPadding;

    // Draw subtle vertical & horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const gridLinesCount = 5;
    for (int i = 1; i < gridLinesCount; i++) {
      final y = topPadding + (availableHeight / gridLinesCount) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (int i = 1; i < 6; i++) {
      final x = (size.width / 6) * i;
      canvas.drawLine(Offset(x, topPadding), Offset(x, size.height - bottomPadding), gridPaint);
    }

    double minY = data.reduce((a, b) => a < b ? a : b);
    double maxY = data.reduce((a, b) => a > b ? a : b);

    if (maxY == minY) {
      maxY += 1.0;
      minY -= 1.0;
    }

    final dx = size.width / (data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final normalizedY = (data[i] - minY) / (maxY - minY);
      final y = size.height - bottomPadding - (normalizedY * availableHeight);
      points.add(Offset(i * dx, y));
    }

    // Smooth Bezier Curve Path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Gradient Area Fill
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.35),
          lineColor.withOpacity(0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Glowing line strokes
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = lineColor.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    // Scrubbing Indicator & Crosshair
    if (scrubNormalizedX != null) {
      final scrubX = scrubNormalizedX! * size.width;
      final index = (scrubNormalizedX! * (data.length - 1)).round().clamp(0, data.length - 1);
      final point = points[index];

      // Vertical dashed/dimmed crosshair line
      final crosshairPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawLine(Offset(scrubX, topPadding), Offset(scrubX, size.height - bottomPadding), crosshairPaint);

      // Outer glow pulse circle at point
      final pointGlow = Paint()
        ..color = lineColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(point, 12, pointGlow);

      // Center point
      final pointOuter = Paint()..color = Colors.white;
      canvas.drawCircle(point, 6, pointOuter);

      final pointInner = Paint()..color = lineColor;
      canvas.drawCircle(point, 3.5, pointInner);

      // Floating Price Tooltip Bubble
      final priceStr = '\$${data[index].toStringAsFixed(data[index] >= 100 ? 2 : 4)}';
      final textSpan = TextSpan(
        text: priceStr,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final bubbleWidth = textPainter.width + 20;
      final bubbleHeight = textPainter.height + 12;
      double bubbleX = (point.dx - bubbleWidth / 2).clamp(10.0, size.width - bubbleWidth - 10);
      double bubbleY = point.dy - bubbleHeight - 16;
      if (bubbleY < 6) {
        bubbleY = point.dy + 18; // Flip below point if too close to top
      }

      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bubbleX, bubbleY, bubbleWidth, bubbleHeight),
        const Radius.circular(10),
      );

      // Bubble shadow & background
      final bubbleShadow = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(bubbleRect.shift(const Offset(0, 3)), bubbleShadow);

      final bubbleBg = Paint()..color = const Color(0xFF151C2D);
      final bubbleBorder = Paint()
        ..color = lineColor.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawRRect(bubbleRect, bubbleBg);
      canvas.drawRRect(bubbleRect, bubbleBorder);

      textPainter.paint(
        canvas,
        Offset(bubbleX + 10, bubbleY + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.scrubNormalizedX != scrubNormalizedX;
  }
}
