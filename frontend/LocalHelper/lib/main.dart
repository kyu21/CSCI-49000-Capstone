import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'Screens/screen_error.dart';
import 'Screens/screen_load.dart';
import 'Screens/screen_start.dart';
import 'settings.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => Settings(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: App(),
    );
  }
}

class App extends StatelessWidget {
  // Create the initilization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return ScreenError();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return ScreenStart();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return ScreenLoad();
      },
    );
  }
}
