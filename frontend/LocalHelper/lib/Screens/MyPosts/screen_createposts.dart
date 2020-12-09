import 'dart:convert';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:smart_select/smart_select.dart';

class ScreenCreatePosts extends StatefulWidget {
  @override
  _ScreenCreatePostsState createState() => _ScreenCreatePostsState();
}

class _ScreenCreatePostsState extends State<ScreenCreatePosts> {
// VARIABLES ===================================================================

  // Text Controllers
  final titleController = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  // Prevent Multi sending
  bool enableSend = true;
  bool request = false;
  bool free = false;

  // Language Selection
  List<String> languageSelect = [];
  List<S2Choice<String>> languages = [
    S2Choice<String>(value: "English", title: 'English'),
    S2Choice<String>(value: "Spanish", title: 'Española'),
    S2Choice<String>(value: "Chinese", title: '中文'),
    S2Choice<String>(value: "Hindi", title: 'हिंदी'),
    S2Choice<String>(value: "Arabic", title: 'عربى'),
    S2Choice<String>(value: "Bengali", title: 'বাংলা'),
    S2Choice<String>(value: "Portuguese", title: 'Português'),
    S2Choice<String>(value: "Russian", title: 'русский'),
    S2Choice<String>(value: "Japanese", title: '日本人'),
  ];

  // Categories
  List<String> tags = [];
  List<String> options = [
    'Teaching',
    'Shopping',
    'Entertainment',
    'Repair',
    'Delivery',
    'Babysitting',
    'Tech Support',
    'Coaching',
    'Other',
  ];

// =============================================================================
// FUNCTIONS ===================================================================

  @override
  void dispose() {
    titleController.dispose();
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<bool> sendPost(String token, String title, String address, String desc,
      bool request, bool free, AuthSettings authSettings) async {
    List<String> _zip = authSettings.zip.split(' ');

    if (desc.isEmpty) desc = "No Description.";
    if (address.isEmpty) address = "No Address.";
    if (title.isEmpty) title = "No Title.";

    String jsonString = json.encode({
      'title': title,
      'address': address,
      'description': desc,
      'is_request': request,
      'free': free,
      'zips': _zip,
      'languages': languageSelect,
      'categories': tags,
    });

    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      var response = await http.post(
        'https://localhelper-backend.herokuapp.com/api/posts',
        headers: headers,
        body: jsonString,
      );

      print(response.statusCode);
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
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
            "Languages (Optional)",
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

  // Categories
  Widget categoryDrop(Settings settings) {
    return Column(
      children: [
        // Text
        Text(
          "Select Categories (Optional)",
          style: TextStyle(
            color: settings.darkMode ? settings.colorBlue : Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Categories
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ChipsChoice<String>.multiple(
            choiceActiveStyle: C2ChoiceStyle(
              brightness: Brightness.dark,
              color: settings.darkMode ? settings.colorBlue : Colors.black,
              labelStyle: TextStyle(
                  color: settings.darkMode
                      ? settings.colorBackground
                      : Colors.white),
            ),
            choiceStyle: C2ChoiceStyle(
              color: settings.darkMode ? settings.colorBackground : Colors.grey,
              brightness: Brightness.dark,
            ),
            scrollPhysics: BouncingScrollPhysics(),
            value: tags,
            onChanged: (val) {
              setState(() {
                tags = val;
              });
            },
            choiceItems: C2Choice.listFrom<String, String>(
              source: options,
              value: (i, v) => v,
              label: (i, v) => v,
            ),
          ),
        ),
      ],
    );
  }

// =============================================================================
// MAIN ========================================================================

  @override
  Widget build(BuildContext context) {
    // Providers
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: settings.darkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(
            color: settings.darkMode
                ? Colors.white
                : Colors.black, //change your color here
          ),
          centerTitle: true,
          title: Text(
            'Create New Post',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: settings.darkMode ? settings.colorBlue : Colors.black),
          ),
          backgroundColor:
              settings.darkMode ? settings.colorBackground : Colors.transparent,
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
              // Title
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: titleController,
                  cursorColor: settings.darkMode ? Colors.white : Colors.black,
                  keyboardType: TextInputType.name,
                  style: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                      color:
                          settings.darkMode ? settings.colorBlue : Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Ex: Babysitting, Tutor, Cleanup ...',
                    hintStyle: TextStyle(
                        fontSize: 20,
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // Address
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: addressController,
                  cursorColor: settings.darkMode ? Colors.white : Colors.black,
                  keyboardType: TextInputType.name,
                  style: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(
                      color:
                          settings.darkMode ? settings.colorBlue : Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Ex: 3123 Main Street ...',
                    hintStyle: TextStyle(
                        fontSize: 20,
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // Request
              SizedBox(height: 15),
              SwitchListTile(
                title: Text(
                  'Request',
                  style: TextStyle(
                      color:
                          settings.darkMode ? settings.colorBlue : Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                value: request,
                onChanged: (value) {
                  setState(() {
                    request = !request;
                  });
                },
              ),

              // Free?
              SwitchListTile(
                title: Text(
                  'Free',
                  style: TextStyle(
                      color:
                          settings.darkMode ? settings.colorBlue : Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                value: free,
                onChanged: (value) {
                  setState(() {
                    free = !free;
                  });
                },
              ),

              // Language
              languageDrop(settings),

              SizedBox(height: 10),
              // Description
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  minLines: 4,
                  maxLines: 6,
                  cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                  style: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color:
                          settings.darkMode ? settings.colorBlue : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              // Categories
              SizedBox(height: 20),
              categoryDrop(settings),

              // Submit Button
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    verticalDirection: VerticalDirection.up,
                    children: [
                      FlatButton(
                        onPressed: () async {
                          if (enableSend) {
                            setState(() {
                              enableSend = false;
                            });
                            if (titleController.text.isEmpty &&
                                descriptionController.text.isEmpty) {
                              Navigator.pop(context, null);
                            } else {
                              // Send post to internet.
                              var result = await sendPost(
                                  authSettings.token,
                                  titleController.text,
                                  addressController.text,
                                  descriptionController.text,
                                  request,
                                  free,
                                  authSettings);
                              if (result) {
                                settings.refreshPage();
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  enableSend = true;
                                });
                              }
                            }
                          }
                        },
                        splashColor:
                            settings.darkMode ? Colors.red : Colors.black,
                        highlightColor:
                            settings.darkMode ? Colors.red : Colors.grey,
                        minWidth: double.infinity,
                        height: 60,
                        child: enableSend
                            ? Text(
                                'Submit',
                                style: TextStyle(
                                  color: settings.darkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
