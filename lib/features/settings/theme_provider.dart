import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Available theme IDs
const themeDefault = 'default';
const themeLight   = 'light';
const themeDark    = 'dark';

class ThemeNotifier extends Notifier<String> {
  static const _boxName = 'appPrefs';
  static const _key     = 'themeId';

  @override
  String build() {
    final box = Hive.box(_boxName);
    return (box.get(_key) as String?) ?? themeDefault;
  }

  void setTheme(String id) async {
    final box = Hive.box(_boxName);
    await box.put(_key, id);
    state = id;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, String>(
  ThemeNotifier.new,
);
