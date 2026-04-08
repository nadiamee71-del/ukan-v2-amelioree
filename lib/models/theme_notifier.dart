import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark }

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal() {
    _loadTheme();
  }

  AppThemeMode _currentTheme = AppThemeMode.light;
  static const String _themeKey = 'theme_mode';

  AppThemeMode get currentTheme => _currentTheme;
  bool get isDarkMode => _currentTheme == AppThemeMode.dark;

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null && themeIndex >= 0 && themeIndex < AppThemeMode.values.length) {
        _currentTheme = AppThemeMode.values[themeIndex];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du thème: $e');
    }
  }

  Future<void> toggleTheme() async {
    _currentTheme = _currentTheme == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _currentTheme.index);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du thème: $e');
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    if (_currentTheme == theme) return;
    _currentTheme = theme;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _currentTheme.index);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du thème: $e');
    }
  }
}

