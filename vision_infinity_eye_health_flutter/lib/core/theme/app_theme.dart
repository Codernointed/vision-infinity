import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF3B82F6), // Blue
      onPrimary: Colors.white,
      secondary: const Color(0xFF64748B), // Slate
      onSecondary: Colors.white,
      tertiary: const Color(0xFF22C55E), // Green
      onTertiary: Colors.white,
      error: const Color(0xFFEF4444), // Red
      onError: Colors.white, // Softer text color
      surface: const Color(0xFFF1F5F9), // Slightly off-white surface
      onSurface: const Color(0xFF334155), // Softer text color
      surfaceContainerHighest: const Color(0xFFE2E8F0), // Even softer surface
      onSurfaceVariant: const Color(0xFF64748B),
      outline: const Color(0xFFCBD5E1), // Softer outline
      shadow: Colors.black.withOpacity(0.03), // Subtler shadow
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Match background color
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFFF1F5F9), // Slightly off-white
      foregroundColor: Color(0xFF334155), // Softer text
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF1F5F9), // Slightly off-white
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogTheme(
      elevation: 0,
      backgroundColor: const Color(0xFFF1F5F9), // Slightly off-white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: Colors.transparent,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF3B82F6);
        }
        return const Color(0xFF64748B);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF3B82F6).withOpacity(0.2);
        }
        return const Color(0xFF64748B).withOpacity(0.2);
      }),
    ),
    tabBarTheme: const TabBarTheme(
      labelPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF60A5FA), // Light Blue
      onPrimary: Colors.white,
      secondary: const Color(0xFF94A3B8), // Light Slate
      onSecondary: Colors.white,
      tertiary: const Color(0xFF4ADE80), // Light Green
      onTertiary: Colors.white,
      error: const Color(0xFFF87171), // Light Red
      onError: Colors.white,
      surface: const Color(0xFF1E293B),
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF334155),
      onSurfaceVariant: const Color(0xFF94A3B8),
      outline: const Color(0xFF475569),
      shadow: Colors.black.withOpacity(0.2),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF60A5FA);
        }
        return const Color(0xFF94A3B8);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF60A5FA).withOpacity(0.2);
        }
        return const Color(0xFF94A3B8).withOpacity(0.2);
      }),
    ),
    tabBarTheme: const TabBarTheme(
      labelPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
  );
}
