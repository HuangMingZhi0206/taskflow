import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _fontSizeKey = 'font_size';
  static const String _useSystemThemeKey = 'use_system_theme';

  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = const Color(0xFF6366f1); // Default Indigo
  double _fontSizeScale = 1.0;
  bool _useSystemTheme = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get accentColor => _accentColor;
  double get fontSizeScale => _fontSizeScale;
  bool get useSystemTheme => _useSystemTheme;

  // Predefined accent colors
  static const List<AccentColorOption> accentColors = [
    AccentColorOption('Indigo', Color(0xFF6366f1)),
    AccentColorOption('Blue', Color(0xFF3b82f6)),
    AccentColorOption('Purple', Color(0xFF8b5cf6)),
    AccentColorOption('Pink', Color(0xFFec4899)),
    AccentColorOption('Emerald', Color(0xFF10b981)),
    AccentColorOption('Orange', Color(0xFFf59e0b)),
    AccentColorOption('Red', Color(0xFFef4444)),
    AccentColorOption('Teal', Color(0xFF14b8a6)),
  ];

  ThemeService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    final colorValue = prefs.getInt(_accentColorKey) ?? 0xFF6366f1;
    final fontSize = prefs.getDouble(_fontSizeKey) ?? 1.0;
    final useSystem = prefs.getBool(_useSystemThemeKey) ?? false;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _accentColor = Color(colorValue);
    _fontSizeScale = fontSize;
    _useSystemTheme = useSystem;

    if (_useSystemTheme) {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _useSystemTheme = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    await prefs.setBool(_useSystemThemeKey, false);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _useSystemTheme = mode == ThemeMode.system;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, mode == ThemeMode.dark);
    await prefs.setBool(_useSystemThemeKey, mode == ThemeMode.system);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> setFontSizeScale(double scale) async {
    _fontSizeScale = scale.clamp(0.8, 1.4);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontSizeScale);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.light;
    _accentColor = const Color(0xFF6366f1);
    _fontSizeScale = 1.0;
    _useSystemTheme = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, false);
    await prefs.setInt(_accentColorKey, 0xFF6366f1);
    await prefs.setDouble(_fontSizeKey, 1.0);
    await prefs.setBool(_useSystemThemeKey, false);

    notifyListeners();
  }
}

class AccentColorOption {
  final String name;
  final Color color;

  const AccentColorOption(this.name, this.color);
}

