import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crypto_asset.dart';
import 'sparkline_chart.dart';

class BentoAssetCard extends StatefulWidget {
  final CryptoAsset asset;
  final VoidCallback onTap;
  final Gradient cardGradient;

  const BentoAssetCard({
    super.key,
    required this.asset,
    required this.onTap,
    required this.cardGradient,
  });

  @override
  State<BentoAssetCard> createState() => _BentoAssetCardState();
}

class _BentoAssetCardState extends State<BentoAssetCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final asset = widget.asset;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 175,
          height: 185,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: widget.cardGradient,
            border: Border.all(color: Colors.white.withOpacity(0.16), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: asset.brandColor.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                // Top-left specular light glare / sheen
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom embedded wavy chart
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: SparklineChart(
                    data: asset.sparkline,
                    isPositive: asset.isPositive,
                    customColor: Colors.white.withOpacity(0.85),
                    width: 175,
                    height: 80,
                    showFill: true,
                  ),
                ),

                // Card Content Header & Stats
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Icon & Symbol & Live Pulse Dot
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.2),
                            ),
                            child: Icon(
                              asset.iconData ?? Icons.monetization_on_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        asset.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF34D399),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${asset.userHolding} ${asset.symbol}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Price & Percentage Gain
                      Text(
                        currency.format(asset.currentPrice),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: asset.isPositive
                                ? const Color(0xFF34D399).withOpacity(0.3)
                                : const Color(0xFFF87171).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${asset.isPositive ? '+' : ''}${asset.change24h.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: asset.isPositive ? const Color(0xFF6EE7B7) : const Color(0xFFFDA4AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
