import 'package:flutter/material.dart';

class AuthSettings extends ChangeNotifier {
  String profileName = 'test';

  void updateProfile(user) {
    profileName = user.displayName;
    notifyListeners();
  }
}
