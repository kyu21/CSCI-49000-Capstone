import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:smart_select/smart_select.dart';

class ScreenUserSettings extends StatefulWidget {
  @override
  _ScreenUserSettingsState createState() => _ScreenUserSettingsState();
}

class _ScreenUserSettingsState extends State<ScreenUserSettings> {
  // Json info
  var info;
  List<String> languageSelect = [];

  Future getOwnerDetails(String token) async {
    try {
      Map<String, String> headers = {
        'authorization': token,
      };
      String link = 'https://localhelper-backend.herokuapp.com/api/users/me';
      var result = await http.get(link, headers: headers);
      info = jsonDecode(result.body);

      // Add Languages
      for (int i = 0; i < info['languages'].length; i++) {
        languageSelect.add(info['languages'][i]['name']);
      }
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
          return OwnerDone(info, authSettings, languageSelect);
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
  final List<String> languageSelect;
  OwnerDone(this.info, this.authSettings, this.languageSelect);
  @override
  _OwnerDoneState createState() =>
      _OwnerDoneState(this.info, authSettings, languageSelect);
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
  bool _zipWrong = false;
  bool _noLang = false;

  // Language Selection
  List<String> languageSelect;
  List<S2Choice<String>> languages = [
    S2Choice<String>(value: "English", title: 'English'),
    S2Choice<String>(value: "Spanish", title: 'Española'),
    S2Choice<String>(value: "Chinese", title: '中文'),
    S2Choice<String>(value: "Hindi", title: 'हिंदी'),
    S2Choice<String>(value: "Arabic", title: 'عربى'),
    S2Choice<String>(value: "Bengali", title: 'বাংলা'),
    S2Choice<String>(value: "Portuguese", title: 'Português'),
    S2Choice<String>(value: "Russian", title: 'русский'),
    S2Choice<String>(value: "Japanese", title: '日本語'),
  ];

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
  _OwnerDoneState(this.info, AuthSettings authSettings, List<String> lang) {
    firstNController.text = info['first'];
    lastNController.text = info['last'];
    genderController.text = info['gender'];
    phoneController.text = info['phone'];
    emailController.text = info['email'];
    zipController.text = info['zips'].last['zip'];
    languageSelect = lang;
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

  // Languages
  Widget languageDrop(Settings settings) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "Languages",
            style: TextStyle(
              color: settings.darkMode ? settings.colorBlue : Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SmartSelect<String>.multiple(
            title: "",
            placeholder: "",
            modalType: S2ModalType.popupDialog,
            modalHeader: true,
            modalTitle: "Pick a Language",
            value: languageSelect,
            choiceItems: languages,
            onChange: (state) {
              setState(() {
                languageSelect = state.value;
              });
            },
          ),
        ),
      ],
    );
  }

  // Warning
  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Could Not Save Info."),
      content: Container(
        child: FittedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("One Field is Empty."),
              SizedBox(height: 10),
              if (_zipWrong) Text("Zip isn't atleast 5 numbers."),
              SizedBox(height: 10),
              if (_noLang) Text("Select atleast ONE language."),
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

// Save button function
  Widget saveButton(Settings settings, AuthSettings authSettings) {
    return FlatButton(
      color: _loading ? Colors.transparent : settings.colorMiddle,
      height: 60,
      minWidth: double.infinity,
      onPressed: () async {
        if (firstNController.text.isEmpty ||
            lastNController.text.isEmpty ||
            genderController.text.isEmpty ||
            phoneController.text.isEmpty ||
            emailController.text.isEmpty ||
            zipController.text.isEmpty ||
            zipController.text.length < 5 ||
            languageSelect.isEmpty) {
          setState(() {
            _zipWrong = zipController.text.length < 5 ? true : false;
            _noLang = languageSelect.isEmpty ? true : false;
            _loading = false;
            showAlertDialog(context);
          });
        } else {
          setState(() {
            _loading = true;
          });

          // User Input
          List<String> _zipArray = zipController.text.split(" ");

          // User Info
          String infoString = json.encode({
            'first': firstNController.text,
            'last': lastNController.text,
            'gender': genderController.text,
            'phone': phoneController.text,
            'email': emailController.text,
            'zips': _zipArray,
            'languages': languageSelect,
          });

          // Header
          Map<String, String> headers = {
            'authorization': authSettings.token,
            "Content-Type": "application/json",
          };

          // Links
          String userLink =
              'https://localhelper-backend.herokuapp.com/api/users';

          try {
            // Update Info
            var infoResponse =
                await http.put(userLink, headers: headers, body: infoString);

            print(infoResponse.statusCode);

            if (infoResponse.statusCode == 200) {
              // Update info
              authSettings.updateFirst(firstNController.text);
              authSettings.updateLast(lastNController.text);
              authSettings.updateGender(genderController.text);
              authSettings.updatePhone(phoneController.text);
              authSettings.updateEmail(emailController.text);
              authSettings.updateZip(zipController.text);
              authSettings.setLanguage(languageSelect);
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
        }
      },
      child: _loading
          ? CircularProgressIndicator()
          : Text(
              'Save',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color:
                    settings.darkMode ? settings.colorBackground : Colors.black,
              ),
            ),
    );
  }

  // Save button function
  Widget deleteButton(Settings settings, AuthSettings authSettings) {
    return FlatButton(
      color: _loading ? Colors.transparent : settings.colorOpposite,
      height: 60,
      minWidth: double.infinity,
      onPressed: () async {
        bool answer = await _showMyDialog();

        if (answer) {
          try {
            setState(() {
              _loading = true;
            });

            // Header
            Map<String, String> headers = {
              'authorization': authSettings.token,
              "Content-Type": "application/json",
            };
            String link = 'https://localhelper-backend.herokuapp.com/api/users';
            var result = await http.delete(link, headers: headers);
            if (result.statusCode == 204) {
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
          ? Container()
          : Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color:
                    settings.darkMode ? settings.colorBackground : Colors.black,
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
          brightness: Brightness.dark,
          iconTheme: IconThemeData(
            color: settings.darkMode
                ? Colors.white
                : Colors.black, //change your color here
          ),
          backgroundColor:
              settings.darkMode ? settings.colorBackground : Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'User Settings',
            style: TextStyle(
              color: settings.darkMode ? settings.colorBlue : Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: ListView(
                    children: [
                      // First Name
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: firstNController,
                          cursorColor:
                              settings.darkMode ? Colors.white : Colors.grey,
                          keyboardType: TextInputType.name,
                          style: TextStyle(
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                              color: settings.darkMode
                                  ? settings.colorBlue
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

                      // Last Name
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: lastNController,
                          cursorColor:
                              settings.darkMode ? Colors.white : Colors.grey,
                          keyboardType: TextInputType.name,
                          style: TextStyle(
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(
                              color: settings.darkMode
                                  ? settings.colorBlue
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

                      // Gender
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: genderController,
                          cursorColor:
                              settings.darkMode ? Colors.white : Colors.grey,
                          style: TextStyle(
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            labelStyle: TextStyle(
                              color: settings.darkMode
                                  ? settings.colorBlue
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

                      // Phone
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: phoneController,
                          cursorColor:
                              settings.darkMode ? Colors.white : Colors.grey,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            labelStyle: TextStyle(
                              color: settings.darkMode
                                  ? settings.colorBlue
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

                      // Email
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: emailController,
                          cursorColor:
                              settings.darkMode ? Colors.white : Colors.grey,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: settings.darkMode
                                  ? settings.colorBlue
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

                      // Zip
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: zipController,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9 ]')),
                          ],
                          cursorColor:
                              settings.darkMode ? Colors.white : Colors.grey,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Zip',
                            labelStyle: TextStyle(
                              color: settings.darkMode
                                  ? settings.colorBlue
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
                      SizedBox(height: 15),
                      languageDrop(settings),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              Container(
                child: Column(
                  children: [
                    saveButton(settings, authSettings),
                    deleteButton(settings, authSettings),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
