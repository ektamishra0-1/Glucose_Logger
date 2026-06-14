import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xff050816),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xff00F5FF),
      secondary: Color(0xff00C2FF),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),

    cardTheme: const CardThemeData(color: Color(0xff111827)),
  );
}
