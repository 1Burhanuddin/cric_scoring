import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1E88E5),
    primary: const Color(0xFF1E88E5),
    secondary: const Color(0xFF43A047),
    background: const Color(0xFFF8F9FA),
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  appBarTheme: const AppBarTheme(
    toolbarHeight: 52,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1A1A1A),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF1A1A1A),
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: Color(0xFF6F6F6F),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 0.5,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
  ),
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    minLeadingWidth: 40,
    horizontalTitleGap: 12,
    dense: true,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    isDense: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      minimumSize: const Size(0, 38),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    elevation: 2,
    smallSizeConstraints: BoxConstraints.tightFor(width: 48, height: 48),
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 60,
    labelTextStyle: MaterialStateProperty.all(
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    ),
    iconTheme: MaterialStateProperty.all(
      const IconThemeData(size: 22),
    ),
  ),
  iconTheme: const IconThemeData(
    size: 20,
  ),
);
