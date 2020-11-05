import 'package:flutter/material.dart';

class AuthSettings extends ChangeNotifier {
  // Authorize
  String token = "";
  int ownerId = -1;

  // Personal Info
  String first = "";
  String last = "";
  String gender = "";
  String phone = "";
  String email = "";

  // FUNCTIONS =======================================

  // Update token
  void updateToken(newToken) {
    token = newToken;
  }

  // UPDATE INFO =============

  // First Name
  void updateFirst(String name) {
    this.first = name;
    notifyListeners();
  }

  // Last Name
  void updateLast(String name) {
    this.last = name;
    notifyListeners();
  }

  // Gender
  void updateGender(String g) {
    this.gender = g;
    notifyListeners();
  }

  // Phone
  void updatePhone(String phone) {
    this.phone = phone;
    notifyListeners();
  }

  // Email
  void updateEmail(String email) {
    this.email = email;
    notifyListeners();
  }
}
