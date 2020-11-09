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

    final _first = authSettings.first;
    final _last = authSettings.last;
    final _gender = authSettings.gender;
    final _phone = authSettings.phone;
    final _email = authSettings.email;
    final _zip = authSettings.zip;
    final _zipID = authSettings.zipID;

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
                'Edit User Info',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FittedBox(
                      alignment: Alignment.center,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          SizedBox(width: 4),
                          Icon(
                            Icons.person,
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Name: " + _first + ' ' + _last,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: settings.darkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Gender
                    SizedBox(height: 20),
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Icon(
                            Icons.family_restroom,
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Gender: ' + _gender,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: settings.darkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Phone
                    SizedBox(height: 20),
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(children: [
                        SizedBox(width: 8),
                        Icon(
                          Icons.phone,
                          color:
                              settings.darkMode ? Colors.white : Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Phone: ' + _phone,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ]),
                    ),

                    // Email
                    SizedBox(height: 20),
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Icon(
                            Icons.email,
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Email: ' + _email,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: settings.darkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Zip
                    SizedBox(height: 20),
                    _zip == ""
                        ? FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.contact_mail,
                                    color: settings.darkMode
                                        ? Colors.white
                                        : Colors.black),
                                SizedBox(width: 8),
                                Text(
                                  'Zip: None',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: settings.darkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.contact_mail,
                                    color: settings.darkMode
                                        ? Colors.white
                                        : Colors.black),
                                SizedBox(width: 8),
                                Text(
                                  'Zip: ' + _zip,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: settings.darkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                    // Zip ID
                    // SizedBox(height: 20),
                    // Text(
                    //   'ZipID: ' + _zipID.toString(),
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     fontSize: 30,
                    //     fontWeight: FontWeight.bold,
                    //     color: settings.darkMode ? Colors.white : Colors.black,
                    //   ),
                    // ),
                  ],
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
