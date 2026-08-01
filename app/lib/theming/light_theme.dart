import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:player/theming/colors.dart';
import 'package:player/theming/typography.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light().copyWith(
    primary: ThreeDColors.green,
    surface: ThreeDColors.sand,
  ),
  tabBarTheme: TabBarThemeData(
    indicatorColor: ThreeDColors.green,
  ),
  appBarTheme: AppBarThemeData(
    backgroundColor: ThreeDColors.darkGrey,
    iconTheme: IconThemeData(color: ThreeDColors.sand),
    titleTextStyle: TextStyle(
      color: ThreeDColors.sand,
      fontFamily: GoogleFonts.jockeyOne().fontFamily,
      fontSize: 22,
    ),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: ThreeDColors.darkGrey,
  ),
  listTileTheme: ListTileThemeData(
    iconColor: ThreeDColors.sand,
    textColor: ThreeDColors.sand,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  chipTheme: ChipThemeData(
    labelStyle: GoogleFonts.barlowCondensed(fontSize: 14),
  ),
  dividerColor: ThreeDColors.sand,
  dividerTheme: DividerThemeData(color: ThreeDColors.sand),
  segmentedButtonTheme: SegmentedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? ThreeDColors.black
            : ThreeDColors.sand,
      ),
      side: WidgetStatePropertyAll(BorderSide(color: ThreeDColors.sand)),
    ),
  ),
  textTheme: threeDTextTheme,
  primaryTextTheme: GoogleFonts.vinaSansTextTheme(
    TextTheme(titleLarge: TextStyle(color: ThreeDColors.white)),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: ThreeDColors.black,
    thumbColor: ThreeDColors.black,
    inactiveTrackColor: ThreeDColors.black,
    overlayColor: ThreeDColors.black.withAlpha(40),
  ),
);
