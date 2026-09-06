import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';

class DexRouteVisualizer extends StatefulWidget {
  final CryptoAsset payAsset;
  final CryptoAsset receiveAsset;

  const DexRouteVisualizer({
    super.key,
    required this.payAsset,
    required this.receiveAsset,
  });

  @override
  State<DexRouteVisualizer> createState() => _DexRouteVisualizerState();
}

class _DexRouteVisualizerState extends State<DexRouteVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_graph_rounded, size: 14, color: AppColors.cyan),
                  SizedBox(width: 6),
                  Text(
                    'Smart DEX Aggregation',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gain.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gain.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bolt, size: 11, color: AppColors.gain),
                    SizedBox(width: 2),
                    Text(
                      'Saves \$14.20',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Node Diagram
          Row(
            children: [
              // Source Token
              _buildTokenNode(widget.payAsset),

              // Animated Route Circuit
              Expanded(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _CircuitPathPainter(
                        animationValue: _pulseController.value,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            _buildDexHopPill('Uniswap v3', '68%', AppColors.primaryLight),
                            const SizedBox(height: 6),
                            _buildDexHopPill('Curve 3Pool', '32%', AppColors.cyan),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Target Token
              _buildTokenNode(widget.receiveAsset),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenNode(CryptoAsset asset) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        shape: BoxShape.circle,
        border: Border.all(color: asset.brandColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: asset.brandColor.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          asset.iconData ?? Icons.circle,
          color: asset.brandColor,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDexHopPill(String name, String split, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text(
            split,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _CircuitPathPainter extends CustomPainter {
  final double animationValue;

  _CircuitPathPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Center horizontal guide lines
    final midY = size.height / 2;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), linePaint);

    // Glowing particle along the line
    final particleX = size.width * animationValue;
    final particlePaint = Paint()
      ..color = AppColors.cyan
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    canvas.drawCircle(Offset(particleX, midY), 3.0, particlePaint);
  }

  @override
  bool shouldRepaint(covariant _CircuitPathPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
