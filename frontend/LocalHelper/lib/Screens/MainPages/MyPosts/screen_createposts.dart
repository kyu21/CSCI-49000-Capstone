import 'package:flutter/material.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:localhelper/Screens/MainPages/MyPosts/personalPosts.dart';
import 'package:provider/provider.dart';

class ScreenCreatePosts extends StatefulWidget {
  @override
  _ScreenCreatePostsState createState() => _ScreenCreatePostsState();
}

class _ScreenCreatePostsState extends State<ScreenCreatePosts> {
  final titleController = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
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
          iconTheme: IconThemeData(color: Colors.black),
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
                cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                keyboardType: TextInputType.name,
                style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(
                    color: Colors.grey,
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

            SizedBox(height: 10),

            // Author
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: nameController,
                cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                keyboardType: TextInputType.name,
                style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            // Address
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: addressController,
                cursorColor: settings.darkMode ? Colors.white : Colors.grey,
                keyboardType: TextInputType.name,
                style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
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
                    color: Colors.grey,
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
                      onPressed: () {
                        if (titleController.text.isEmpty &&
                            descriptionController.text.isEmpty) {
                          Navigator.pop(context, null);
                        } else {
                          Navigator.pop(
                              context,
                              MyPosts(
                                titleController.text,
                                descriptionController.text,
                                nameController.text,
                                addressController.text,
                              ));
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
