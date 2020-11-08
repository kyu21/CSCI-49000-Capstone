// Screen for viewing the posts in full screen.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localhelper/Additions/authSettings.dart';
import 'dart:convert';

import 'package:localhelper/Additions/settings.dart';
import 'package:localhelper/Additions/users.dart';
import 'package:localhelper/Screens/MainPages/MyPosts/screen_editposts.dart';
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
  bool interested = false;
  var interestJson;

  // Get details
  Future getOwnerDetails(AuthSettings authSettings) async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': authSettings.token,
      };
      String link = 'https://localhelper-backend.herokuapp.com/api/posts' +
          '/' +
          widget.ownerId.toString();
      var result = await http.get(link, headers: headers);
      info = jsonDecode(result.body)[0];

      // GET A LIST OF INTERESTED PEOPLE
      String interLink =
          'https://localhelper-backend.herokuapp.com/api/postInterests/' +
              '/' +
              widget.ownerId.toString();

      var interestResult = await http.get(interLink, headers: headers);
      interestJson = jsonDecode(interestResult.body);

      for (int i = 0; i < interestJson.length; i++) {
        if (interestJson[i]['id'] == authSettings.ownerId) {
          interested = true;
          break;
        }
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
      future: getOwnerDetails(authSettings),
      builder: (context, mywidget) {
        // When  not connected
        if (mywidget.connectionState == ConnectionState.none) {
          return FullNone();

          // When loading
        } else if (mywidget.connectionState == ConnectionState.waiting) {
          return FullWait();

          // When finished
        } else if (mywidget.connectionState == ConnectionState.done) {
          return FullDone(info, interested, interestJson);
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
        title: Text('Post Not Found!'),
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

class FullDone extends StatefulWidget {
  final info;
  final bool interested;
  final interestJson;
  FullDone(this.info, this.interested, this.interestJson);

  @override
  _FullDoneState createState() => _FullDoneState(interested, interestJson);
}

class _FullDoneState extends State<FullDone> {
  bool interested;
  var interestJson;
  _FullDoneState(this.interested, this.interestJson);
  @override
  Widget build(BuildContext context) {
    //
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);

    // Names
    final title = widget.info['post']['title'];
    final ownerName =
        widget.info['owner']['first'] + ' ' + widget.info['owner']['last'];
    final description = widget.info['post']['description'];
    final ownerId = widget.info['owner']['id'];
    final postId = widget.info['post']['id'];

    // Owner checker
    final bool isOwners = ownerId == authSettings.ownerId ? true : false;

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
        title: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            title,
            style: TextStyle(
              color: settings.darkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
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
                    // Text(
                    //   'Date: ' + date,
                    //   style: TextStyle(
                    //     color: settings.darkMode ? Colors.white : Colors.black,
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
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
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      'Description:',
                      style: TextStyle(
                        color: settings.darkMode ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      constraints: BoxConstraints(
                          minHeight: 80,
                          maxHeight: interestJson.length > 0 ? 200 : 400),
                      child: SingleChildScrollView(
                        child: Text(
                          description,
                          style: TextStyle(
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),

                    // Interested Users
                    if (interestJson.length > 0)
                      Expanded(
                        child: Container(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Interested Users:',
                                  style: TextStyle(
                                    color: settings.darkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Expanded(
                                child: Container(
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Users(interestJson[index]);
                                    },
                                    itemCount: interestJson.length,
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
          ),

          if (isOwners)
            ownerWidgets(context, authSettings, widget.info)
          else
            interestedWidget(authSettings, settings, postId),
        ],
      ),
    );
  }

  Widget ownerWidgets(
      BuildContext context, AuthSettings authSettings, var info) {
    return Column(
      children: [
        // EditPosts
        FlatButton(
          color: Colors.green[300],
          height: 50,
          minWidth: double.infinity,
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
              final int pId = info['post']['id'];
              final title = info['post']['title'];
              final des = info['post']['description'];
              final req = info['post']['is_request'];
              return ScreenEditPosts(pId, title, des, req);
            }));
            Navigator.pop(context, true);
          },
          child: Text(
            'Edit',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Delete Posts
        FlatButton(
          color: Colors.red[300],
          height: 50,
          minWidth: double.infinity,
          onPressed: () async {
            try {
              Map<String, String> headers = {
                'content-type': 'application/json',
                'accept': 'application/json',
                'authorization': authSettings.token,
              };
              String link =
                  'https://localhelper-backend.herokuapp.com/api/posts' +
                      '/' +
                      info['post']['id'].toString();
              var result = await http.delete(link, headers: headers);
              if (result.statusCode == 200) {
                Navigator.pop(context, true);
              }
            } catch (e) {
              print(e);
              Navigator.pop(context);
            }
          },
          child: Text(
            'Delete',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget interestedWidget(
      AuthSettings authSettings, Settings settings, var postId) {
    return Container(
      height: 100,
      child: Center(
        heightFactor: double.infinity,
        widthFactor: double.infinity,
        child: SwitchListTile(
          value: interested,
          onChanged: (value) async {
            interested =
                await toggleInterests(authSettings, postId, interested);
            setState(() {});
          },
          title: Text('Interested',
              style: TextStyle(
                  color: settings.darkMode ? Colors.white : Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // FUNCTIONS
  Future<bool> toggleInterests(
      AuthSettings authSettings, var postId, bool interested) async {
    try {
      // Header
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': authSettings.token,
      };

      // Remove user from interested list
      if (interested) {
        // Link
        String interLink =
            'https://localhelper-backend.herokuapp.com/api/postInterests/' +
                '/' +
                postId.toString();
        await http.delete(interLink, headers: headers);
        return false;
      }

      // Add user to interested list
      else {
        // Link
        String interLink =
            'https://localhelper-backend.herokuapp.com/api/postInterests/' +
                '/' +
                postId.toString();
        await http.post(interLink, headers: headers);
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
