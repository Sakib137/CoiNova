import 'package:flutter/material.dart';
import '../data/mock_crypto_data.dart';
import '../theme/app_colors.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricsEnabled = true;
  bool _aiCopilotEnabled = true;
  bool _gasAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: const Text(
                  'Settings & Security',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              // Profile Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      ),
                      child: const Center(
                        child: Text('⚡️', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Alex Vance',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            MockCryptoData.ensName,
                            style: TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text(
                            MockCryptoData.shortAddress,
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gainSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Verified',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gain),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nova AI Intelligence Settings Section
              _buildSectionHeader('NOVA AI INTELLIGENCE'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.auto_awesome_rounded,
                        iconColor: const Color(0xFFC084FC),
                        title: 'Autonomous Portfolio Copilot',
                        subtitle: 'Get AI alerts on staking yields & risk exposure',
                        value: _aiCopilotEnabled,
                        onChanged: (val) => setState(() => _aiCopilotEnabled = val),
                      ),
                      const Divider(color: AppColors.divider, height: 1),
                      _buildSwitchTile(
                        icon: Icons.local_gas_station_rounded,
                        iconColor: AppColors.cyan,
                        title: 'Optimal Gas Sentinel',
                        subtitle: 'Execute transactions when gas drops below target',
                        value: _gasAlerts,
                        onChanged: (val) => setState(() => _gasAlerts = val),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Security Section
              _buildSectionHeader('SECURITY & VAULT'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.fingerprint_rounded,
                        iconColor: AppColors.primaryLight,
                        title: 'Biometric Authentication',
                        subtitle: 'Require Face ID / Touch ID for transfers',
                        value: _biometricsEnabled,
                        onChanged: (val) => setState(() => _biometricsEnabled = val),
                      ),
                      const Divider(color: AppColors.divider, height: 1),
                      _buildNavigationTile(
                        icon: Icons.key_rounded,
                        iconColor: AppColors.gold,
                        title: 'Recovery Seed Phrase',
                        subtitle: '12-word backup vault verified',
                      ),
                      const Divider(color: AppColors.divider, height: 1),
                      _buildNavigationTile(
                        icon: Icons.lock_outline_rounded,
                        iconColor: AppColors.textSecondary,
                        title: 'App Auto-Lock',
                        subtitle: 'Immediately on exit',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionHeader('PREFERENCES & APP'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _buildNavigationTile(
                        icon: Icons.language_rounded,
                        iconColor: AppColors.cyan,
                        title: 'Primary Currency',
                        subtitle: 'USD (\$)',
                      ),
                      const Divider(color: AppColors.divider, height: 1),
                      _buildNavigationTile(
                        icon: Icons.hub_rounded,
                        iconColor: const Color(0xFF818CF8),
                        title: 'Connected Web3 DApps',
                        subtitle: '3 Active Sessions (Uniswap, OpenSea, Curve)',
                      ),
                      const Divider(color: AppColors.divider, height: 1),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const OnboardingScreen()),
                            );
                          },
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.rocket_launch_rounded, color: AppColors.primaryLight, size: 18),
                          ),
                          title: const Text('Replay Welcome Experience', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Version info
              Center(
                child: Text(
                  'Coinova v2.4.0 (Build 2026) · Non-Custodial Core',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: () {},
      ),
    );
  }
}
