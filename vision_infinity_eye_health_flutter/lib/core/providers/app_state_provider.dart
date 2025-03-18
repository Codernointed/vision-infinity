import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode provider with persistence
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const _key = 'theme_mode';

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == value,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.toString());
    state = mode;
  }
}

// Auth state provider
final authStateProvider = StateProvider<bool>((ref) => false);

// Loading state provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Error state provider
final errorProvider = StateProvider<String?>((ref) => null);

// User provider
final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Scan results provider
final scanResultsProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

// Current scan provider
final currentScanProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Advanced mode provider
final isAdvancedModeProvider = StateProvider<bool>((ref) => false);
