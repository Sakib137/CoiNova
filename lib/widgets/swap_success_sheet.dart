import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';

class SwapSuccessSheet extends StatelessWidget {
  final CryptoAsset payAsset;
  final CryptoAsset receiveAsset;
  final double payAmount;
  final double receiveAmount;

  const SwapSuccessSheet({
    super.key,
    required this.payAsset,
    required this.receiveAsset,
    required this.payAmount,
    required this.receiveAmount,
  });

  static void show(
    BuildContext context, {
    required CryptoAsset payAsset,
    required CryptoAsset receiveAsset,
    required double payAmount,
    required double receiveAmount,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SwapSuccessSheet(
        payAsset: payAsset,
        receiveAsset: receiveAsset,
        payAmount: payAmount,
        receiveAmount: receiveAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const txHash = '0x8f23...c914e';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.gain.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gain.withOpacity(0.12),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Glowing Checkmark Orb
          Center(
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gain.withOpacity(0.3),
                    AppColors.gain.withOpacity(0.1),
                  ],
                ),
                border: Border.all(color: AppColors.gain, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gain.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.gain,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Center(
            child: Text(
              'Swap Executed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Confirmed on-chain via smart DEX aggregator',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),

          // Details receipt card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildReceiptRow('You Swapped', '${payAmount.toStringAsFixed(3)} ${payAsset.symbol}'),
                const SizedBox(height: 12),
                _buildReceiptRow('You Received', '${receiveAmount.toStringAsFixed(4)} ${receiveAsset.symbol}', isHighlight: true),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                _buildReceiptRow('Routing Protocol', 'Uniswap v3 + Curve'),
                const SizedBox(height: 12),
                _buildReceiptRow('Network Gas', '0.0014 ETH (\$4.82)'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transaction Hash', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: '0x8f237190bda33245c914e'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaction Hash copied to clipboard!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Row(
                        children: const [
                          Text(
                            txHash,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.cyan),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.copy_rounded, size: 13, color: AppColors.cyan),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isHighlight ? AppColors.gain : Colors.white,
          ),
        ),
      ],
    );
  }
}
