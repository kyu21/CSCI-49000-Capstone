import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:localhelper/home.dart';
import 'package:localhelper/register.dart';
import 'package:provider/provider.dart';

import 'Additions/authSettings.dart';

class ScreenStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScreenLogin(),
    );
  }
}

class ScreenLogin extends StatefulWidget {
  @override
  _ScreenLoginState createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hidePass = true;

  @override
  Widget build(BuildContext context) {
    AuthSettings authSettings = Provider.of<AuthSettings>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.teal,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    // Title
                    SizedBox(height: 50),
                    Center(child: headerSection()),

                    // Inputs
                    SizedBox(height: 50),
                    textSection(),

                    // Sign In
                    SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      margin: EdgeInsets.only(top: 30.0),
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: RaisedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          var result = await signIn(
                              emailController.text, passwordController.text);

                          if (result != null) {
                            // Update user info
                            authSettings.updateToken(result);
                            await userInfo(result, authSettings);

                            // DEBUG
                            // await debugger(result, authSettings);

                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return WillPopScope(
                                onWillPop: () async => false,
                                child: ScreenHome(),
                              );
                            }));
                          }

                          setState(() {
                            _isLoading = false;
                          });
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Text('Sign In',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ),

                    // Register
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      margin: EdgeInsets.only(top: 30.0),
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ScreenRegister();
                          }));
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Text('Register',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // WIDGETS ======================================================

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(top: 30.0),
      child: Column(
        children: [
          txtSection("Email", Icons.email, emailController),
          SizedBox(height: 30.0),
          passSection("Password", Icons.lock, passwordController),
        ],
      ),
    );
  }

  TextFormField txtSection(
      String title, IconData icons, TextEditingController control) {
    return TextFormField(
      controller: control,
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.white70),
        icon: Icon(icons),
      ),
    );
  }

  TextFormField passSection(
      String title, IconData icons, TextEditingController control) {
    return TextFormField(
      obscureText: _hidePass,
      controller: control,
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.white70),
        icon: Icon(icons),
        suffixIcon: IconButton(
          icon: Icon(Icons.remove_red_eye),
          color: _hidePass ? Colors.black87 : Colors.grey,
          onPressed: () {
            setState(() {
              _hidePass = !_hidePass;
            });
          },
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Text(
        "Local Helper",
        style: TextStyle(
          fontSize: 50,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==============================================================

  // FUNCTIONS ===================================================

  Future debugger(String token, AuthSettings authSettings) async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };

      http.Response response = await http
          .get('https://localhelper-backend.herokuapp.com/api/users/me',
              headers: headers)
          .timeout(Duration(seconds: 5));

      var json = jsonDecode(response.body);
      print(json);
    } catch (e) {
      print(e);
    }
  }

  Future userInfo(String token, AuthSettings authSettings) async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };

      http.Response response = await http
          .get('https://localhelper-backend.herokuapp.com/api/users/me',
              headers: headers)
          .timeout(Duration(seconds: 5));

      var json = jsonDecode(response.body);

      // Update player info
      int _id = json['id'];
      String _first = json['first'];
      String _last = json['last'];
      String _gender = json['gender'];
      String _phone = json['phone'];
      String _email = json['email'];

      authSettings.ownerId = _id;
      authSettings.first = _first;
      authSettings.last = _last;
      authSettings.gender = _gender;
      authSettings.phone = _phone;
      authSettings.email = _email;
    } catch (e) {
      print(e);
    }
  }

  Future signIn(String email, String password) async {
    // Flutter Json
    Map<String, String> jsonMap = {
      'email': email,
      'password': password,
    };

    // Encode
    String jsonString = json.encode(jsonMap);

    // Try sending the info
    try {
      var response = await http.post(
        'https://localhelper-backend.herokuapp.com/api/auth/login',
        headers: {"Content-Type": "application/json"},
        body: jsonString,
      );

      // Error
      if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
        });
        print(response.statusCode.toString());
        return null;
      } else {
        setState(() {
          _isLoading = false;
        });
        return jsonDecode(response.body)['accessToken'];
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      return null;
    }
  }
}
