import 'package:flutter/material.dart';

class AuthSettings extends ChangeNotifier {
  String token = "";

  void updateToken(newToken) {
    token = newToken;
    // notifyListeners();
  }
}
