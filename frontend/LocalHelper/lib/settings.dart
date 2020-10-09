import 'package:flutter/cupertino.dart';

class Settings extends ChangeNotifier {
  bool darkMode = false;

  void changeDark() {
    darkMode = !darkMode;
    notifyListeners();
  }
}
