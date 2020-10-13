import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'Additions/Screens/screen_error.dart';
import 'Additions/Screens/screen_load.dart';
import 'Additions/authSettings.dart';
import 'Additions/settings.dart';
import 'initialize.dart';

/*
  This is How the apps starts.

  1. Creates Multiproviders for Settings and AuthSettings
      - Settings is for local stuff
      - AuthSettings is credential stuff

  2. Initializes firebase
*/

void main() {
  runApp(
    MultiProvider(
      child: MyApp(),
      providers: [
        ChangeNotifierProvider(create: (_) => Settings()),
        ChangeNotifierProvider(create: (_) => AuthSettings()),
      ],
    ),
  );
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
