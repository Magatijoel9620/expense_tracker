// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode(); // Load saved theme preference on initialization
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _saveThemeMode(_themeMode); // Save theme preference
  }

  // Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeModeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
  }

  // Save theme mode to shared preferences
  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
  }

  // Optional: Define your light and dark themes here or in main.dart
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green, // Example primary color for light theme
    colorScheme: ColorScheme.light(
      primary: Colors.green,       // Primary color for components like AppBar
      secondary: Colors.teal,      // Secondary color (e.g., for FAB)
      surface: Colors.white,       // Background of cards, dialogs
      background: Colors.grey[100]!,// Overall background of scaffold
      onPrimary: Colors.white,     // Text/icons on primary color
      onSecondary: Colors.white,   // Text/icons on secondary color
      onSurface: Colors.black87,   // Text/icons on surface color
      onBackground: Colors.black87,// Text/icons on background color
      surfaceVariant: Colors.grey[200]!, // Used for your scaffold background
      onSurfaceVariant: Colors.black54,  // Text on surfaceVariant
    ),
    appBarTheme: const AppBarTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    ),
    // Add other theme properties as needed
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal, // Example primary color for dark theme
    colorScheme: ColorScheme.dark(
      primary: Colors.teal[700]!,   // Darker primary for dark mode
      secondary: Colors.cyanAccent, // Accent for FAB
      surface: Colors.grey[850]!,  // Dark surface for cards
      background: Colors.grey[900]!,// Overall dark background
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white70,
      onBackground: Colors.white70,
      surfaceVariant: Colors.grey[800]!, // Darker scaffold background
      onSurfaceVariant: Colors.white60,   // Text on dark surfaceVariant
    ),
    appBarTheme: AppBarTheme(
      elevation: 2.0,
      backgroundColor: Colors.teal[700], // Ensure AppBar matches
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    ),
    // Customize dark theme further [1]
    // Use dark grey – rather than black – to express elevation and space [1]
  );
}
