import 'package:flutter/material.dart';

class AppTheme {
  // Light Mode Color Palette
  static const Color primary = Color(0xFF3B82F6); // Light Blue
  static const Color secondary = Color(0xFF0EA5E9); // Sky Blue
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color surface = Color(0xFFF8FAFC); // Very Light Gray
  static const Color textPrimary = Color(0xFF1E293B); // Dark Slate
  static const Color textLight = Color(0xFF64748B); // Slate

  // Dark Mode Color Palette
  static const Color darkBackground = Color(0xFF0F172A); // Dark Slate
  static const Color darkSurface = Color(0xFF1E293B); // Slate
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Light
  static const Color darkTextLight = Color(0xFF94A3B8); // Gray

  // Priority Colors (same for both themes)
  static const Color urgent = Color(0xFFef4444); // Red
  static const Color medium = Color(0xFFf59e0b); // Orange
  static const Color low = Color(0xFF10b981); // Green

  // Status Colors (same for both themes)
  static const Color statusTodo = Color(0xFF64748b); // Gray
  static const Color statusInProgress = Color(0xFF3b82f6); // Blue
  static const Color statusDone = Color(0xFF10b981); // Green

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF5252), // Salmon/Red accent from reference
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0, // Using manual shadows for better control
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textLight),
      ),
    );
  }

  // Dark Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF5252),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: darkTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: darkTextPrimary),
        bodySmall: TextStyle(fontSize: 12, color: darkTextLight),
      ),
    );
  }

  // Helper methods for priority and status colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return urgent;
      case 'medium':
        return medium;
      case 'low':
        return low;
      default:
        return textLight;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return statusTodo;
      case 'in-progress':
        return statusInProgress;
      case 'done':
        return statusDone;
      default:
        return textLight;
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return 'To Do';
      case 'in-progress':
        return 'In Progress';
      case 'done':
        return 'Done';
      default:
        return status;
    }
  }
}
