import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';

class ScreenOwner extends StatefulWidget {
  // Variables
  final int ownerId;
  ScreenOwner(this.ownerId);

  @override
  _ScreenOwnerState createState() => _ScreenOwnerState();
}

class _ScreenOwnerState extends State<ScreenOwner> {
  // Json info
  var info;

  Future getOwnerDetails(String token) async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      String link = 'https://localhelper-backend.herokuapp.com/api/users' +
          '/' +
          widget.ownerId.toString();
      var result = await http.get(link, headers: headers);
      info = jsonDecode(result.body);
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    return FutureBuilder(
      future: getOwnerDetails(authSettings.token),
      builder: (context, snapshot) {
        // When  not connected
        if (snapshot.connectionState == ConnectionState.none) {
          return OwnerNone();

          // When loading
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return OwnerWait();

          // When finished
        } else if (snapshot.connectionState == ConnectionState.done) {
          return OwnerDone(info);
        }

        // Failsafe
        return OwnerNone();
      },
    );
  }
}

class OwnerNone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Owner not found!'),
      ),
    );
  }
}

class OwnerWait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class OwnerDone extends StatelessWidget {
// VARIABLES ===================================================================

// =============================================================================
// FUNCTIONS ===================================================================

  void makeConvo(BuildContext context) async {
    try {
      String userId = info['id'].toString();
      final String token =
          Provider.of<AuthSettings>(context, listen: false).token;
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      // userId is the person you are talking to
      String link =
          'https://localhelper-backend.herokuapp.com/api/users/convos/' +
              userId;
      // Http Post
      await http.post(link,
          headers: headers, body: []).timeout(Duration(seconds: 20));

      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

// =============================================================================
// WIDGETS =====================================================================

  Widget convoButton(BuildContext context, Settings settings) {
    return FlatButton(
      color: settings.darkMode ? settings.colorMiddle : Colors.grey,
      height: 60,
      minWidth: double.infinity,
      child: Text(
        'Create Conversation',
        style: TextStyle(fontSize: 30, color: settings.colorBackground),
      ),
      onPressed: () {
        makeConvo(context);
      },
    );
  }

  Widget infoList(Settings settings) {
    return Expanded(
      child: Container(
        child: ListView(
          children: [
            // Gender
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Icon(
                        Icons.family_restroom,
                        size: 20,
                        color: settings.darkMode
                            ? settings.colorBlue
                            : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Gender: ' + info['gender'],
                      style: TextStyle(
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Phone
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Icon(
                        Icons.phone,
                        size: 20,
                        color: settings.darkMode
                            ? settings.colorBlue
                            : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Phone: ' + info['phone'],
                      style: TextStyle(
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Email
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Icon(
                        Icons.email,
                        size: 20,
                        color: settings.darkMode
                            ? settings.colorBlue
                            : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Email: ' + info['email'],
                      style: TextStyle(
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Zip
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Icon(
                        Icons.house,
                        size: 20,
                        color: settings.darkMode
                            ? settings.colorBlue
                            : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Main Zip:',
                      style: TextStyle(
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: info['zips'].length > 0
                  ? Text(
                      info['zips'].last['zip'],
                      style: TextStyle(
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.black,
                        fontSize: 30,
                      ),
                    )
                  : Text(
                      'None',
                      style: TextStyle(
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.black,
                        fontSize: 30,
                      ),
                    ),
            ),

            // Languages
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Icon(
                        Icons.contact_mail,
                        size: 20,
                        color: settings.darkMode
                            ? settings.colorBlue
                            : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Languages: ',
                      style: TextStyle(
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: info['languages'].length,
                itemBuilder: (context, index) {
                  if (info['languages'].length > 0) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        info['languages'][index]['name'],
                        style: TextStyle(
                          color: settings.darkMode
                              ? settings.colorMiddle
                              : Colors.black,
                          fontSize: 30,
                        ),
                      ),
                    );
                  } else {
                    return Text('None');
                  }
                },
              ),
            ),

            // Posts
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Icon(
                        Icons.contact_mail,
                        size: 20,
                        color: settings.darkMode
                            ? settings.colorBlue
                            : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Posts: ',
                      style: TextStyle(
                        color: settings.darkMode
                            ? settings.colorMiddle
                            : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Posts List
            Container(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: info['posts'].length,
                itemBuilder: (context, index) {
                  if (info['posts'].length > 0) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        info['posts'][index]['title'],
                        style: TextStyle(
                          color: settings.darkMode
                              ? settings.colorMiddle
                              : Colors.black,
                          fontSize: 30,
                        ),
                      ),
                    );
                  } else {
                    return Text('None');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// =============================================================================
// MAIN ========================================================================

  final info;
  OwnerDone(this.info);
  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: settings.darkMode
              ? Colors.white
              : Colors.black, //change your color here
        ),
        backgroundColor:
            settings.darkMode ? settings.colorBackground : Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          info['first'] + ' ' + info['last'],
          style: TextStyle(
            color: settings.darkMode ? settings.colorMiddle : Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
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
            infoList(settings),
            if (authSettings.ownerId != info['id'])
              convoButton(context, settings),
          ],
        ),
      ),
    );
  }
}
