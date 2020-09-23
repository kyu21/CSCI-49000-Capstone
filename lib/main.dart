import 'package:flutter/material.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';

import 'screen_main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScreenLogin(),
    );
  }
}

// The login screen for the application
class ScreenLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LitAuthInit(
      authProviders: AuthProviders(
        emailAndPassword: true,
        google: true,
      ),
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.blueAccent,
          body: Column(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      SizedBox(height: 75),
                      Expanded(
                        child: Text(
                          'Local Helper',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 75,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  color: Colors.blueAccent,
                ),
              ),
              Container(
                child: LitAuth(
                  onAuthSuccess: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScreenHome()),
                    );
                  },
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
