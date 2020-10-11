import 'package:flutter/cupertino.dart';

class Settings extends ChangeNotifier {
  bool darkMode = false;
  String profileName = 'test';

  void changeDark() {
    darkMode = !darkMode;
    notifyListeners();
  }

  void updateName(name) {
    profileName = name;
    notifyListeners();
  }
}
