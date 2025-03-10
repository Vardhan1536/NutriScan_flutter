import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF0D244A),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.poppins().fontFamily, 
    textTheme: GoogleFonts.poppinsTextTheme(),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.blueGrey.shade600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0D244A),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}


// Primary Color	Color(0xFF0D244A) (Dark Blue)
// Secondary Color	Color(0xFFF1AA8F) (Soft Orange)
// Background	Color(0xFFFDF3EF) (Peach)
// Surface	Color(0xFFFFFFFF) (White)
// Highlight / Active	Color(0xFFCEE8F1) (Light Blue)