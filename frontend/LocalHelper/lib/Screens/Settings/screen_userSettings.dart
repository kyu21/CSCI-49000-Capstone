/*
  Allow the user to update their info.
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';

class ScreenUserSettings extends StatefulWidget {
  @override
  _ScreenUserSettingsState createState() => _ScreenUserSettingsState();
}

class _ScreenUserSettingsState extends State<ScreenUserSettings> {
  // Json info
  var info;

  Future getOwnerDetails(String token) async {
    try {
      Map<String, String> headers = {
        'authorization': token,
      };
      String link = 'https://localhelper-backend.herokuapp.com/api/users/me';
      var result = await http.get(link, headers: headers);
      info = jsonDecode(result.body);
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    return FutureBuilder(
      future: getOwnerDetails(authSettings.token),
      builder: (context, snapshot) {
        // When  not connected
        if (snapshot.connectionState == ConnectionState.none) {
          return OwnerNone();

          // When loading
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return OwnerWait();

          // When finished
        } else if (snapshot.connectionState == ConnectionState.done) {
          return OwnerDone(info, authSettings);
        }

        // Failsafe
        return OwnerNone();
      },
    );
  }
}

class OwnerNone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Owner not found!'),
      ),
    );
  }
}

class OwnerWait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class OwnerDone extends StatefulWidget {
  // Json
  final info;
  final AuthSettings authSettings;
  OwnerDone(this.info, this.authSettings);
  @override
  _OwnerDoneState createState() => _OwnerDoneState(this.info, authSettings);
}

class _OwnerDoneState extends State<OwnerDone> {
// VARIABLES ===================================================================

  // Save json info
  final info;

  // Controllers
  final firstNController = TextEditingController();
  final lastNController = TextEditingController();
  final genderController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final zipController = TextEditingController();

  // Loading
  bool _loading = false;
  bool _invalidZip = false;

// =============================================================================
// FUNCTIONS ===================================================================

  @override
  void dispose() {
    firstNController.dispose();
    lastNController.dispose();
    genderController.dispose();
    phoneController.dispose();
    emailController.dispose();
    zipController.dispose();
    super.dispose();
  }

  // Constructor
  _OwnerDoneState(this.info, AuthSettings authSettings) {
    firstNController.text = info['first'];
    lastNController.text = info['last'];
    genderController.text = info['gender'];
    phoneController.text = info['phone'];
    emailController.text = info['email'];
    zipController.text = authSettings.zip;
  }

  Future<bool> _showMyDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This action is permanent!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

// =============================================================================
// WIDGETS =====================================================================

// Save button function
  Widget saveButton(Settings settings, AuthSettings authSettings) {
    return FlatButton(
      height: 60,
      minWidth: double.infinity,
      onPressed: () async {
        if (zipController.text.length < 5) {
          setState(() {
            _invalidZip = true;
          });
          return false;
        }

        try {
          // Put body
          Map<String, dynamic> jsonMap = {
            'first': firstNController.text,
            'last': lastNController.text,
            'gender': genderController.text,
            'phone': phoneController.text,
            'email': emailController.text,
          };

          // Encode
          String jsonString = json.encode(jsonMap);

          // Header
          Map<String, String> headers = {
            'authorization': authSettings.token,
            "Content-Type": "application/json",
          };
          String link = 'https://localhelper-backend.herokuapp.com/api/users';
          var result = await http.put(link, headers: headers, body: jsonString);

          // ZIP CHECK
          http.Response zipResponse = await http
              .get('https://localhelper-backend.herokuapp.com/api/zips',
                  headers: headers)
              .timeout(Duration(seconds: 5));

          var zipJson = jsonDecode(zipResponse.body);

          int _zipID = -1;
          String _zip = "";
          bool _found = false;
          for (int i = 0; i < zipJson.length; i++) {
            if (zipJson[i]['zip'] == zipController.text.toString()) {
              _zipID = zipJson[i]['id'];
              _zip = zipJson[i]['zip'];
              _found = true;
              break;
            }
          }

          // If the zip was in the database
          if (_found) {
            authSettings.zipID = _zipID;
            authSettings.zip = _zip;

            // Check if the Zip was already added before
            http.Response zipCheck = await http
                .get('https://localhelper-backend.herokuapp.com/api/users/me',
                    headers: headers)
                .timeout(Duration(seconds: 5));

            var zipCheckJson = jsonDecode(zipCheck.body);

            bool _found = false;
            for (int i = 0; i < zipCheckJson['zips'].length; i++) {
              if (zipCheckJson['zips'][i]['zip'] == _zip) {
                _found = true;
                break;
              }
            }

            // If it wasn't added before add it
            if (!_found) {
              Map<String, dynamic> jsonMap = {
                'userId': authSettings.ownerId,
                'zipId': _zipID,
              };

              // Encode
              String jsonString = json.encode(jsonMap);

              http.Response zipPut = await http
                  .post(
                      'https://localhelper-backend.herokuapp.com/api/userZips',
                      headers: headers,
                      body: jsonString)
                  .timeout(Duration(seconds: 5));
              print(zipPut.statusCode);
            }
          }

          // If it wasn't in the database add a new one
          else {
            // Put body
            Map<String, dynamic> jsonMap = {
              'zip': zipController.text,
              'name': "NEW",
            };

            // Encode
            String jsonString = json.encode(jsonMap);

            // Header
            Map<String, String> headers = {
              'authorization': authSettings.token,
              "Content-Type": "application/json",
            };
            String link = 'https://localhelper-backend.herokuapp.com/api/zips';
            var newZip =
                await http.post(link, headers: headers, body: jsonString);

            var newJson = jsonDecode(newZip.body);

            authSettings.zipID = newJson['id'];
            authSettings.zip = newJson['zip'];
          }

          if (result.statusCode == 200) {
            // Update info
            authSettings.updateFirst(jsonMap['first']);
            authSettings.updateLast(jsonMap['last']);
            authSettings.updateGender(jsonMap['gender']);
            authSettings.updatePhone(jsonMap['phone']);
            authSettings.updateEmail(jsonMap['email']);

            setState(() {
              _loading = false;
            });
            Navigator.pop(context);
          }
        } catch (e) {
          print(e);
        }

        setState(() {
          _loading = false;
        });
      },
      child: _loading
          ? CircularProgressIndicator()
          : Text(
              'Save',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: settings.darkMode ? Colors.white : Colors.black,
              ),
            ),
    );
  }

  // Save button function
  Widget deleteButton(Settings settings, AuthSettings authSettings) {
    return FlatButton(
      color: Colors.red[300],
      height: 80,
      minWidth: double.infinity,
      onPressed: () async {
        bool answer = await _showMyDialog();

        if (answer) {
          try {
            // Header
            Map<String, String> headers = {
              'authorization': authSettings.token,
              "Content-Type": "application/json",
            };
            String link = 'https://localhelper-backend.herokuapp.com/api/users';
            var result = await http.delete(link, headers: headers);
            print(result.statusCode);
            if (result.statusCode == 200) {
              setState(() {
                _loading = false;
              });
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          } catch (e) {
            print(e);
          }

          setState(() {
            _loading = false;
          });
        }
      },
      child: _loading
          ? CircularProgressIndicator()
          : Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: settings.darkMode ? Colors.white : Colors.black,
              ),
            ),
    );
  }

// =============================================================================
// MAIN ========================================================================

  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: settings.darkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: settings.darkMode
                ? Colors.white
                : Colors.black, //change your color here
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'User Settings',
            style: TextStyle(
              color: settings.darkMode ? Colors.white : Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            // First Name
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: firstNController,
                cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                keyboardType: TextInputType.name,
                style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Last Name
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: lastNController,
                cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                keyboardType: TextInputType.name,
                style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Gender
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: genderController,
                cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Phone
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: phoneController,
                cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Email
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: emailController,
                cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Zip
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: zipController,
                cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Zip',
                  labelStyle: TextStyle(
                    color: _invalidZip
                        ? Colors.red
                        : settings.darkMode
                            ? Colors.white
                            : Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Save
            SizedBox(height: 40),
            saveButton(settings, authSettings),
            Expanded(
              child: Container(
                child: Column(
                  verticalDirection: VerticalDirection.up,
                  children: [
                    deleteButton(settings, authSettings),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
