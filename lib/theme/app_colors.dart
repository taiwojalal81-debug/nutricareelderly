// lib/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Premium Primary Palette - Soft Mint & Emerald (Health/Nutrition)
  static const Color primary = Color(0xFF10b981); // Vibrant soft emerald
  static const Color primaryLight = Color(0xFF34d399); // Lighter mint
  static const Color primaryDark = Color(0xFF059669); // Deeper emerald
  static const Color primaryContainer = Color(0xFFd1fae5); // Very soft mint background

  // Premium Secondary Palette - Calming Slate Blue (Trust/Stability)
  static const Color secondary = Color(0xFF3b82f6); // Soft blue
  static const Color secondaryLight = Color(0xFF60a5fa);
  static const Color secondaryContainer = Color(0xFFdbeafe); 

  // Semantic Colors (High contrast but soft)
  static const Color success = Color(0xFF10b981);
  static const Color warning = Color(0xFFf59e0b); // Warm amber
  static const Color error = Color(0xFFef4444); // Soft red
  static const Color info = Color(0xFF3b82f6);

  // Neutral Colors (Softer than pure black/white)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Text Colors (Using slate grays for readability without harshness)
  static const Color textPrimary = Color(0xFF1e293b); // Slate 800 - Very readable
  static const Color textSecondary = Color(0xFF64748b); // Slate 500
  static const Color textHint = Color(0xFF94a3b8); // Slate 400
  static const Color textDisabled = Color(0xFFcbd5e1); // Slate 300

  // Backgrounds (Warm off-whites for eye comfort)
  static const Color background = Color(0xFFf8fafc); // Slate 50
  static const Color scaffoldBackground = Color(0xFFf1f5f9); // Slate 100 - beautiful off-white

  // Overlay, Shadows & Dividers
  static const Color divider = Color(0xFFe2e8f0); // Slate 200
  static const Color overlay = Color(0x1F000000); // 12% black overlay
  
  // Soft UI Specific
  static const Color softShadow = Color(0x0A0F172A); // Very soft bluish-black shadow
  static const Color glassmorphism = Color(0xB3FFFFFF); // 70% white for frosted glass
  
  // Legacy aliases to prevent compilation errors in un-migrated screens
  static const Color grey = Color(0xFF94a3b8);
  static const Color lightGrey = Color(0xFFcbd5e1);
  static const Color veryLightGrey = Color(0xFFf1f5f9);
  static const Color dark = Color(0xFF1e293b);
  static const Color darkGrey = Color(0xFF475569);
  static const Color surface = Color(0xFFffffff);
  static const Color transparent = Colors.transparent;
}
