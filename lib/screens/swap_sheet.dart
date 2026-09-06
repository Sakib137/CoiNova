import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';
import '../widgets/dex_route_visualizer.dart';
import '../widgets/slide_to_confirm.dart';
import '../widgets/swap_success_sheet.dart';

class SwapSheet extends StatefulWidget {
  final List<CryptoAsset> assets;
  final CryptoAsset? initialPayAsset;
  final CryptoAsset? initialReceiveAsset;

  const SwapSheet({
    super.key,
    required this.assets,
    this.initialPayAsset,
    this.initialReceiveAsset,
  });

  @override
  State<SwapSheet> createState() => _SwapSheetState();
}

class _SwapSheetState extends State<SwapSheet> with SingleTickerProviderStateMixin {
  late CryptoAsset _payAsset;
  late CryptoAsset _receiveAsset;
  final TextEditingController _payController = TextEditingController(text: '1.0');
  double _slippage = 0.5;
  bool _isSwapping = false;
  late AnimationController _rotationController;

  final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _payAsset = widget.initialPayAsset ??
        widget.assets.firstWhere((a) => a.symbol == 'ETH', orElse: () => widget.assets[0]);
    _receiveAsset = widget.initialReceiveAsset ??
        widget.assets.firstWhere((a) => a.symbol == 'SOL', orElse: () => widget.assets[1]);

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _payController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  double get _payAmount => double.tryParse(_payController.text) ?? 0.0;
  double get _exchangeRate => _payAsset.currentPrice / (_receiveAsset.currentPrice > 0 ? _receiveAsset.currentPrice : 1.0);
  double get _receiveAmount => _payAmount * _exchangeRate;

  void _flipTokens() {
    _rotationController.forward(from: 0.0);
    setState(() {
      final temp = _payAsset;
      _payAsset = _receiveAsset;
      _receiveAsset = temp;
    });
  }

  void _executeSwap() async {
    if (_payAmount <= 0) return;
    setState(() => _isSwapping = true);

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final pay = _payAsset;
    final recv = _receiveAsset;
    final payAmt = _payAmount;
    final recvAmt = _receiveAmount;

    setState(() => _isSwapping = false);
    Navigator.of(context).pop();

    // Show luxury transaction receipt sheet
    SwapSuccessSheet.show(
      context,
      payAsset: pay,
      receiveAsset: recv,
      payAmount: payAmt,
      receiveAmount: recvAmt,
    );
  }

  void _setPercentAmount(double fraction) {
    final balance = _payAsset.userHolding > 0 ? _payAsset.userHolding : 5.0;
    final amt = balance * fraction;
    setState(() {
      _payController.text = amt.toStringAsFixed(amt < 1 ? 4 : 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        top: 18,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text(
                      'Instant Swap',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.verified_rounded, size: 16, color: AppColors.cyan),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.local_gas_station_rounded, size: 13, color: AppColors.cyan),
                      SizedBox(width: 4),
                      Text(
                        '14 Gwei',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.cyan),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // You Pay Box
            _buildTokenInputBox(
              title: 'You Pay',
              asset: _payAsset,
              isEditable: true,
              controller: _payController,
              onAssetTap: () => _selectToken(isPay: true),
              showPercentages: true,
            ),

            // Flip Button in center
            Center(
              child: GestureDetector(
                onTap: _flipTokens,
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_rotationController),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),

            // You Receive Box
            _buildTokenInputBox(
              title: 'You Receive (Est.)',
              asset: _receiveAsset,
              isEditable: false,
              displayValue: _receiveAmount.toStringAsFixed(4),
              onAssetTap: () => _selectToken(isPay: false),
            ),

            const SizedBox(height: 16),

            // Smart DEX Aggregation Multi-Hop Visualizer
            DexRouteVisualizer(
              payAsset: _payAsset,
              receiveAsset: _receiveAsset,
            ),

            const SizedBox(height: 14),

            // Slippage & Execution details
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rate', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        '1 ${_payAsset.symbol} = ${_exchangeRate.toStringAsFixed(4)} ${_receiveAsset.symbol}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Slippage Tolerance', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Row(
                        children: [0.1, 0.5, 1.0].map((s) {
                          final selected = _slippage == s;
                          return GestureDetector(
                            onTap: () => setState(() => _slippage = s),
                            child: Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: selected ? AppColors.primary : AppColors.border,
                                ),
                              ),
                              child: Text(
                                '$s%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Est. Gas Fee', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Row(
                        children: const [
                          Icon(Icons.bolt, size: 12, color: AppColors.gain),
                          SizedBox(width: 4),
                          Text(
                            '~ \$4.82 (Subsidized 40%)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gain),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ultra-Luxurious Slide To Confirm Swap
            SlideToConfirm(
              label: 'Slide to Confirm Swap',
              isLoading: _isSwapping,
              onConfirmed: _executeSwap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInputBox({
    required String title,
    required CryptoAsset asset,
    required bool isEditable,
    TextEditingController? controller,
    String? displayValue,
    required VoidCallback onAssetTap,
    bool showPercentages = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(
                'Bal: ${asset.userHolding.toStringAsFixed(2)} ${asset.symbol}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Token selector pill
              GestureDetector(
                onTap: onAssetTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(asset.iconData ?? Icons.circle, color: asset.brandColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        asset.symbol,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Amount input / display
              Expanded(
                child: isEditable
                    ? TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.0',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                        ),
                        onChanged: (_) => setState(() {}),
                      )
                    : Text(
                        displayValue ?? '0.0',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showPercentages)
                Row(
                  children: [0.25, 0.50, 0.75, 1.0].map((f) {
                    final label = f == 1.0 ? 'MAX' : '${(f * 100).toInt()}%';
                    return GestureDetector(
                      onTap: () => _setPercentAmount(f),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                const SizedBox(),
              Text(
                currency.format(
                  isEditable ? _payAmount * asset.currentPrice : _receiveAmount * asset.currentPrice,
                ),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectToken({required bool isPay}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Token',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.assets.length,
                  itemBuilder: (ctx, i) {
                    final a = widget.assets[i];
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            if (isPay) {
                              _payAsset = a;
                            } else {
                              _receiveAsset = a;
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: a.brandColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(a.iconData ?? Icons.circle, color: a.brandColor, size: 22),
                        ),
                        title: Text(a.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: Text(a.symbol, style: const TextStyle(color: AppColors.textSecondary)),
                        trailing: Text(
                          currency.format(a.currentPrice),
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
