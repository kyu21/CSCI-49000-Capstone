import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smart_select/smart_select.dart';

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
  TextEditingController zipController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();

  // Lock
  bool _isLoading = false;
  bool _hidePass = true;
  bool _hideConPass = true;
  bool _notSame = false;
  bool _zipWrong = false;

  // Language Selection
  List<String> languageSelect = ["English"];
  List<S2Choice<String>> languages = [
    S2Choice<String>(value: "English", title: 'English'),
    S2Choice<String>(value: "Spanish", title: 'Española'),
    S2Choice<String>(value: "Chinese", title: '中文'),
  ];

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
    zipController.dispose();
    passwordController.dispose();
    conPasswordController.dispose();
    super.dispose();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Could Not Create User"),
      content: Container(
        child: FittedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("One Field is Empty."),
              SizedBox(height: 10),
              if (_notSame) Text("Passwords Don't Match."),
              SizedBox(height: 10),
              if (_zipWrong) Text("Zip isn't atleast 5 numbers."),
            ],
          ),
        ),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Submit Button
  void submitInfo(String first, String last, String gender, String phone,
      String email, String zip, String password, List<String> lang) async {
    if ((firstController.text.isEmpty ||
            lastController.text.isEmpty ||
            genderController.text.isEmpty ||
            phoneController.text.isEmpty ||
            emailController.text.isEmpty ||
            passwordController.text.isEmpty) ||
        zipController.text.isEmpty ||
        (passwordController.text != conPasswordController.text)) {
      setState(() {
        _isLoading = false;
        if (passwordController.text != conPasswordController.text)
          _notSame = true;
        if (zipController.text.length < 5) _zipWrong = true;
      });

      if (passwordController.text == conPasswordController.text)
        _notSame = false;
      if (zipController.text.length >= 5) _zipWrong = false;

      print('Empty Strings');
      showAlertDialog(context);
    } else {
      List<String> _zipArray = zip.split(" ");

      // Flutter Json
      // Encode
      String jsonString = json.encode({
        'first': first,
        'last': last,
        'gender': gender,
        'phone': phone,
        'zips': _zipArray,
        'languages': lang,
        'email': email,
        'password': password,
      });

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

  // Languages
  Widget languageDrop() {
    return SmartSelect<String>.multiple(
      modalType: S2ModalType.popupDialog,
      title: 'Languages (Optional)',
      value: languageSelect,
      choiceItems: languages,
      onChange: (state) {
        setState(() {
          languageSelect = state.value;
        });
      },
    );
  }

// Holds all the text in a column
  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(top: 30.0),
      child: Column(
        children: [
          txtSection("First Name", "", Icons.person, firstController,
              TextInputType.name),
          SizedBox(height: 30.0),
          txtSection("Last Name", "", Icons.person, lastController,
              TextInputType.name),
          SizedBox(height: 30.0),
          txtSection(
              "Gender", "", Icons.person, genderController, TextInputType.name),
          SizedBox(height: 30.0),
          txtSection("Phone", "ex: 123-321-1123", Icons.phone, phoneController,
              TextInputType.phone),
          SizedBox(height: 30.0),
          txtSection("Email", "ex: test@gmail.com", Icons.email,
              emailController, TextInputType.emailAddress),
          SizedBox(height: 30.0),
          zipSection("Zips (Optional)", Icons.house, zipController,
              TextInputType.number),
          SizedBox(height: 30.0),
          passSection("Password", Icons.lock, passwordController),
          SizedBox(height: 30.0),
          passConSection("Confirm Password", Icons.lock, conPasswordController),
        ],
      ),
    );
  }

  // Normal Text input
  TextFormField txtSection(String title, String hintT, IconData icons,
      TextEditingController control, TextInputType type) {
    return TextFormField(
      controller: control,
      keyboardType: type,
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        labelText: title,
        labelStyle:
            TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        alignLabelWithHint: true,
        hintText: hintT,
        hintStyle: TextStyle(color: Colors.grey),
        icon: Icon(icons),
      ),
    );
  }

  // Zip
  TextFormField zipSection(String title, IconData icons,
      TextEditingController control, TextInputType type) {
    return TextFormField(
      controller: control,
      keyboardType: type,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
      ],
      style: TextStyle(color: _zipWrong ? Colors.red : Colors.white70),
      decoration: InputDecoration(
        labelText: title,
        labelStyle:
            TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        alignLabelWithHint: true,
        hintText: 'ex: 11323 11232 ...',
        hintStyle: TextStyle(color: Colors.grey),
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
        labelText: title,
        labelStyle:
            TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
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
        labelText: title,
        labelStyle:
            TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
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

                    SizedBox(height: 20),
                    languageDrop(),

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
                              zipController.text,
                              passwordController.text,
                              languageSelect);
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Text('Submit',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    SizedBox(height: 30.0),
                  ],
                ),
        ),
      ),
    );
  }
}
