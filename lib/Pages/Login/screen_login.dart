import 'package:flutter/material.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:localhelper/Pages/screen_posts.dart';

class ScreenAuth extends StatefulWidget {
  @override
  _ScreenAuthState createState() => _ScreenAuthState();
}

class _ScreenAuthState extends State<ScreenAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LitAuth(
        onAuthSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScreenPosts()),
          );
        },
        onAuthFailure: null,
      ),
    );
  }
}
