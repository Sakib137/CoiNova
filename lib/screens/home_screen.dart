import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_crypto_data.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';
import '../widgets/action_button.dart';
import '../widgets/ambient_aurora_background.dart';
import '../widgets/bento_asset_card.dart';
import '../widgets/glass_container.dart';
import '../widgets/sparkline_chart.dart';
import '../widgets/token_tile.dart';
import 'asset_detail_screen.dart';
import 'receive_sheet.dart';
import 'send_sheet.dart';
import 'swap_sheet.dart';
import '../widgets/nova_copilot_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<CryptoAsset> _assets;
  bool _isBalanceHidden = false;
  AssetCategory _selectedCategory = AssetCategory.all;
  Timer? _liveTickerTimer;
  String _selectedNetwork = 'Ethereum Mainnet';

  final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _assets = MockCryptoData.getAssets();

    // Subtle live ticker simulation: slightly adjusts prices every few seconds to make the app feel alive!
    _liveTickerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        final randomIndex = timer.tick % _assets.length;
        final asset = _assets[randomIndex];
        final delta = (timer.tick.isEven ? 1 : -1) * (asset.currentPrice * 0.0015);
        final updatedPrice = (asset.currentPrice + delta);
        final updatedChange = asset.change24h + (timer.tick.isEven ? 0.05 : -0.05);

        final updatedSparkline = List<double>.from(asset.sparkline);
        updatedSparkline[updatedSparkline.length - 1] = updatedPrice;

        _assets[randomIndex] = asset.copyWithPrice(
          newPrice: updatedPrice,
          newChange: updatedChange,
          newSparkline: updatedSparkline,
        );
      });
    });
  }

  @override
  void dispose() {
    _liveTickerTimer?.cancel();
    super.dispose();
  }

  double get _totalBalance => MockCryptoData.getTotalPortfolioBalance(_assets);

  List<CryptoAsset> get _filteredAssets {
    if (_selectedCategory == AssetCategory.all) return _assets;
    return _assets.where((a) => a.category == _selectedCategory).toList();
  }

  void _openSendModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SendSheet(assets: _assets),
    );
  }

  void _openReceiveModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const ReceiveSheet(),
    );
  }

  void _openSwapModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SwapSheet(assets: _assets),
    );
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

  void _showNetworkSelector() {
    final networks = [
      {'name': 'Ethereum Mainnet', 'icon': Icons.diamond_outlined, 'gas': '14 Gwei'},
      {'name': 'Solana Network', 'icon': Icons.flash_on_rounded, 'gas': '<0.001 SOL'},
      {'name': 'Arbitrum One', 'icon': Icons.layers_outlined, 'gas': '0.1 Gwei'},
      {'name': 'Base Network', 'icon': Icons.circle_outlined, 'gas': '0.05 Gwei'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Active Network',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 16),
              ...networks.map((net) {
                final isSelected = _selectedNetwork == net['name'];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      setState(() => _selectedNetwork = net['name'] as String);
                      Navigator.pop(ctx);
                    },
                    leading: Icon(net['icon'] as IconData, color: isSelected ? AppColors.cyan : Colors.white),
                    title: Text(net['name'] as String,
                        style: TextStyle(
                            color: isSelected ? AppColors.cyan : Colors.white,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                    trailing: Text(net['gas'] as String,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ethAsset = _assets.firstWhere((a) => a.symbol == 'ETH', orElse: () => _assets[1]);
    final solAsset = _assets.firstWhere((a) => a.symbol == 'SOL', orElse: () => _assets[2]);

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
              // Top Bar: Avatar, Wallet Pill, Notifications
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar with status
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                              ),
                              child: const Center(
                                child: Text(
                                  '⚡️',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.gain,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.background, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Alex Vance',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              MockCryptoData.ensName,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Network & Wallet Pill
                    GestureDetector(
                      onTap: _showNetworkSelector,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.cyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              MockCryptoData.shortAddress,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecondary, size: 16),
                          ],
                        ),
                      ),
                    ),

                    // Notification Bell with badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Luxury Obsidian Vault Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(22),
                  child: Stack(
                    children: [
                      // Embedded subtle wavy portfolio curve
                      Positioned(
                        right: -10,
                        bottom: -10,
                        width: 140,
                        height: 60,
                        child: Opacity(
                          opacity: 0.35,
                          child: SparklineChart(
                            data: const [132000, 136000, 139000, 137500, 142000, 148000, 154820],
                            isPositive: true,
                            width: 140,
                            height: 60,
                            showFill: true,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.verified_rounded, size: 12, color: AppColors.primaryLight),
                                    SizedBox(width: 5),
                                    Text(
                                      'OBSIDIAN VAULT · VIP',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isBalanceHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Total Net Worth',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isBalanceHidden ? '\$ • • • • • •' : currency.format(_totalBalance),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gainSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.gain),
                                    SizedBox(width: 4),
                                    Text(
                                      '+16.55%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.gain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '(+\$21,940.10) this week',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Action Buttons Row (Send, Receive, Buy, Swap)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionButton(
                      icon: Icons.north_east_rounded,
                      label: 'Send',
                      onTap: _openSendModal,
                    ),
                    ActionButton(
                      icon: Icons.south_west_rounded,
                      label: 'Receive',
                      onTap: _openReceiveModal,
                    ),
                    ActionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Buy',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fiat On-Ramp via Apple Pay / Card ready!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    ActionButton(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Swap',
                      isPrimary: true,
                      onTap: _openSwapModal,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nova AI Intelligence Pill / Card (Interactive)
              GestureDetector(
                onTap: () => NovaCopilotSheet.show(context),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1638), Color(0xFF141926)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFC084FC), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Nova Copilot · DeFi Insight',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFC084FC),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Staking opportunity: +7.4% APY detected on Solana with zero lockup.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFC084FC)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bento Highlight Assets (Ethereum & Solana)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Featured Assets',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Live 24h',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    BentoAssetCard(
                      asset: ethAsset,
                      onTap: () => _navigateToAssetDetail(ethAsset),
                      cardGradient: const LinearGradient(
                        colors: [Color(0xFF3B4371), Color(0xFF1D2235)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    const SizedBox(width: 14),
                    BentoAssetCard(
                      asset: solAsset,
                      onTap: () => _navigateToAssetDetail(solAsset),
                      cardGradient: const LinearGradient(
                        colors: [Color(0xFF285346), Color(0xFF132822)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    const SizedBox(width: 14),
                    BentoAssetCard(
                      asset: _assets[0], // Bitcoin
                      onTap: () => _navigateToAssetDetail(_assets[0]),
                      cardGradient: const LinearGradient(
                        colors: [Color(0xFF5E4319), Color(0xFF241B0D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Trending Tokens & Category Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Trending Market',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildCategoryChip('All Assets', AssetCategory.all),
                    _buildCategoryChip('Layer 1', AssetCategory.layer1),
                    _buildCategoryChip('DeFi', AssetCategory.defi),
                    _buildCategoryChip('AI Tokens', AssetCategory.ai),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Token List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredAssets.length,
                  itemBuilder: (context, index) {
                    final asset = _filteredAssets[index];
                    return TokenTile(
                      asset: asset,
                      showHolding: true,
                      onTap: () => _navigateToAssetDetail(asset),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),);
  }

  Widget _buildCategoryChip(String label, AssetCategory category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
