import 'package:flutter/material.dart';

enum SortMode { updatedDesc, labelAsc, prefixAsc, favoriteFirst }

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _textScale = 1.0;

  ThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;

  void setThemeMode(ThemeMode v) {
    _themeMode = v;
    notifyListeners();
  }

  void setTextScale(double v) {
    _textScale = v.clamp(0.8, 1.6);
    notifyListeners();
  }
}
