import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  
  ThemeData get currentTheme => _themeMode == ThemeMode.dark 
      ? _darkTheme 
      : _lightTheme;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  static final ThemeData _lightTheme = ThemeData(
    primaryColor: const Color(0xFF3498db),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xFF3498db),
      secondary: const Color(0xFF2c3e50),
    ),
    scaffoldBackgroundColor: Colors.white,
  );

  static final ThemeData _darkTheme = ThemeData(
    primaryColor: const Color(0xFF3498db),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3498db),
      secondary: Color(0xFF2c3e50),
    ),
    scaffoldBackgroundColor: Colors.grey[900],
  );
}