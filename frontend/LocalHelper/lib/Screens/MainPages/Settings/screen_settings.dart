import 'package:flutter/material.dart';
import 'package:localhelper/Additions/authSettings.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:localhelper/initialize.dart';
import 'package:provider/provider.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';

class ScreenSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Providers
    final Settings settings = Provider.of<Settings>(context);
    final AuthSettings authSettings = Provider.of<AuthSettings>(context);

    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          verticalDirection: VerticalDirection.up,
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
            Expanded(
              child: Container(
                child: Text(
                  authSettings.profileName != null
                      ? authSettings.profileName
                      : 'None',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: settings.darkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
