import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeData get currentTheme => _themeMode == ThemeMode.dark 
      ? _darkTheme 
      : _lightTheme;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Enhanced light theme
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true, // Consider using Material 3
    brightness: Brightness.light,
    primaryColor: const Color(0xFF3498db),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3498db),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3498db),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3498db),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF2c3e50)),
      bodyMedium: TextStyle(color: Color(0xFF2c3e50)),
    ),
  );

  // Enhanced dark theme
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true, // Consider using Material 3
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF3498db),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3498db),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3498db),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}