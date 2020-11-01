import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ScreenCreatePosts extends StatefulWidget {
  @override
  _ScreenCreatePostsState createState() => _ScreenCreatePostsState();
}

class _ScreenCreatePostsState extends State<ScreenCreatePosts> {
  // Text Controllers
  final titleController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Prevent Multi sending
  bool enableSend = true;

  @override
  void dispose() {
    titleController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<bool> sendPost(String title, String desc) async {
    // Flutter Json
    Map<String, String> jsonMap = {
      'title': title,
      'description': desc,
    };

    // Encode
    String jsonString = json.encode(jsonMap);

    try {
      var response = await http.post(
        'https://localhelper-backend.herokuapp.com/api/posts/1',
        headers: {"Content-Type": "application/json"},
        body: jsonString,
      );

      // Error
      if (response.statusCode != 201) {
        print(response.statusCode.toString());
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Providers
    Settings settings = Provider.of<Settings>(context);

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

            SizedBox(height: 40),

            // // Author
            // Padding(
            //   padding: const EdgeInsets.only(left: 20, right: 20),
            //   child: TextField(
            //     controller: nameController,
            //     cursorColor: settings.darkMode ? Colors.white : Colors.grey,
            //     keyboardType: TextInputType.name,
            //     style: TextStyle(
            //       color: settings.darkMode ? Colors.white : Colors.black,
            //     ),
            //     decoration: InputDecoration(
            //       labelText: 'Name',
            //       labelStyle: TextStyle(
            //         color: Colors.grey,
            //         fontSize: 30,
            //         fontWeight: FontWeight.bold,
            //       ),
            //       enabledBorder: UnderlineInputBorder(
            //         borderSide: BorderSide(color: Colors.grey),
            //       ),
            //     ),
            //   ),
            // ),

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
                            var result = await sendPost(titleController.text,
                                descriptionController.text);
                            if (result) {
                              Navigator.pop(
                                context,
                              );
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
