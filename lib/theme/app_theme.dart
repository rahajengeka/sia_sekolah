import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand colors: Enterprise Academic Blue & Slate
  static const Color primary = Color(0xFF1E3A8A); // Deep Navy Blue
  static const Color primaryLight = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF172554); // Dark Navy
  static const Color accent = Color(0xFF0284C7); // Sky Blue

  // Neutrals - Light Mode
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  // Neutrals - Dark Mode
  static const Color bgDark = Color(0xFF0B0F19); // Deep Slate
  static const Color surfaceDark = Color(0xFF111827); // Gray 900
  static const Color cardDark = Color(0xFF1E293B); // Slate 800
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate 300
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500

  // Status & Feedback
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF2563EB); // Blue 600
  static const Color infoBg = Color(0xFFEFF6FF);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMutedLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimaryLight,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textMutedLight,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: outlinedButtonFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.borderLight, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMutedDark,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimaryDark,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textMutedDark,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: outlinedButtonFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.borderDark, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // --- Helper UI Decorations for Consistency ---
  static BoxDecoration cardBox(BuildContext context, {Color? customColor, Color? customBorder}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: customColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: customBorder ?? (isDark ? AppColors.borderDark : AppColors.borderLight),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration badgeBox({required Color color, double radius = 8}) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withOpacity(0.25), width: 1),
    );
  }

  // Helper for OutlinedButton style
  static ButtonStyle outlinedButtonFrom({
    required Color foregroundColor,
    required BorderSide side,
    required OutlinedBorder shape,
    required TextStyle textStyle,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      side: side,
      shape: shape,
      textStyle: textStyle,
      minimumSize: const Size.fromHeight(48),
    );
  }
}
