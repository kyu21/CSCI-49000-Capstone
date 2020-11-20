import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ScreenRegister extends StatefulWidget {
  @override
  _ScreenRegisterState createState() => _ScreenRegisterState();
}

class _ScreenRegisterState extends State<ScreenRegister> {
// VARIABLES ===================================================================

  // Controller
  TextEditingController firstController = TextEditingController();
  TextEditingController lastController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();

  // Lock
  bool _isLoading = false;
  bool _hidePass = true;
  bool _hideConPass = true;
  bool _notSame = false;

// =============================================================================
// FUNCTIONS ===================================================================

  // Initialize
  @override
  void dispose() {
    firstController.dispose();
    lastController.dispose();
    genderController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    conPasswordController.dispose();
    super.dispose();
  }

  // Submit Button
  void submitInfo(String first, String last, String gender, String phone,
      String email, String password) async {
    if ((firstController.text.isEmpty ||
            lastController.text.isEmpty ||
            genderController.text.isEmpty ||
            phoneController.text.isEmpty ||
            emailController.text.isEmpty ||
            passwordController.text.isEmpty) ||
        (passwordController.text != conPasswordController.text)) {
      setState(() {
        _isLoading = false;
        if (passwordController.text != conPasswordController.text)
          _notSame = true;
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
        // Send new data to database
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

// =============================================================================
// WIDGETS =====================================================================

// Holds all the text in a column
  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(top: 30.0),
      child: Column(
        children: [
          txtSection(
              "First Name", Icons.person, firstController, TextInputType.name),
          SizedBox(height: 30.0),
          txtSection(
              "Last Name", Icons.person, lastController, TextInputType.name),
          SizedBox(height: 30.0),
          txtSection(
              "Gender", Icons.person, genderController, TextInputType.name),
          SizedBox(height: 30.0),
          txtSection(
              "Phone", Icons.phone, phoneController, TextInputType.phone),
          SizedBox(height: 30.0),
          txtSection("Email", Icons.email, emailController,
              TextInputType.emailAddress),
          SizedBox(height: 30.0),
          passSection("Password", Icons.lock, passwordController),
          SizedBox(height: 30.0),
          passConSection("Confirm Password", Icons.lock, conPasswordController),
        ],
      ),
    );
  }

  // Normal Text input
  TextFormField txtSection(String title, IconData icons,
      TextEditingController control, TextInputType type) {
    return TextFormField(
      controller: control,
      keyboardType: type,
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.white70),
        icon: Icon(icons),
      ),
    );
  }

  // Password Input
  TextFormField passSection(
      String title, IconData icons, TextEditingController control) {
    return TextFormField(
      obscureText: _hidePass,
      controller: control,
      style: TextStyle(color: _notSame ? Colors.red : Colors.white70),
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

  // Confirm Password
  TextFormField passConSection(
      String title, IconData icons, TextEditingController control) {
    return TextFormField(
      obscureText: _hideConPass,
      controller: control,
      style: TextStyle(color: _notSame ? Colors.red : Colors.white70),
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.white70),
        icon: Icon(icons),
        suffixIcon: IconButton(
          icon: Icon(Icons.remove_red_eye),
          color: _hidePass ? Colors.black87 : Colors.grey,
          onPressed: () {
            setState(() {
              _hideConPass = !_hideConPass;
            });
          },
        ),
      ),
    );
  }

  // Top part
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

// =============================================================================
// MAIN ========================================================================

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
                    SizedBox(height: 5),
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
}