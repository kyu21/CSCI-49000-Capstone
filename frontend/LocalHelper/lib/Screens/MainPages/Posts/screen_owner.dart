import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localhelper/Additions/authSettings.dart';
import 'package:localhelper/Additions/settings.dart';
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
  final info;
  OwnerDone(this.info);
  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: settings.darkMode
              ? Colors.white
              : Colors.black, //change your color here
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          info['first'] + ' ' + info['last'],
          style: TextStyle(
            color: settings.darkMode ? Colors.white : Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Gender
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Gender: ' + info['gender'],
              style: TextStyle(
                color: settings.darkMode ? Colors.white : Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Phone
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Phone: ' + info['phone'],
              style: TextStyle(
                color: settings.darkMode ? Colors.white : Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Email
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Email: ' + info['email'],
              style: TextStyle(
                color: settings.darkMode ? Colors.white : Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Address
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Main Zip:',
              style: TextStyle(
                color: settings.darkMode ? Colors.white : Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: info['zips'].length > 0
                ? Text(
                    info['zips'].last['zip'],
                    style: TextStyle(
                      color: settings.darkMode ? Colors.white : Colors.black,
                      fontSize: 30,
                    ),
                  )
                : Text(
                    'None',
                    style: TextStyle(
                      color: settings.darkMode ? Colors.white : Colors.black,
                      fontSize: 30,
                    ),
                  ),
          ),

          // Languages
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Languages: ',
              style: TextStyle(
                color: settings.darkMode ? Colors.white : Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(10),
            child: info['languages'].length > 0
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: info['languages'].length,
                    itemBuilder: (context, index) {
                      return Text(
                        info['languages'][index]['name'],
                        style: TextStyle(
                          color:
                              settings.darkMode ? Colors.white : Colors.black,
                          fontSize: 30,
                        ),
                      );
                    },
                  )
                : Text(
                    'None',
                    style: TextStyle(
                      color: settings.darkMode ? Colors.white : Colors.black,
                      fontSize: 30,
                    ),
                  ),
          ),

          // Posts
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Posts: ',
              style: TextStyle(
                color: settings.darkMode ? Colors.white : Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: info['posts'].length,
              itemBuilder: (context, index) {
                if (info['posts'].length > 0) {
                  return Text(
                    info['posts'][index]['title'],
                    style: TextStyle(
                      color: settings.darkMode ? Colors.white : Colors.black,
                      fontSize: 30,
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
    );
  }
}
