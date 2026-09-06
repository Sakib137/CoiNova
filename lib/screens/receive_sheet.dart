import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/mock_crypto_data.dart';
import '../theme/app_colors.dart';
import '../widgets/qr_code_painter.dart';

class ReceiveSheet extends StatelessWidget {
  const ReceiveSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const address = MockCryptoData.walletAddress;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          const Text(
            'Receive Assets',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const Text(
                'Ethereum & Multi-Chain EVM',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stylized QR Code Box
          Container(
            width: 210,
            height: 210,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D121F),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.primary.withOpacity(0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CustomPaint(
              size: const Size(186, 186),
              painter: StylizedQrPainter(
                data: address,
                primaryColor: AppColors.primaryLight,
                backgroundColor: const Color(0xFF0D121F),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Address Pill with Copy Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Your Wallet Address',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      SizedBox(height: 2),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: address));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF102A24),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.gain),
                        ),
                        content: Row(
                          children: const [
                            Icon(Icons.check_rounded, color: AppColors.gain),
                            SizedBox(width: 8),
                            Text('Address copied to clipboard!'),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.copy_rounded, size: 14, color: AppColors.primaryLight),
                        SizedBox(width: 6),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Network warning pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: AppColors.goldLight, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Deposit only EVM compatible tokens (Ethereum, Polygon, Arbitrum, Base) to this address.',
                    style: TextStyle(fontSize: 11, color: Color(0xFFFDE68A)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
