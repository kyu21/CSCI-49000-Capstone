import 'package:flutter/cupertino.dart';

class Settings extends ChangeNotifier {
  bool darkMode = false;
  int listNum = 0;
  int userNum = 0;

  // FUNCTIONS ================================
  void changeDark() {
    darkMode = !darkMode;
    notifyListeners();
  }

  void updateListNum(int i) {
    listNum = i;
    notifyListeners();
  }

  void updateUserNum(int i) {
    userNum = i;
    notifyListeners();
  }
}
