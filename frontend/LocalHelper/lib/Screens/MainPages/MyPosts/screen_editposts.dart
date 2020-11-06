import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localhelper/Additions/authSettings.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ScreenEditPosts extends StatefulWidget {
  final int postId;
  final String title;
  final String description;
  final bool req;
  ScreenEditPosts(this.postId, this.title, this.description, this.req);
  @override
  _ScreenEditPostsState createState() =>
      _ScreenEditPostsState(title, description, req);
}

class _ScreenEditPostsState extends State<ScreenEditPosts> {
  // Text Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Prevent Multi sending
  bool enableSend = true;
  bool request;

  _ScreenEditPostsState(String title, String description, this.request) {
    titleController.text = title;
    descriptionController.text = description;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> sendPost(
      String token, String title, String desc, bool request) async {
    // Flutter Json
    Map<String, dynamic> jsonMap = {
      'title': title,
      'description': desc,
      'is_request': request,
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
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
  }

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

            SizedBox(height: 20),

            SwitchListTile(
              title: Text(
                'Request?',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              value: request,
              onChanged: (value) {
                setState(() {
                  request = !request;
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
                          await sendPost(
                              authSettings.token,
                              titleController.text,
                              descriptionController.text,
                              request);
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
    );
  }
}
