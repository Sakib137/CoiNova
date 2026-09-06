import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF080A10);
  static const Color surface = Color(0xFF0E121E);
  static const Color card = Color(0xFF141A29);
  static const Color cardElevated = Color(0xFF1C2436);
  static const Color cardGlass = Color(0x80182033);

  // Borders & Dividers
  static const Color border = Color(0x1AFFFFFF);
  static const Color borderHighlight = Color(0x336366F1);
  static const Color divider = Color(0x0FFFFFFF);

  // Accents & Gradients
  static const Color primary = Color(0xFF6366F1); // Neon Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryPurple = Color(0xFF8B5CF6); // Electric Purple
  static const Color cyan = Color(0xFF06B6D4); // Cyber Cyan
  static const Color gold = Color(0xFFF59E0B); // Amber Gold
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color bnbYellow = Color(0xFFF0B90B);

  // Market Sentiment
  static const Color gain = Color(0xFF10B981); // Emerald Green
  static const Color gainSoft = Color(0x1A10B981);
  static const Color loss = Color(0xFFF43F5E); // Crimson Rose
  static const Color lossSoft = Color(0x1AF43F5E);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanPurpleGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ethGradient = LinearGradient(
    colors: [Color(0xFF627EEA), Color(0xFF3B5998)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient solanaGradient = LinearGradient(
    colors: [Color(0xFF9945FF), Color(0xFF14F195)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    colors: [Color(0x28232D42), Color(0x14182033)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
