import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Pages/Login/screen_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenStart();
  }
}

class ScreenStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScreenLogin(),
    );
  }
}
