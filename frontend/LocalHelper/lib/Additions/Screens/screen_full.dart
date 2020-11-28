// Screen for viewing the posts in full screen.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'dart:convert';

import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Additions/Widgets/users.dart';
import 'package:localhelper/Screens/MyPosts/screen_editposts.dart';
import 'package:provider/provider.dart';

class ScreenPostsFull extends StatefulWidget {
  // Variables
  final int postID;
  ScreenPostsFull(this.postID);

  @override
  _ScreenPostsFullState createState() => _ScreenPostsFullState();
}

class _ScreenPostsFullState extends State<ScreenPostsFull> {
// VARIABLES ===================================================================

  // Json info
  var info;
  bool interested = false;
  var interestJson;

// =============================================================================
// FUNCTIONS ===================================================================

  // Get details
  Future getFullDetails(AuthSettings authSettings) async {
    // Header
    Map<String, String> headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      'authorization': authSettings.token,
    };

    // URL
    String link = 'https://localhelper-backend.herokuapp.com/api/posts/' +
        widget.postID.toString();

    // API
    try {
      var result = await http.get(link, headers: headers);
      info = jsonDecode(result.body);
      interestJson = info['interests'];

      // Check if already interested
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

// =============================================================================
// MAIN ========================================================================

  @override
  Widget build(BuildContext context) {
    AuthSettings authSettings = Provider.of<AuthSettings>(context);

    return FutureBuilder(
      future: getFullDetails(authSettings),
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
// VARIABLES ===================================================================

  bool interested;
  var interestJson;

// =============================================================================
// FUNCTIONS ===================================================================

  // Constructor
  _FullDoneState(this.interested, this.interestJson);

  // Delete
  void deletePost(AuthSettings authSettings) async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': authSettings.token,
      };
      String link = 'https://localhelper-backend.herokuapp.com/api/posts/' +
          widget.info['id'].toString();
      await http.delete(link, headers: headers);
      Navigator.pop(context, true);
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  // Edit
  void editPosts(AuthSettings authSettings) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      final int pId = widget.info['id'];
      final title = widget.info['title'];
      final address = widget.info['address'];
      final des = widget.info['description'];
      final req = widget.info['is_request'];
      final free = widget.info['free'];
      return ScreenEditPosts(pId, title, address, des, req, free);
    }));
    Navigator.pop(context, true);
  }

  // Interests
  Future<bool> toggleInterests(
      AuthSettings authSettings, var postId, bool interested) async {
    // Header
    Map<String, String> headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      'authorization': authSettings.token,
    };

    // URL
    String url = 'https://localhelper-backend.herokuapp.com/api/posts/' +
        postId.toString() +
        '/interests';

    try {
      // Remove user from interested list
      if (interested) {
        await http.delete(url, headers: headers);
        return false;
      }

      // Add user to interested list
      else {
        await http.post(url, headers: headers);
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

// =============================================================================
// WIDGETS =====================================================================

  Widget ownerWidgets(BuildContext context, AuthSettings authSettings,
      Settings settings, var info) {
    return Column(
      children: [
        // EditPosts
        FlatButton(
          color: settings.colorMiddle,
          height: 50,
          minWidth: double.infinity,
          onPressed: () => editPosts(authSettings),
          child: Text(
            'Edit',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: settings.colorBackground),
          ),
        ),

        // Delete Posts
        FlatButton(
          color: settings.colorOpposite,
          height: 50,
          minWidth: double.infinity,
          onPressed: () => deletePost(authSettings),
          child: Text(
            'Delete',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: settings.colorBackground),
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
                  color: settings.darkMode ? settings.colorBlue : Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

// =============================================================================
// MAIN ========================================================================

  @override
  Widget build(BuildContext context) {
    //
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);

    // Names
    final title = widget.info['title'];
    final address = widget.info['address'];
    final ownerName =
        widget.info['owner']['first'] + ' ' + widget.info['owner']['last'];
    final description = widget.info['description'];
    final ownerId = widget.info['owner']['id'];
    final postId = widget.info['id'];

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
        backgroundColor:
            settings.darkMode ? settings.colorBackground : Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            title,
            style: TextStyle(
              color: settings.darkMode ? settings.colorBlue : Colors.black,
              fontWeight: FontWeight.bold,
            ),
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
                          color: settings.darkMode
                              ? settings.colorBlue
                              : Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (address != null) SizedBox(height: 30),
                      if (address != null)
                        Text(
                          'Address: ' + address,
                          style: TextStyle(
                            color: settings.darkMode
                                ? settings.colorBlue
                                : Colors.black,
                            fontSize: 25,
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
                          color: settings.darkMode
                              ? settings.colorBlue
                              : Colors.black,
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
                              color: settings.darkMode
                                  ? Colors.white
                                  : Colors.black,
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
                                          ? settings.colorBlue
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
              ownerWidgets(context, authSettings, settings, widget.info)
            else
              interestedWidget(authSettings, settings, postId),
          ],
        ),
      ),
    );
  }
}
