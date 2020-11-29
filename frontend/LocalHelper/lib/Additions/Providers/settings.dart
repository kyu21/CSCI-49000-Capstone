import 'package:flutter/cupertino.dart';
import 'package:localhelper/Additions/Classes/hexcolor.dart';

class Settings extends ChangeNotifier {
  // Bpp;s
  bool local = true;
  bool darkMode = true;

  // Iterators
  int listNum = 0; // Posts
  int interestNum = 0; // UserNames
  int personalNum = 0; // Personal Posts

  // Refreshers
  bool refreshPosts = false;
  bool refreshMyposts = false;

  // Colors
  final Color colorBackground = HexColor.fromHex('#011638');
  final Color colorOpposite = HexColor.fromHex('#963D5A');
  final Color colorLight = HexColor.fromHex('#EEE5E9');
  final Color colorMiddle = HexColor.fromHex('#92DCE5');
  final Color colorBlue = HexColor.fromHex('#52DEE5');

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
