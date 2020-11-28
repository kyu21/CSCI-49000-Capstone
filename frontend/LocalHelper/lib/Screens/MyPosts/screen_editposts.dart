import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ScreenEditPosts extends StatefulWidget {
  final int postId;
  final String title;
  final String address;
  final String description;
  final bool req;
  final bool free;
  ScreenEditPosts(this.postId, this.title, this.address, this.description,
      this.req, this.free);
  @override
  _ScreenEditPostsState createState() =>
      _ScreenEditPostsState(title, address, description, req, free);
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

// =============================================================================
// FUNCTIONS ===================================================================

  // Constructor
  _ScreenEditPostsState(String title, String address, String description,
      this.request, this.free) {
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
      bool request, bool free) async {
    // Flutter Json
    Map<String, dynamic> jsonMap = {
      'title': title,
      'address': address,
      'description': desc,
      'is_request': request,
      'free': free,
    };

    // Encode
    String jsonString = json.encode(jsonMap);

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
      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
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
                    hintStyle: TextStyle(fontSize: 20),
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
                    hintStyle: TextStyle(fontSize: 20),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // Request
              SizedBox(height: 20),
              SwitchListTile(
                title: Text(
                  'Request',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: settings.darkMode
                          ? settings.colorBlue
                          : Colors.black),
                ),
                value: request,
                onChanged: (value) {
                  setState(() {
                    request = !request;
                  });
                },
              ),

              // Free?
              SizedBox(height: 20),
              SwitchListTile(
                title: Text(
                  'Free',
                  style: TextStyle(
                      color:
                          settings.darkMode ? settings.colorBlue : Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                value: free,
                onChanged: (value) {
                  setState(() {
                    free = !free;
                  });
                },
              ),

              // Description
              SizedBox(height: 40),
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
                                free);
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
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
