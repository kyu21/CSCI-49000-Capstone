import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ScreenCreatePosts extends StatefulWidget {
  @override
  _ScreenCreatePostsState createState() => _ScreenCreatePostsState();
}

class _ScreenCreatePostsState extends State<ScreenCreatePosts> {
// VARIABLES ===================================================================

  // Text Controllers
  final titleController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Prevent Multi sending
  bool enableSend = true;
  bool request = false;
  bool free = false;

// =============================================================================
// FUNCTIONS ===================================================================

  @override
  void dispose() {
    titleController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<bool> sendPost(String token, String title, String desc, bool request,
      bool free, AuthSettings authSettings) async {
    // Flutter Json
    Map<String, dynamic> jsonMap = {
      'title': title,
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
      var response = await http.post(
        'https://localhelper-backend.herokuapp.com/api/posts',
        headers: headers,
        body: jsonString,
      );

      // Error
      if (response.statusCode != 201) {
        print(response.statusCode.toString());
        return false;
      } else {
        // If the zip
        if (authSettings.zipID != -1) {
          var postId = await http.get(
            'https://localhelper-backend.herokuapp.com/api/posts/me',
            headers: headers,
          );

          var postIDJson = jsonDecode(postId.body).last;

          // Post the new zip
          Map<String, dynamic> jsonMap = {
            'postId': postIDJson['post']['id'],
            'zipId': authSettings.zipID,
          };

          // Encode
          String jsonString = json.encode(jsonMap);

          var result = await http.post(
            'https://localhelper-backend.herokuapp.com/api/postZips',
            headers: headers,
            body: jsonString,
          );

          print(result.statusCode);
        }

        return true;
      }
    } catch (e) {
      print(e);
      return false;
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
            'Create New Post',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: settings.darkMode ? Colors.white : Colors.black),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
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
                    color: settings.darkMode ? Colors.white : Colors.black,
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

            // Request
            SizedBox(height: 20),
            SwitchListTile(
              title: Text(
                'Request',
                style: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
                    fontSize: 30,
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
            SizedBox(height: 20),
            SwitchListTile(
              title: Text(
                'Free',
                style: TextStyle(
                    color: settings.darkMode ? Colors.white : Colors.black,
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

            SizedBox(height: 40),

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
                    color: settings.darkMode ? Colors.white : Colors.black,
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
                          if (titleController.text.isEmpty &&
                              descriptionController.text.isEmpty) {
                            Navigator.pop(context, null);
                          } else {
                            // Send post to internet.
                            var result = await sendPost(
                                authSettings.token,
                                titleController.text,
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
                      child: Text(
                        'Submit',
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
    );
  }
}
