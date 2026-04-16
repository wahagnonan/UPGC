import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A1A1A);
  static const Color primaryContainer = Color(0xFFE8E8E8);
  static const Color secondary = Color(0xFF2D2D2D);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceContainerLow = Color(0xFFF0F0F0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color outlineVariant = Color(0xFFE0E0E0);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outlineVariant,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: AppColors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryContainer,
        labelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.normal,
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.onSurfaceVariant);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.bold,
          fontSize: 56,
          color: AppColors.onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: AppColors.onSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.normal,
          fontSize: 16,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: AppColors.onSurface,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.normal,
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: AppColors.onSurface,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w500,
          fontSize: 11,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE0E0E0),
        onPrimary: Color(0xFF1A1A1A),
        primaryContainer: Color(0xFF2D2D2D),
        surface: AppColors.backgroundDark,
        surfaceContainerLow: Color(0xFF1E1E1E),
        surfaceContainerLowest: Color(0xFF252525),
        onSurface: AppColors.onSurfaceDark,
        onSurfaceVariant: Color(0xFF9E9E9E),
        outline: Color(0xFF424242),
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class CoursColors {
  static Color getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'CM':
        return const Color(0xFF2563EB);
      case 'TD':
        return const Color(0xFF16A34A);
      case 'TP':
        return const Color(0xFFEA580C);
      case 'EXAMEN':
      case 'EXAM':
        return const Color(0xFFDC2626);
      case 'DEVOIR':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static Color getTypeContainerColor(String type) {
    switch (type.toUpperCase()) {
      case 'CM':
        return const Color(0xFFDBEAFE);
      case 'TD':
        return const Color(0xFFDCFCE7);
      case 'TP':
        return const Color(0xFFFEF3C7);
      case 'EXAMEN':
      case 'EXAM':
        return const Color(0xFFFEE2E2);
      case 'DEVOIR':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  static Color getTypeTextColor(String type) {
    switch (type.toUpperCase()) {
      case 'CM':
        return const Color(0xFF1D4ED8);
      case 'TD':
        return const Color(0xFF15803D);
      case 'TP':
        return const Color(0xFFC2410C);
      case 'EXAMEN':
      case 'EXAM':
        return const Color(0xFFB91C1C);
      case 'DEVOIR':
        return const Color(0xFF7E22CE);
      default:
        return const Color(0xFF4B5563);
    }
  }
}
