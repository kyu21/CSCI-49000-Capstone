import 'package:flutter/material.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';

class ScreenPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User user = context.getSignedInUser();
    print(user);
    print('hello');
    return Container(
      color: Colors.black,
    );
  }
}
