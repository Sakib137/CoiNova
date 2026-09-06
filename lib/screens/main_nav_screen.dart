import 'package:flutter/material.dart';
import '../data/mock_crypto_data.dart';
import '../models/crypto_asset.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'markets_screen.dart';
import 'portfolio_screen.dart';
import 'settings_screen.dart';
import 'swap_sheet.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  final List<CryptoAsset> _assets = MockCryptoData.getAssets();

  final List<Widget> _pages = const [
    HomeScreen(),
    MarketsScreen(),
    PortfolioScreen(),
    SettingsScreen(),
  ];

  void _openCenterSwap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SwapSheet(assets: _assets),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Indexed Stack to preserve state across tabs
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // Floating Glass Bottom Navigation Dock
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xE6101524),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tab 0: Home
                  _buildNavItem(
                    index: 0,
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Home',
                  ),

                  // Tab 1: Markets
                  _buildNavItem(
                    index: 1,
                    icon: Icons.show_chart_rounded,
                    label: 'Markets',
                  ),

                  // Center Floating Neon Action Button (Instant Swap)
                  GestureDetector(
                    onTap: _openCenterSwap,
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                  // Tab 2: Portfolio
                  _buildNavItem(
                    index: 2,
                    icon: Icons.pie_chart_rounded,
                    label: 'Portfolio',
                  ),

                  // Tab 3: Settings
                  _buildNavItem(
                    index: 3,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
