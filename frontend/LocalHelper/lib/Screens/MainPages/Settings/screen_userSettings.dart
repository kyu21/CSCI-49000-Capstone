/*
  Allow the user to update their info.
*/

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localhelper/Additions/authSettings.dart';
import 'package:localhelper/Additions/settings.dart';
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
          return OwnerDone(info);
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
  OwnerDone(this.info);
  @override
  _OwnerDoneState createState() => _OwnerDoneState(this.info);
}

class _OwnerDoneState extends State<OwnerDone> {
  // Save json info
  final info;

  // Controllers
  final firstNController = TextEditingController();
  final lastNController = TextEditingController();
  final genderController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  _OwnerDoneState(this.info) {
    firstNController.text = info['first'];
    lastNController.text = info['last'];
    genderController.text = info['gender'];
    phoneController.text = info['phone'];
    emailController.text = info['email'];
  }

  // Loading
  bool _loading = false;

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
                keyboardType: TextInputType.name,
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
                keyboardType: TextInputType.name,
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
                keyboardType: TextInputType.name,
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

            // Save
            // Sign Out
            SizedBox(height: 40),
            FlatButton(
              height: 60,
              minWidth: double.infinity,
              onPressed: () async {
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
                  String link =
                      'https://localhelper-backend.herokuapp.com/api/users';
                  var result =
                      await http.put(link, headers: headers, body: jsonString);
                  print(result.statusCode);
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
            ),
          ],
        ),
      ),
    );
  }
}
