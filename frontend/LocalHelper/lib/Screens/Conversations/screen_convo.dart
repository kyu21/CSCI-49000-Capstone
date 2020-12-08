import 'dart:async';
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
  Future myName(int userId) async {
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
  Future getUserList(int convoId) async {
    for (int i = 0; i < convoList.length; i++) {
      if (convoList[i]['id'] == convoId) {
        usersList.add(convoList[i]['participants'][1]['id']);
        usersList = usersList.toSet().toList();
        // adds the name of the person you are talking to
        nameList.add(convoList[i]['participants'][1]['first'] +
            ' ' +
            convoList[i]['participants'][1]['last']);
        nameList = nameList.toSet().toList();
      }
    }
  }

  /* takes the logged in user's id and adds all the convoIds 
  that the user is a part of to a list of convoIds
  convoList is an array of json of convos that the user is a part of
  the for loop parses only the convoId part and stores it in ofConvoId
  */
  Future getConvoList() async {
    final String token =
        Provider.of<AuthSettings>(context, listen: false).token;
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      String link =
          'https://localhelper-backend.herokuapp.com/api/users/convos/';

      // HTTP Get
      http.Response response =
          await http.get(link, headers: headers).timeout(Duration(seconds: 20));

      // If it worked
      if (response.statusCode == 200) {
        List json = jsonDecode(response.body);
        convoList = json;
        for (int i = 0; i < convoList.length; i++) {
          ofConvoId.add(convoList[i]['id']);
          ofConvoId = ofConvoId.toSet().toList();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future getAllInfo() async {
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    await getConvoList();
    if (ofConvoId.length != 0) {
      await myName(authSettings.ownerId);
      for (int i = 0; i < ofConvoId.length; i++) {
        await getUserList(ofConvoId[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAllInfo(),
      builder: (context, snapshot) {
        // No connection
        if (snapshot.connectionState == ConnectionState.none) {
          return ConvoNone();

          // Currently Loading
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return ConvoWait();

          // Finished Loading
        } else if (snapshot.connectionState == ConnectionState.done) {
          return ConvoDone(
              senderName, convoList, usersList, ofConvoId, nameList);
        }

        // failsafe
        return ConvoNone();
      },
    );
  }
}

class ConvoNone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation Not Found!'),
      ),
    );
  }
}

class ConvoWait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ConvoDone extends StatefulWidget {
  final String senderName;
  final List convoList;
  final List usersList;
  final List ofConvoId;
  final List nameList;
  ConvoDone(this.senderName, this.convoList, this.usersList, this.ofConvoId,
      this.nameList);

  @override
  _ConvoDoneState createState() =>
      _ConvoDoneState(senderName, convoList, usersList, ofConvoId, nameList);
}

class _ConvoDoneState extends State<ConvoDone> {
  // Variables
  String senderName;
  // in json still all the convo user is in
  List convoList;
  // list of users in userId form from all the convos
  List usersList;
  // list of convoIds in int form
  List<int> ofConvoId;
  // list of users in String form with first and last name
  List<String> nameList;
  bool loading = false;

  // Constructor
  _ConvoDoneState(this.senderName, this.convoList, this.usersList,
      this.ofConvoId, this.nameList);

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  // Grabs the currently logged in user's name
  Future myName(int userId) async {
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
  Future getUserList(int convoId) async {
    for (int i = 0; i < convoList.length; i++) {
      if (convoList[i]['id'] == convoId) {
        usersList.add(convoList[i]['participants'][1]['id']);
        usersList = usersList.toSet().toList();
        // adds the name of the person you are talking to
        nameList.add(convoList[i]['participants'][1]['first'] +
            ' ' +
            convoList[i]['participants'][1]['last']);
        nameList = nameList.toSet().toList();
      }
    }
  }

  /* takes the logged in user's id and adds all the convoIds 
  that the user is a part of to a list of convoIds
  convoList is an array of json of convos that the user is a part of
  the for loop parses only the convoId part and stores it in ofConvoId
  */
  Future getConvoList() async {
    final String token =
        Provider.of<AuthSettings>(context, listen: false).token;
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      String link =
          'https://localhelper-backend.herokuapp.com/api/users/convos/';

      // HTTP Get
      http.Response response =
          await http.get(link, headers: headers).timeout(Duration(seconds: 20));

      // If it worked
      if (response.statusCode == 200) {
        List json = jsonDecode(response.body);
        convoList = json;
        for (int i = 0; i < convoList.length; i++) {
          ofConvoId.add(convoList[i]['id']);
          ofConvoId = ofConvoId.toSet().toList();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future getAllInfo() async {
    AuthSettings authSettings =
        Provider.of<AuthSettings>(context, listen: false);
    await getConvoList();
    if (ofConvoId.length != 0) {
      await myName(authSettings.ownerId);
      for (int i = 0; i < ofConvoId.length; i++) {
        await getUserList(ofConvoId[i]);
      }
    }
  }

  void _onRefresh() async {
    if (this.mounted) {
      setState(() {
        convoList.clear();
        usersList.clear();
        ofConvoId.clear();
        nameList.clear();
        _refreshController.refreshCompleted();
      });
    }
    _onLoading();
  }

  void _onLoading() async {
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }
    await getAllInfo();
    if (this.mounted) {
      setState(() {
        loading = false;
        _refreshController.loadComplete();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    List revseredNameList = List.from(nameList.reversed);
    List reversedConvoId = List.from(ofConvoId.reversed);

    return GestureDetector(
      child: Scaffold(
        backgroundColor: settings.darkMode ? Colors.black : Colors.white,
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
          child: SmartRefresher(
            controller: _refreshController,
            physics: BouncingScrollPhysics(),
            header: MaterialClassicHeader(),
            onRefresh: () => _onRefresh(),
            onLoading: () => _onLoading(),
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      // conversations if any
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Your Conversations',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: settings.darkMode
                                ? settings.colorBlue
                                : Colors.black,
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
                            style: TextStyle(
                              fontSize: 35,
                              fontStyle: FontStyle.italic,
                              color: settings.darkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      for (int i = 0; i < nameList.length; i++)
                        Convos(revseredNameList[i], senderName,
                            reversedConvoId[i]),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
