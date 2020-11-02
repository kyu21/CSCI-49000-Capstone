import 'package:flutter/material.dart';
import 'package:localhelper/Additions/authSettings.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:localhelper/Screens/MainPages/Settings/screen_userSettings.dart';
import 'package:localhelper/initialize.dart';
import 'package:provider/provider.dart';

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
            // Sign Out
            FlatButton(
              height: 60,
              minWidth: double.infinity,
              onPressed: () {
                authSettings.updateToken("");
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

            // User Settings
            FlatButton(
              height: 60,
              minWidth: double.infinity,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ScreenUserSettings();
                }));
              },
              child: Text(
                'User Settings',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
              ),
            ),

            // Dark Mode
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

            // User Name
            Expanded(
              child: Container(
                child: Text(
                  authSettings.token != null ? authSettings.token : 'None',
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
