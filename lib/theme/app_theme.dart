import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFE53935), // Vibrant Red
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFFCDD2), // Light red for containers
    onPrimaryContainer: Color(0xFFB71C1C),

    secondary: Color(0xFF43A047), // Green
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFC8E6C9), // Light green for containers
    onSecondaryContainer: Color(0xFF1B5E20),

    tertiary: Color(0xFF1E88E5), // Blue
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFBBDEFB), // Light blue for containers
    onTertiaryContainer: Color(0xFF0D47A1),

    error: Color(0xFFD32F2F),
    onError: Colors.white,

    background: Color(0xFFF8F9FA),
    onBackground: Color(0xFF1A1A1A),

    surface: Colors.white, // Pure white for cards, bottom nav, etc.
    onSurface: Color(0xFF1A1A1A),
    surfaceVariant: Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFF6F6F6F),

    outline: Color(0xFFE0E0E0),
    shadow: Colors.black12,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  // Disable surface tint globally to prevent color bleeding
  applyElevationOverlayColor: false,
  appBarTheme: const AppBarTheme(
    toolbarHeight: 52,
    surfaceTintColor: Colors.transparent, // Remove tint from app bar
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent, // Remove tint from dialogs
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent, // Remove tint from bottom sheets
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
    color: Colors.white, // Pure white
    surfaceTintColor: Colors.transparent, // Remove any tint
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
    backgroundColor: Color(0xFFE53935), // Red background
    foregroundColor: Colors.white,
    smallSizeConstraints: BoxConstraints.tightFor(width: 48, height: 48),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Colors.white, // Pure white drawer
    surfaceTintColor: Colors.transparent, // Remove tint
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 60,
    backgroundColor: Colors.white, // Pure white background
    surfaceTintColor: Colors.transparent, // Remove any tint
    indicatorColor: const Color(0xFFFFEBEE), // Very light red for selected item
    labelTextStyle: MaterialStateProperty.all(
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    ),
    iconTheme: MaterialStateProperty.all(
      const IconThemeData(size: 22),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white, // Pure white background
    elevation: 8,
  ),
  iconTheme: const IconThemeData(
    size: 20,
  ),
);
