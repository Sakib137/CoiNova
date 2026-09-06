import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_crypto_data.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';
import '../widgets/ambient_aurora_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/interactive_chart.dart';
import 'send_sheet.dart';
import 'swap_sheet.dart';

class AssetDetailScreen extends StatefulWidget {
  final CryptoAsset asset;
  final List<CryptoAsset> allAssets;

  const AssetDetailScreen({
    super.key,
    required this.asset,
    required this.allAssets,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  late CryptoAsset _asset;
  String _activeTimeframe = '1D';
  late List<double> _chartPoints;
  double? _scrubbedPrice;
  bool _isFavorite = false;
  bool _hasAlert = false;

  final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final compactCurrency = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1);

  @override
  void initState() {
    super.initState();
    _asset = widget.asset;
    _chartPoints = MockCryptoData.generateTimeframePoints(_asset.currentPrice, _activeTimeframe);
  }

  void _onTimeframeChanged(String tf) {
    setState(() {
      _activeTimeframe = tf;
      _chartPoints = MockCryptoData.generateTimeframePoints(_asset.currentPrice, tf);
    });
  }

  void _openSwapModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SwapSheet(
        assets: widget.allAssets,
        initialPayAsset: _asset,
      ),
    );
  }

  void _openSendModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SendSheet(
        assets: widget.allAssets,
        initialAsset: _asset,
      ),
    );
  }

  void _toggleAlert() {
    setState(() => _hasAlert = !_hasAlert);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: _hasAlert ? AppColors.gold : AppColors.border),
        ),
        content: Row(
          children: [
            Icon(
              _hasAlert ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
              color: _hasAlert ? AppColors.gold : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _hasAlert
                  ? 'Price Alert set at ${currency.format(_asset.currentPrice * 1.05)} (+5%)'
                  : 'Price Alert removed for ${_asset.symbol}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPrice = _scrubbedPrice ?? _asset.currentPrice;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientAuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _asset.brandColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: _asset.brandColor.withOpacity(0.5)),
                          ),
                          child: Icon(_asset.iconData ?? Icons.circle, color: _asset.brandColor, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _asset.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            Text(
                              '${_asset.symbol} • Rank #${widget.allAssets.indexOf(_asset) + 1}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _hasAlert ? Icons.notifications_active_rounded : Icons.notifications_outlined,
                            color: _hasAlert ? AppColors.gold : AppColors.textSecondary,
                            size: 22,
                          ),
                          onPressed: _toggleAlert,
                        ),
                        IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: _isFavorite ? AppColors.gold : AppColors.textSecondary,
                            size: 22,
                          ),
                          onPressed: () => setState(() => _isFavorite = !_isFavorite),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Live Price Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currency.format(displayPrice),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _asset.isPositive ? AppColors.gainSoft : AppColors.lossSoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _asset.isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                        size: 14,
                                        color: _asset.isPositive ? AppColors.gain : AppColors.loss,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_asset.isPositive ? '+' : ''}${_asset.change24h.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _asset.isPositive ? AppColors.gain : AppColors.loss,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _scrubbedPrice != null ? 'Scrubbing timeframe' : 'Past 24 Hours',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Interactive Glowing Bezier Spline Chart
                      InteractiveChart(
                        data: _chartPoints,
                        lineColor: _asset.brandColor,
                        activeTimeframe: _activeTimeframe,
                        onTimeframeChanged: _onTimeframeChanged,
                        onPriceScrubbed: (p) => setState(() => _scrubbedPrice = p),
                      ),

                      const SizedBox(height: 20),

                      // Order Book Pressure Bar (Buy vs Sell)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Order Flow Pressure',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'High Liquidity Pool',
                                    style: TextStyle(fontSize: 11, color: AppColors.cyan, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Bids (Buy): 64%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gain)),
                                  Text('Asks (Sell): 36%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.loss)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 64,
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [AppColors.gain.withOpacity(0.6), AppColors.gain],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      flex: 36,
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [AppColors.loss, AppColors.loss.withOpacity(0.6)],
                                          ),
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

                      const SizedBox(height: 18),

                      // "In Your Wallet" Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF161C2C),
                              Color(0xFF0F1422),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet_outlined,
                                        size: 16, color: _asset.brandColor),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'In Your Wallet',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Active Holdings',
                                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Balance',
                                        style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_asset.userHolding} ${_asset.symbol}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Total Value',
                                        style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    const SizedBox(height: 4),
                                    Text(
                                      currency.format(_asset.holdingFiatValue),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Market Statistics Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Market Statistics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: [
                                  _buildStatRow('Market Cap', compactCurrency.format(_asset.marketCap)),
                                  const Divider(color: AppColors.divider, height: 20),
                                  _buildStatRow('24h Volume', compactCurrency.format(_asset.volume24h)),
                                  const Divider(color: AppColors.divider, height: 20),
                                  _buildStatRow('24h High', currency.format(_asset.high24h)),
                                  const Divider(color: AppColors.divider, height: 20),
                                  _buildStatRow('24h Low', currency.format(_asset.low24h)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Floating Action Bar: Swap & Send
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    // Swap Button (Translucent dark/glass pill)
                    Expanded(
                      child: GestureDetector(
                        onTap: _openSwapModal,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Swap',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Send COIN Button (Glowing primary gradient)
                    Expanded(
                      child: GestureDetector(
                        onTap: _openSendModal,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_outward_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Send ${_asset.symbol}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
