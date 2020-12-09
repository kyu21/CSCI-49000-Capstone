import 'dart:convert';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:smart_select/smart_select.dart';

class ScreenEditPosts extends StatefulWidget {
  final int postId;
  final String title;
  final String address;
  final String description;
  final bool req;
  final bool free;
  final List<String> language;
  final List<String> categories;
  ScreenEditPosts(this.postId, this.title, this.address, this.description,
      this.req, this.free, this.language, this.categories);
  @override
  _ScreenEditPostsState createState() => _ScreenEditPostsState(
      title, address, description, req, free, language, categories);
}

class _ScreenEditPostsState extends State<ScreenEditPosts> {
// VARIABLES ===================================================================

  // Text Controllers
  final titleController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  // Prevent Multi sending
  bool enableSend = true;
  bool request;
  bool free;

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
    S2Choice<String>(value: "Japanese", title: '日本語'),
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
    'Cleaning',
    'Other',
  ];

// =============================================================================
// FUNCTIONS ===================================================================

  // Constructor
  _ScreenEditPostsState(String title, String address, String description,
      this.request, this.free, this.languageSelect, this.tags) {
    titleController.text = title;
    addressController.text = address;
    descriptionController.text = description;
  }

  @override
  void dispose() {
    titleController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> sendPost(String token, String title, String address, String desc,
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
      if (languageSelect.isNotEmpty) 'languages': languageSelect,
      if (tags.isNotEmpty) 'categories': tags,
    });

    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      var response = await http.put(
        'https://localhelper-backend.herokuapp.com/api/posts/' +
            widget.postId.toString(),
        headers: headers,
        body: jsonString,
      );

      print(languageSelect);
      print(tags);
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
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
            'Edit Post',
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
                            await sendPost(
                                authSettings.token,
                                titleController.text,
                                addressController.text,
                                descriptionController.text,
                                request,
                                free,
                                authSettings);
                          }
                          setState(() {
                            enableSend = true;
                          });
                        },
                        splashColor:
                            settings.darkMode ? Colors.red : Colors.black,
                        highlightColor:
                            settings.darkMode ? Colors.red : Colors.grey,
                        minWidth: double.infinity,
                        height: 60,
                        child: enableSend
                            ? Text(
                                'Save',
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
