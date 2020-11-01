// Screen for viewing the posts in full screen.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:localhelper/Additions/settings.dart';
import 'package:provider/provider.dart';

class ScreenPostsFull extends StatefulWidget {
  // Variables
  final int ownerId;
  ScreenPostsFull(this.ownerId);

  @override
  _ScreenPostsFullState createState() => _ScreenPostsFullState();
}

class _ScreenPostsFullState extends State<ScreenPostsFull> {
  // Json info
  var info;

  // Get details
  Future getOwnerDetails() async {
    try {
      String link = 'https://localhelper-backend.herokuapp.com/api/posts' +
          '/' +
          widget.ownerId.toString();
      var result = await http.get(link);
      info = jsonDecode(result.body);
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getOwnerDetails(),
      builder: (context, mywidget) {
        // When  not connected
        if (mywidget.connectionState == ConnectionState.none) {
          return FullNone();

          // When loading
        } else if (mywidget.connectionState == ConnectionState.waiting) {
          return FullWait();

          // When finished
        } else if (mywidget.connectionState == ConnectionState.done) {
          return FullDone(info);
        }

        // Failsafe
        return FullNone();
      },
    );
  }
}

class FullNone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner not found!'),
      ),
    );
  }
}

class FullWait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class FullDone extends StatelessWidget {
  final info;
  FullDone(this.info);

  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);

    final title = info['post']['title'];
    final ownerName = info['owner']['first'] + ' ' + info['owner']['last'];
    final date = info['post']['dateCreated'];
    final description = info['post']['description'];

    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: settings.darkMode
              ? Colors.white
              : Colors.black, //change your color here
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: settings.darkMode ? Colors.white : Colors.black,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Owner/Date
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Owner: ' + ownerName,
                      style: TextStyle(
                        color: settings.darkMode ? Colors.white : Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Date: ' + date,
                      style: TextStyle(
                        color: settings.darkMode ? Colors.white : Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Description
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description:',
                      style: TextStyle(
                        color: settings.darkMode ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      description,
                      style: TextStyle(
                        color: settings.darkMode ? Colors.white : Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
