import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  Color mainBGColor = const Color(0xFF20254E);
  Color colorWhite = const Color(0xFFFFFFFF);
  Color colorPrimary = const Color(0xFFDEBD69);
  FontWeight fWNormal = FontWeight.normal;
  FontWeight fWBold = FontWeight.bold;
  double headlineTextSize = 20;
  Color iconColor = const Color(0xFFDADADA);
  Color iconBgColor = const Color(0xFF3C4171);

  static const Color noteColorGolden = Color(0xFFDEBD69);
  static const Color noteColorTurquoise = Color(0xFF8ED9CE);
  static const Color noteColorPink = Color(0xFFF3C3E5);
  static const Color noteColorGreen = Color(0xFFAED581);
  static const Color noteColorWhite = Color(0xFFFFF9E6);

  // A map to retrieve colors based on enum
  final Map<NoteColor, Color> noteColors = {
    NoteColor.golden: noteColorGolden,
    NoteColor.turquoise: noteColorTurquoise,
    NoteColor.orange: noteColorPink,
    NoteColor.green: noteColorGreen,
    NoteColor.white: noteColorWhite,
  };

  // To get a color by its enum value
  Color getNoteColor(NoteColor color) {
    return noteColors[color] ?? noteColorWhite; // Default to white if not found
  }

  ThemeProvider() {
    _loadThemePreference(); // Load theme on initialization
  }

  // Toggle theme and save preference
  void toggleTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    notifyListeners();
    _saveThemePreference(isDarkMode);
  }

  // Save theme preference
  Future<void> _saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  // Load theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Method to convert String to FontWeight
  FontWeight _getFontWeight(String fw) {
    switch (fw.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'light':
        return FontWeight.w300;
      case 'medium':
        return FontWeight.w500;
      case 'semibold':
        return FontWeight.w600;
      case 'heavy':
        return FontWeight.w800;
      default:
        return FontWeight.normal; // Default to normal if input is invalid
    }
  }

  // Custom font method
  TextStyle customFontsMerriweather(int size, String fw, Color fc) {
    return GoogleFonts.merriweather(
      textStyle: TextStyle(
        fontSize: size.toDouble(),
        fontWeight: _getFontWeight(fw),
        color: fc,
      ),
    );
  }

  // Custom font method
  TextStyle customFontsRoboto(int size, String fw, Color fc) {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        fontSize: size.toDouble(),
        fontWeight: _getFontWeight(fw),
        color: fc,
      ),
    );
  }

  heightWidget({required double heightValue}) {
    return SizedBox(
      height: heightValue,
    );
  }
}

enum NoteColor {
  golden,
  turquoise,
  orange,
  green,
  white,
}
