import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Screens/Login/screen_login.dart';
import 'package:localhelper/Screens/Settings/screen_userSettings.dart';
import 'package:provider/provider.dart';

class ScreenSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
// =============================================================================
// VARIABLES ===================================================================

    // Providers
    final Settings settings = Provider.of<Settings>(context);
    final AuthSettings authSettings = Provider.of<AuthSettings>(context);

    final _first = authSettings.first;
    final _last = authSettings.last;
    final _gender = authSettings.gender;
    final _phone = authSettings.phone;
    final _email = authSettings.email;
    final _zip = authSettings.zip;
    final _lang = authSettings.languages;

//==============================================================================
// FUNCTIONS ===================================================================

// =============================================================================
// WIDGETS =====================================================================

    // Languages
    Widget languageDisplay() {
      return Expanded(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Icon(
                      Icons.email,
                      color:
                          settings.darkMode ? settings.colorBlue : Colors.black,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Languages: ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Container(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          _lang[index],
                          style: TextStyle(
                            fontSize: 30,
                            color: settings.darkMode
                                ? settings.colorMiddle
                                : Colors.black,
                          ),
                        ),
                      );
                    },
                    itemCount: _lang.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

// =============================================================================
// MAIN ========================================================================

    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: settings.darkMode
                  ? [
                      settings.colorBackground,
                      settings.colorBackground,
                      Colors.black87,
                    ]
                  : [Colors.white, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
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
                  child: Row(
                    children: [
                      Text(
                        'Sign Out',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: settings.darkMode
                              ? settings.colorOpposite
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // User Settings
                FlatButton(
                  height: 60,
                  minWidth: double.infinity,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ScreenUserSettings();
                    }));
                  },
                  child: Row(
                    children: [
                      Text(
                        'Edit User Info',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: settings.darkMode
                              ? settings.colorBlue
                              : Colors.black,
                        ),
                      ),
                    ],
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
                      color:
                          settings.darkMode ? settings.colorBlue : Colors.black,
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
                                color: settings.darkMode
                                    ? settings.colorBlue
                                    : Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Name: " + _first + ' ' + _last,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: settings.darkMode
                                      ? settings.colorMiddle
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
                                color: settings.darkMode
                                    ? settings.colorBlue
                                    : Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Gender: ' + _gender,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: settings.darkMode
                                      ? settings.colorMiddle
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
                              color: settings.darkMode
                                  ? settings.colorBlue
                                  : Colors.black,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Phone: ' + _phone,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: settings.darkMode
                                    ? settings.colorMiddle
                                    : Colors.black,
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
                                color: settings.darkMode
                                    ? settings.colorBlue
                                    : Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Email: ' + _email,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: settings.darkMode
                                      ? settings.colorMiddle
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
                                            ? settings.colorBlue
                                            : Colors.black),
                                    SizedBox(width: 8),
                                    Text(
                                      'Zip: None',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: settings.darkMode
                                            ? settings.colorMiddle
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
                                            ? settings.colorBlue
                                            : Colors.black),
                                    SizedBox(width: 8),
                                    Text(
                                      'Zip: ' + _zip,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: settings.darkMode
                                            ? settings.colorMiddle
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                        // Languages
                        SizedBox(height: 20),
                        languageDisplay(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
