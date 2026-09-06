import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';

class SendSheet extends StatefulWidget {
  final List<CryptoAsset> assets;
  final CryptoAsset? initialAsset;

  const SendSheet({
    super.key,
    required this.assets,
    this.initialAsset,
  });

  @override
  State<SendSheet> createState() => _SendSheetState();
}

class _SendSheetState extends State<SendSheet> {
  late CryptoAsset _selectedAsset;
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(text: '0.5');
  int _selectedSpeedIndex = 1; // 0: Eco, 1: Standard, 2: Instant
  bool _isSending = false;

  final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _selectedAsset = widget.initialAsset ??
        widget.assets.firstWhere((a) => a.symbol == 'SOL', orElse: () => widget.assets[0]);
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0.0;

  void _pasteAddress() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
      setState(() => _recipientController.text = clipboardData.text!);
    } else {
      // Demo simulated address
      setState(() => _recipientController.text = '0x88F2...9C3A');
    }
  }

  void _handleSend() async {
    if (_amount <= 0) return;
    if (_recipientController.text.isEmpty) {
      _recipientController.text = '0x88F27D11A39B9C3A';
    }

    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    setState(() => _isSending = false);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF102A24),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.gain),
        ),
        content: Row(
          children: [
            const Icon(Icons.arrow_upward_rounded, color: AppColors.gain, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transfer Broadcasted!',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  Text(
                    'Sent ${_amount.toStringAsFixed(3)} ${_selectedAsset.symbol} to ${_recipientController.text}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.border, width: 1.2),
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
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Send Crypto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryLight),
                onPressed: () {
                  setState(() => _recipientController.text = '0x88F27D11A39B9C3A');
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Recipient Address Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _recipientController,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Recipient address or ENS / domain',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pasteAddress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PASTE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Asset & Amount Card
          Container(
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
                    const Text('Amount', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Row(
                      children: [
                        Text(
                          'Available: ${_selectedAsset.userHolding.toStringAsFixed(2)} ${_selectedAsset.symbol}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (_selectedAsset.userHolding > 0) {
                              _amountController.text = _selectedAsset.userHolding.toString();
                              setState(() {});
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'MAX',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Token dropdown
                    GestureDetector(
                      onTap: _selectAsset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(_selectedAsset.iconData ?? Icons.circle,
                                color: _selectedAsset.brandColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _selectedAsset.symbol,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecondary, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.0',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    currency.format(_amount * _selectedAsset.currentPrice),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Network Speed & Gas Fee
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Network Speed & Gas',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildSpeedChip(0, 'Eco', '10 Gwei', '~\$0.95'),
                    const SizedBox(width: 8),
                    _buildSpeedChip(1, 'Standard', '14 Gwei', '~\$1.45'),
                    const SizedBox(width: 8),
                    _buildSpeedChip(2, 'Instant', '22 Gwei', '~\$2.20'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Send Action Button
          GestureDetector(
            onTap: _isSending ? null : _handleSend,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Send Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedChip(int index, String label, String gwei, String fiat) {
    final isSelected = _selectedSpeedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSpeedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fiat,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAsset() {
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
                'Select Asset to Send',
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
                          setState(() => _selectedAsset = a);
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
                        subtitle: Text('${a.userHolding} ${a.symbol}',
                            style: const TextStyle(color: AppColors.textSecondary)),
                        trailing: Text(
                          currency.format(a.holdingFiatValue),
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
