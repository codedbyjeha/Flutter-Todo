import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_theme';
  String _themeName = 'light';

  String get themeName => _themeName;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeName = prefs.getString(_prefsKey) ?? 'light';
    notifyListeners();
  }

  Future<void> setTheme(String name) async {
    _themeName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, name);
    notifyListeners();
  }

  ThemeData get themeData {
    if (_themeName == 'dark') return _darkTheme;
    if (_themeName == 'pink') return _pinkTheme;
    return _lightTheme;
  }

  ThemeData get _lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FE),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        elevation: 3,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEFF2FF),
        selectedColor: const Color(0xFF4F5BD5),
        labelStyle: const TextStyle(color: Color(0xFF4F5BD5)),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7F2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7F2)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F5BD5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4F5BD5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Color(0xFFCED4FF)),
        ),
      ),
    );
  }

  ThemeData get _darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8B95FF),
        onPrimary: Colors.white,
        secondary: Color(0xFF2A2F3A),
        onSecondary: Color(0xFFE6E9EF),
        surface: Color(0xFF1A1F27),
        onSurface: Color(0xFFE6E9EF),
        background: Color(0xFF0F1115),
        onBackground: Color(0xFFE6E9EF),
        error: Color(0xFFFF6B6B),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      shadowColor: const Color(0x55FFFFFF),
      dividerColor: const Color(0xFF232733),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F1115),
        foregroundColor: Color(0xFFE6E9EF),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1A1F27),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        elevation: 3,
        shadowColor: Color(0x33FFFFFF),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF232733),
        selectedColor: const Color(0xFF8B95FF),
        labelStyle: const TextStyle(color: Color(0xFFE6E9EF)),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE6E9EF)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F1115),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1F27),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF232733)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF232733)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B95FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE6E9EF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Color(0xFF2E3340)),
        ),
      ),
    );
  }

  ThemeData get _pinkTheme {
    const Color basePink = Color(0xFFFF6FAE);
    const Color softPink = Color(0xFFFFC3DA);
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: basePink,
        onPrimary: Colors.white,
        secondary: softPink,
        onSecondary: Color(0xFF3B0A1A),
        surface: Colors.white,
        onSurface: Color(0xFF2E2E2E),
        background: Color(0xFFFFF4F8),
        onBackground: Color(0xFF2E2E2E),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF4F8),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF4F8),
        foregroundColor: Color(0xFF2E2E2E),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        shadowColor: Color(0x33FF6FAE),
        elevation: 3,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFFE2EE),
        selectedColor: basePink,
        labelStyle: const TextStyle(color: Color(0xFF9A2C56)),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD1E3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD1E3)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: basePink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF9A2C56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Color(0xFFFFC3DA)),
        ),
      ),
    );
  }
}
