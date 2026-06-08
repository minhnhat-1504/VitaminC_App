import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  Box get _settingsBox => Hive.box('settingsBox');

  @override
  ThemeMode build() {
    final savedMode = _settingsBox.get(_themeKey) as String?;

    if (savedMode == 'dark') return ThemeMode.dark;
    if (savedMode == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  void toggleTheme(bool isDark) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _settingsBox.put(_themeKey, newMode.name);
    state = newMode;
  }
}
