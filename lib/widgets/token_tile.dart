import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';
import 'sparkline_chart.dart';

class TokenTile extends StatelessWidget {
  final CryptoAsset asset;
  final VoidCallback onTap;
  final bool showHolding;

  const TokenTile({
    super.key,
    required this.asset,
    required this.onTap,
    this.showHolding = false,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Token Logo Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: asset.brandColor.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: asset.brandColor.withOpacity(0.3), width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    asset.iconData ?? Icons.monetization_on_rounded,
                    color: asset.brandColor,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Name and Symbol
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      showHolding && asset.userHolding > 0
                          ? '${asset.userHolding.toStringAsFixed(asset.userHolding >= 1 ? 2 : 4)} ${asset.symbol}'
                          : asset.symbol,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Sparkline Mini Chart
              Expanded(
                flex: 2,
                child: Center(
                  child: SparklineChart(
                    data: asset.sparkline,
                    isPositive: asset.isPositive,
                    width: 65,
                    height: 26,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Price and Change Percentage
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      showHolding && asset.userHolding > 0
                          ? currency.format(asset.holdingFiatValue)
                          : currency.format(asset.currentPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: asset.isPositive ? AppColors.gainSoft : AppColors.lossSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${asset.isPositive ? '+' : ''}${asset.change24h.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: asset.isPositive ? AppColors.gain : AppColors.loss,
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
    );
  }
}
