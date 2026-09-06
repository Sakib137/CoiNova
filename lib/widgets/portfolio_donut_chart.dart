import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';

class PortfolioDonutChart extends StatefulWidget {
  final List<CryptoAsset> assets;
  final double totalValue;
  final Function(CryptoAsset?)? onAssetSelected;

  const PortfolioDonutChart({
    super.key,
    required this.assets,
    required this.totalValue,
    this.onAssetSelected,
  });

  @override
  State<PortfolioDonutChart> createState() => _PortfolioDonutChartState();
}

class _PortfolioDonutChartState extends State<PortfolioDonutChart> {
  int? _selectedIndex;

  final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final selectedAsset = _selectedIndex != null && _selectedIndex! < widget.assets.length
        ? widget.assets[_selectedIndex!]
        : null;

    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom Painter Donut
              GestureDetector(
                onTapUp: (details) => _handleTap(details.localPosition, const Size(220, 220)),
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _DonutChartPainter(
                    assets: widget.assets,
                    totalValue: widget.totalValue,
                    selectedIndex: _selectedIndex,
                  ),
                ),
              ),

              // Center Interactive Info Readout
              GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = null);
                  widget.onAssetSelected?.call(null);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedAsset != null ? selectedAsset.symbol : 'TOTAL VAULT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: selectedAsset != null ? selectedAsset.brandColor : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selectedAsset != null
                          ? currency.format(selectedAsset.holdingFiatValue)
                          : currency.format(widget.totalValue),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (selectedAsset != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${((selectedAsset.holdingFiatValue / widget.totalValue) * 100).toStringAsFixed(1)}% of vault',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cyan,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      const Text(
                        'Tap slice to inspect',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleTap(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final dist = sqrt(dx * dx + dy * dy);

    // Only respond to taps on the ring itself (radius between 65 and 105)
    if (dist < 55 || dist > 115) {
      setState(() => _selectedIndex = null);
      widget.onAssetSelected?.call(null);
      return;
    }

    var angle = atan2(dy, dx);
    if (angle < 0) angle += 2 * pi;

    // Shift by start angle (-pi / 2)
    angle = (angle + pi / 2) % (2 * pi);

    double currentAngle = 0.0;
    for (int i = 0; i < widget.assets.length; i++) {
      final sweep = (widget.assets[i].holdingFiatValue / widget.totalValue) * 2 * pi;
      if (angle >= currentAngle && angle <= currentAngle + sweep) {
        setState(() => _selectedIndex = i);
        widget.onAssetSelected?.call(widget.assets[i]);
        return;
      }
      currentAngle += sweep;
    }
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CryptoAsset> assets;
  final double totalValue;
  final int? selectedIndex;

  _DonutChartPainter({
    required this.assets,
    required this.totalValue,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (assets.isEmpty || totalValue <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = 85.0;
    const strokeWidth = 16.0;

    double startAngle = -pi / 2;

    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];
      final sweepAngle = (asset.holdingFiatValue / totalValue) * 2 * pi;
      final isSelected = selectedIndex == i;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 6.0 : strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = asset.brandColor;

      // Glow effect for selected slice
      if (isSelected) {
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 14.0
          ..color = asset.brandColor.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: outerRadius),
          startAngle + 0.04,
          sweepAngle - 0.08,
          false,
          glowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: isSelected ? outerRadius + 2 : outerRadius),
        startAngle + 0.04,
        sweepAngle - 0.08,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex || oldDelegate.totalValue != totalValue;
}
