import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:provider/provider.dart';
import 'package:localhelper/Additions/Widgets/convo_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScreenConvo extends StatefulWidget {
  @override
  _ScreenConvoState createState() => _ScreenConvoState();
}

class User {
  String firstName;
  String lastName;
  User(Map<String, dynamic> data) {
    firstName = data['first'];
    lastName = data['last'];
  }
}

class _ScreenConvoState extends State<ScreenConvo> {
  String senderName = '';
  // in json still all the convo user is in
  List convoList = List();
  // list of users in userId form from all the convos
  List usersList = List();
  // list of convoIds in int form
  List<int> ofConvoId = List();
  // list of users in String form with first and last name
  List<String> nameList = List();

// Grabs the currently logged in user's name
  void myName(int userId) async {
    final String token =
        Provider.of<AuthSettings>(context, listen: false).token;
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      String link = 'https://localhelper-backend.herokuapp.com/api/users/' +
          userId.toString();

      // HTTP Get
      http.Response response =
          await http.get(link, headers: headers).timeout(Duration(seconds: 20));
      // If it worked
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        User newPerson = User(json);
        senderName = newPerson.firstName + ' ' + newPerson.lastName;
      }
    } catch (e) {
      print(e);
    }
  }

  // takes convoId and adds all users from that convo to a list of users
  void getUserList(int convoId) async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
      };
      String link =
          'https://localhelper-backend.herokuapp.com/api/convos/uofc/' +
              convoId.toString();

      // HTTP Get
      http.Response response =
          await http.get(link, headers: headers).timeout(Duration(seconds: 20));

      // If it worked
      if (response.statusCode == 200) {
        List json = jsonDecode(response.body);
        for (int i = 0; i < json.length; i++) {
          usersList.add(json[i]);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  /* takes the logged in user's id and adds all the convoIds 
  that the user is a part of to a list of convoIds
  convoList is an array of json of convos that the user is a part of
  the for loop parses only the convoId part and stores it in ofConvoId
  */
  void getConvoList(int ownerId) async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
      };
      String link =
          'https://localhelper-backend.herokuapp.com/api/convos/cofu/' +
              ownerId.toString();

      // HTTP Get
      http.Response response =
          await http.get(link, headers: headers).timeout(Duration(seconds: 20));

      // If it worked
      if (response.statusCode == 200) {
        List json = jsonDecode(response.body);
        convoList = json;
        for (int i = 0; i < convoList.length; i++) {
          ofConvoId.add(convoList[i]['id']);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  // takes in userIds and returns the first and last name of the account
  void getUsersName(int userId) async {
    final String token =
        Provider.of<AuthSettings>(context, listen: false).token;
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      String link = 'https://localhelper-backend.herokuapp.com/api/users/' +
          userId.toString();

      // HTTP Get
      http.Response response =
          await http.get(link, headers: headers).timeout(Duration(seconds: 20));
      // If it worked
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        User newPerson = User(json);
        nameList.add(newPerson.firstName + ' ' + newPerson.lastName);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    // Scuffed code
    getConvoList(authSettings.ownerId);
    ofConvoId = ofConvoId.toSet().toList();
    for (int i = 0; i < ofConvoId.length; i++) {
      getUserList(ofConvoId[i]);
      usersList = usersList.toSet().toList();
      usersList.remove(authSettings.ownerId);
      getUsersName(usersList[i]);
    }
    nameList = nameList.toSet().toList();
    myName(authSettings.ownerId);

    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
      body: ListView(
        children: [
          // conversations if any
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your Conversations',
              //convoList.toString(),
              //ofConvoId.toString(),
              //usersList.toString(),
              //nameList.toString(),
              //senderName,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: settings.darkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          // empty
          if (nameList.isEmpty)
            Center(
              widthFactor: 5,
              heightFactor: 5,
              child: Text(
                'You have no conversations...',
                style: TextStyle(fontSize: 35, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),

          for (int i = 0; i < nameList.length; i++)
            Convos(nameList[i], senderName, ofConvoId[i]),

          // Convos(nameList[0], authSettings.ownerId),
        ],
      ),
    );
  }
}
