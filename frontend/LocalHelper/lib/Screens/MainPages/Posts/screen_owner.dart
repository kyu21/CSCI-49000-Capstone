import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future getOwnerDetails() async {
    try {
      String link = 'https://localhelper-backend.herokuapp.com/api/users' +
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
          return OwnerNone();

          // When loading
        } else if (mywidget.connectionState == ConnectionState.waiting) {
          return OwnerWait();

          // When finished
        } else if (mywidget.connectionState == ConnectionState.done) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(info['first'] + ' ' + info['last']),
      ),
      body: ListView(
        children: [
          // Gender
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Gender: ' + info['gender'],
              style: TextStyle(
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
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Address
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Address:',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              info['zips'][0]['zip'] + ' ' + info['zips'][0]['name'],
              style: TextStyle(
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
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: info['languages'].length,
              itemBuilder: (context, index) {
                return Text(
                  info['languages'][index]['name'],
                  style: TextStyle(
                    fontSize: 30,
                  ),
                );
              },
            ),
          ),

          // Posts
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Posts: ',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: info['posts'].length,
              itemBuilder: (context, index) {
                return Text(
                  info['posts'][index]['title'],
                  style: TextStyle(
                    fontSize: 30,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
