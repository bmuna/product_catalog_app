import 'package:flutter/material.dart';

class ThemeModeNotifier extends ChangeNotifier {
  ThemeModeNotifier([ThemeMode mode = ThemeMode.system]) : _mode = mode;

  ThemeMode _mode;
  ThemeMode get mode => _mode;
  set mode(ThemeMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }

  void toggle() {
    mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

class ThemeModeScope extends InheritedNotifier<ThemeModeNotifier> {
  const ThemeModeScope({super.key, required ThemeModeNotifier notifier, required super.child})
      : super(notifier: notifier);

  static ThemeModeNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeModeScope>();
    assert(scope != null, 'ThemeModeScope not found');
    return scope!.notifier!;
  }
}
