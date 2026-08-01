import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final threeDTextTheme = TextTheme(
  bodyLarge: GoogleFonts.barlowCondensed(fontSize: 18),
  bodyMedium: GoogleFonts.barlowCondensed(fontSize: 16),
  bodySmall: GoogleFonts.barlowCondensed(fontSize: 14),
  labelLarge: GoogleFonts.barlowCondensed(
    fontWeight: FontWeight.bold,
  ),
  displayMedium: GoogleFonts.vinaSans(fontSize: 40),
  displaySmall: GoogleFonts.vinaSans(fontSize: 36),
  headlineMedium: GoogleFonts.vinaSans(
    fontSize: 32,
    height: 1,
  ),
  headlineSmall: GoogleFonts.vinaSans(),
  titleLarge: GoogleFonts.vinaSans(fontSize: 18),
);
final primaryTextTheme = GoogleFonts.vinaSansTextTheme(
  TextTheme(titleLarge: TextStyle(color: Colors.white)),
);
