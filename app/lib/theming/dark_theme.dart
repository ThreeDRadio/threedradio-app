import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:player/theming/colors.dart';
import 'package:player/theming/typography.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark().copyWith(
    primary: ThreeDColors.green,
    surface: ThreeDColors.black,
    onSurface: ThreeDColors.sand,
  ),
  canvasColor: ThreeDColors.darkGrey,
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
  textTheme: threeDTextTheme,
  sliderTheme: SliderThemeData(
    activeTrackColor: ThreeDColors.sand,
    thumbColor: ThreeDColors.sand,
    inactiveTrackColor: ThreeDColors.sand,
    overlayColor: ThreeDColors.sand.withAlpha(40),
  ),
);
