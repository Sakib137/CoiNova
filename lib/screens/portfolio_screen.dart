import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_crypto_data.dart';
import '../models/crypto_asset.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../widgets/ambient_aurora_background.dart';
import '../widgets/portfolio_donut_chart.dart';
import '../widgets/token_tile.dart';
import 'asset_detail_screen.dart';
import 'receive_sheet.dart';
import 'send_sheet.dart';
import 'swap_sheet.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late List<CryptoAsset> _assets;
  late List<TransactionModel> _transactions;
  int _selectedTab = 0; // 0: Assets, 1: History
  String _selectedCurrency = 'USD';

  final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _assets = MockCryptoData.getAssets();
    _transactions = MockCryptoData.getTransactions();
  }

  double get _totalPortfolioValue => MockCryptoData.getTotalPortfolioBalance(_assets);

  List<CryptoAsset> get _holdingAssets =>
      _assets.where((a) => a.userHolding > 0).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientAuroraBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header with Currency Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Portfolio',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          dropdownColor: AppColors.surface,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16, color: AppColors.textSecondary),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          items: ['USD', 'EUR', 'GBP', 'BTC'].map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCurrency = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Wallet Card (Reference design matching Screen 5)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF242C44), Color(0xFF131828)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.shield_rounded, size: 16, color: AppColors.primaryLight),
                            SizedBox(width: 6),
                            Text(
                              'MAIN VAULT · WALLET 1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.gainSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '+24.8% All-Time',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gain),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currency.format(_totalPortfolioValue),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Quick Action Pills Inside Wallet Card (Receive, Buy, Send)
                    Row(
                      children: [
                        Expanded(
                          child: _buildWalletCardAction(
                            icon: Icons.south_west_rounded,
                            label: 'Receive',
                            onTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) => const ReceiveSheet(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildWalletCardAction(
                            icon: Icons.add_rounded,
                            label: 'Buy',
                            isHighlighted: true,
                            onTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) => SwapSheet(assets: _assets),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildWalletCardAction(
                            icon: Icons.north_east_rounded,
                            label: 'Send',
                            onTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) => SendSheet(assets: _assets),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Asset Allocation Visual Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Asset Allocation',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Text('Diversified', style: TextStyle(fontSize: 12, color: AppColors.cyan)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Interactive Glowing Donut Chart
                    Center(
                      child: PortfolioDonutChart(
                        assets: _holdingAssets,
                        totalValue: _totalPortfolioValue,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Segmented color bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 8,
                        child: Row(
                          children: _holdingAssets.map((asset) {
                            final percent = (asset.holdingFiatValue / _totalPortfolioValue).clamp(0.02, 1.0);
                            return Expanded(
                              flex: (percent * 100).round(),
                              child: Container(color: asset.brandColor),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Legend chips
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: _holdingAssets.take(4).map((asset) {
                        final percent = ((asset.holdingFiatValue / _totalPortfolioValue) * 100).toStringAsFixed(1);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: asset.brandColor, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('${asset.symbol} $percent%', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab Selector: Holdings vs History
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Holdings (${_holdingAssets.length})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                color: _selectedTab == 0 ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Activity History',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                color: _selectedTab == 1 ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tab Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _selectedTab == 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _holdingAssets.length,
                        itemBuilder: (context, index) {
                          final asset = _holdingAssets[index];
                          return TokenTile(
                            asset: asset,
                            showHolding: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => AssetDetailScreen(asset: asset, allAssets: _assets),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
                          return _buildTransactionTile(tx);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    ),);
  }

  Widget _buildWalletCardAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primary : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted ? AppColors.primaryLight : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel tx) {
    IconData icon;
    Color iconColor;

    switch (tx.type) {
      case TransactionType.send:
        icon = Icons.north_east_rounded;
        iconColor = AppColors.loss;
        break;
      case TransactionType.receive:
        icon = Icons.south_west_rounded;
        iconColor = AppColors.gain;
        break;
      case TransactionType.swap:
        icon = Icons.swap_horiz_rounded;
        iconColor = AppColors.primaryLight;
        break;
      case TransactionType.stake:
        icon = Icons.lock_clock_rounded;
        iconColor = AppColors.gold;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tx.typeLabel} ${tx.assetSymbol}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.recipientOrSender} · ${DateFormat('MMM d, h:mm a').format(tx.timestamp)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${tx.isCredit ? '+' : '-'}${tx.amount} ${tx.assetSymbol.split(' ').first}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: tx.isCredit ? AppColors.gain : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currency.format(tx.fiatAmount),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
