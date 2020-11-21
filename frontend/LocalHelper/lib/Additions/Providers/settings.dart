import 'package:flutter/cupertino.dart';

class Settings extends ChangeNotifier {
  bool local = true;
  bool darkMode = false;

  int listNum = 0; // Posts
  int interestNum = 0; // UserNames
  int personalNum = 0; // Personal Posts

  // Refreshers
  bool refreshPosts = false;
  bool refreshMyposts = false;

  // FUNCTIONS ================================
  void changeDark() {
    darkMode = !darkMode;
    notifyListeners();
  }

  void updateListNum(int i) {
    listNum += i;
  }

  void updatePersonalNum(int i) {
    personalNum += i;
  }

  void updateInterestNum(int i) {
    interestNum += i;
  }

  void refreshPage() {
    refreshPosts = true;
    refreshMyposts = true;
    notifyListeners();
  }
}