import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ScreenRegister extends StatefulWidget {
  @override
  _ScreenRegisterState createState() => _ScreenRegisterState();
}

class _ScreenRegisterState extends State<ScreenRegister> {
  // Controllers
  TextEditingController firstController = TextEditingController();
  TextEditingController lastController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Lock
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                    SizedBox(height: 20),
                    Center(child: headerSection()),

                    // Text
                    textSection(),

                    // Submit
                    SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      margin: EdgeInsets.only(top: 30.0),
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });
                          submitInfo(
                              firstController.text,
                              lastController.text,
                              genderController.text,
                              phoneController.text,
                              emailController.text,
                              passwordController.text);
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Text('Submit',
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
          txtSection("First Name", Icons.email, firstController),
          SizedBox(height: 30.0),
          txtSection("Last Name", Icons.email, lastController),
          SizedBox(height: 30.0),
          txtSection("Gender", Icons.email, genderController),
          SizedBox(height: 30.0),
          txtSection("Phone", Icons.email, phoneController),
          SizedBox(height: 30.0),
          txtSection("Email", Icons.email, emailController),
          SizedBox(height: 30.0),
          txtSection("Password", Icons.lock, passwordController),
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

  Container headerSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Text(
        "Register Account",
        style: TextStyle(
          fontSize: 35,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==============================================================

  // FUNCTIONS ===================================================

  void submitInfo(String first, String last, String gender, String phone,
      String email, String password) async {
    if (firstController.text.isEmpty ||
        lastController.text.isEmpty ||
        genderController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      print('Empty Strings');
    } else {
      // Flutter Json
      Map<String, String> jsonMap = {
        'first': first,
        'last': last,
        'gender': gender,
        'phone': phone,
        'email': email,
        'password': password,
      };

      // Encode
      String jsonString = json.encode(jsonMap);

      // Try sending the info
      try {
        var response = await http.post(
          'https://localhelper-backend.herokuapp.com/api/auth/register',
          headers: {"Content-Type": "application/json"},
          body: jsonString,
        );

        // Error
        if (response.statusCode != 201) {
          setState(() {
            _isLoading = false;
          });
          print(response.statusCode.toString());
        } else {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print(e);
      }
    }
  }
}
