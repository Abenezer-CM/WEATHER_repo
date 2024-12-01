import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = true;
  bool isImperial = false;

  void changeTheme(bool value) {
    isDarkMode = value;
    print("isDarkMode value: $isDarkMode");
    notifyListeners();
  }

  void changeMeasurment(bool value) {
    isImperial = value;
    print("isImperial value: $isImperial");
    notifyListeners();
  }
}
