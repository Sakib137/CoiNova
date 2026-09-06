import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_crypto_data.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';
import '../widgets/ambient_aurora_background.dart';
import '../widgets/fear_greed_meter.dart';
import '../widgets/glass_container.dart';
import '../widgets/sparkline_chart.dart';
import '../widgets/token_tile.dart';
import 'asset_detail_screen.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  late List<CryptoAsset> _assets;
  String _searchQuery = '';
  String _activeFilter = 'All';

  final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _assets = MockCryptoData.getAssets();
  }

  List<CryptoAsset> get _displayedAssets {
    var list = _assets;

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      list = list.where((a) =>
          a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.symbol.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply Category Filter
    if (_activeFilter == 'Gainers') {
      final gainers = list.where((a) => a.isPositive).toList();
      gainers.sort((a, b) => b.change24h.compareTo(a.change24h));
      return gainers;
    } else if (_activeFilter == 'Losers') {
      final losers = list.where((a) => !a.isPositive).toList();
      losers.sort((a, b) => a.change24h.compareTo(b.change24h));
      return losers;
    } else if (_activeFilter == 'DeFi') {
      return list.where((a) => a.category == AssetCategory.defi).toList();
    } else if (_activeFilter == 'AI Tokens') {
      return list.where((a) => a.category == AssetCategory.ai).toList();
    }

    return list;
  }

  List<CryptoAsset> get _trendingAssets {
    // Pick highest movers
    final sorted = List<CryptoAsset>.from(_assets);
    sorted.sort((a, b) => b.change24h.abs().compareTo(a.change24h.abs()));
    return sorted.take(4).toList();
  }

  void _navigateToAssetDetail(CryptoAsset asset) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AssetDetailScreen(
          asset: asset,
          allAssets: _assets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientAuroraBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 115),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Live Markets',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Real-time global crypto intelligence',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.cardElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.wifi_tethering_rounded, size: 14, color: AppColors.gain),
                            SizedBox(width: 5),
                            Text(
                              'LIVE',
                              style: TextStyle(fontSize: 11, color: AppColors.gain, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Fear & Greed Sentiment Radar
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: FearGreedMeter(score: 78, sentiment: 'Extreme Greed'),
                ),

                const SizedBox(height: 12),

                // Global Stats Banner in GlassContainer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    borderRadius: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlobalStat('Global Cap', '\$3.14T', '+2.4%', true),
                        Container(width: 1, height: 32, color: AppColors.divider),
                        _buildGlobalStat('24h Volume', '\$98.5B', '-4.1%', false),
                        Container(width: 1, height: 32, color: AppColors.divider),
                        _buildGlobalStat('BTC Dominance', '56.2%', '+0.8%', true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Trending Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.local_fire_department_rounded, size: 18, color: AppColors.loss),
                          SizedBox(width: 6),
                          Text(
                            'High Velocity Movers',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '24h Volume Spike',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Horizontal Trending Movers Horizon Slider
                SizedBox(
                  height: 106,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _trendingAssets.length,
                    itemBuilder: (context, index) {
                      final asset = _trendingAssets[index];
                      return _buildTrendingCard(asset);
                    },
                  ),
                ),

                const SizedBox(height: 18),

                // Search Bar in GlassContainer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    borderRadius: 18,
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.cyan, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search token, symbol, or contract...',
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _searchQuery = ''),
                            child: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: ['All', 'Gainers', 'Losers', 'DeFi', 'AI Tokens'].map((filter) {
                      final isSelected = _activeFilter == filter;
                      return GestureDetector(
                        onTap: () => setState(() => _activeFilter = filter),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.primaryGradient : null,
                            color: isSelected ? null : AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primary.withOpacity(0.5) : AppColors.border,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // Asset List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _displayedAssets.length,
                    itemBuilder: (context, index) {
                      final asset = _displayedAssets[index];
                      return TokenTile(
                        asset: asset,
                        showHolding: false,
                        onTap: () => _navigateToAssetDetail(asset),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingCard(CryptoAsset asset) {
    return GestureDetector(
      onTap: () => _navigateToAssetDetail(asset),
      child: Container(
        width: 154,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: asset.brandColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: asset.brandColor.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(asset.iconData ?? Icons.circle, color: asset.brandColor, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      asset.symbol,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  asset.change24hFormatted,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: asset.isPositive ? AppColors.gain : AppColors.loss,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(asset.currentPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 44,
                  height: 22,
                  child: SparklineChart(
                    data: asset.sparkline,
                    isPositive: asset.isPositive,
                    width: 44,
                    height: 22,
                    showFill: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStat(String label, String value, String change, bool isPositive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 2),
        Text(
          change,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isPositive ? AppColors.gain : AppColors.loss,
          ),
        ),
      ],
    );
  }
}
