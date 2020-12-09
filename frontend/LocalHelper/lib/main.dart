import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'Screens/Login/screen_login.dart';
import 'Additions/Providers/settings.dart';

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
    final Settings settings = Provider.of<Settings>(context);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: settings.darkMode
          ? SystemUiOverlayStyle.dark.copyWith(
              systemNavigationBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.light
              .copyWith(systemNavigationBarColor: Colors.grey),
      child: ScreenStart(),
    );
  }
}
