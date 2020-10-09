import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localhelper/settings.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';

import '../screen_start.dart';

class ScreenSettings extends StatefulWidget {
  @override
  _ScreenSettingsState createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  Settings settings;

  @override
  void initState() {
    settings = context.read<Settings>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: settings.darkMode ? Colors.black : Colors.white,
          body: ListView(
            reverse: true,
            children: [
              FlatButton(
                height: 60,
                onPressed: () {
                  context.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => ScreenStart()),
                      (Route<dynamic> route) => false);
                },
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: settings.darkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              SwitchListTile(
                value: settings.darkMode,
                onChanged: (value) => settings.changeDark(),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: settings.darkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
