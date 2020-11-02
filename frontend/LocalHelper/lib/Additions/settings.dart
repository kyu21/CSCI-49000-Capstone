import 'package:flutter/cupertino.dart';

class Settings extends ChangeNotifier {
  bool darkMode = false;
  int listNum = 0; // Posts
  int userNum = 0; // UserNames
  int personalNum = 0; // Personal Posts

  // FUNCTIONS ================================
  void changeDark() {
    darkMode = !darkMode;
    notifyListeners();
  }

  void updateListNum(int i) {
    listNum = i;
    notifyListeners();
  }

  void updatePersonalNum(int i) {
    personalNum = i;
    notifyListeners();
  }

  void updateUserNum(int i) {
    userNum = i;
    notifyListeners();
  }
}
