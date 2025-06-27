import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  void setTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  // Light Theme
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF42A5F5),
      surface: Colors.white,
      background: const Color(0xFFF8FAFF),
      onBackground: const Color(0xFF1A1A1A),
      onSurface: const Color(0xFF1A1A1A),
    ),
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1A1A1A),
    ),
    // cardTheme: CardTheme(
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(24),
    //   ),
    //   color: Colors.white,
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFF),
  );

  // Dark Theme
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF42A5F5),
      secondary: const Color(0xFF64B5F6),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      onBackground: Colors.white,
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF2A2A2A),
    ),
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    // cardTheme: CardTheme(
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(24),
    //   ),
    //   color: const Color(0xFF1E1E1E),
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );

  // Helper methods for colors
  Color getBackgroundColor(BuildContext context) {
    return _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFF);
  }

  Color getCardColor(BuildContext context) {
    return _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }

  Color getTextColor(BuildContext context) {
    return _isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
  }

  Color getSecondaryTextColor(BuildContext context) {
    return _isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  }

  Color getPrimaryColor(BuildContext context) {
    return _isDarkMode ? const Color(0xFF42A5F5) : const Color(0xFF1976D2);
  }

  Color getSurfaceColor(BuildContext context) {
    return _isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[50]!;
  }

  LinearGradient getPrimaryGradient(BuildContext context) {
    return _isDarkMode
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF42A5F5),
              const Color(0xFF64B5F6),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1976D2),
              const Color(0xFF42A5F5),
            ],
          );
  }

  BoxShadow getCardShadow(BuildContext context) {
    return BoxShadow(
      color: _isDarkMode 
          ? Colors.black.withOpacity(0.3)
          : const Color(0xFF1976D2).withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    );
  }
}
