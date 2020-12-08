import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Messaging extends StatefulWidget {
  // senderName is the YOU, the person sending the messages
  // chattingWith is the person you are talking to
  final chattingWith;
  final senderName;
  final convoId;
  Messaging(this.chattingWith, this.senderName, this.convoId);
  @override
  _MessagingState createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  // Variables
  List messagesJson = List();
  List messages = List();
  String messageToSend = '';
  TextEditingController _textEditingController = TextEditingController();
  bool loading = false;
  bool displayed = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  void _onRefresh() async {
    setState(() {
      // Clear the lists
      messagesJson.clear();
      messages.clear();

      displayed = false;

      // Trigger controller complete
      _refreshController.refreshCompleted();
    });
    // Load data
    await _onLoading();
  }

  Future _onLoading() async {
    setState(() {
      loading = true;
    });

    if (!displayed) {
      await getMessages(widget.convoId);
      displayed = true;
    }
    setState(() {
      loading = false;
      _refreshController.loadComplete();
    });
  }

  // Grabs all messages in a conversation and stores them in a list
  Future getMessages(int convoId) async {
    final String token =
        Provider.of<AuthSettings>(context, listen: false).token;
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      String link =
          'https://localhelper-backend.herokuapp.com/api/users/convos/' +
              convoId.toString() +
              '/messages';
      // HTTP Get
      http.Response response =
          await http.get(link, headers: headers).timeout(Duration(seconds: 20));

      // If it worked
      if (response.statusCode == 200) {
        List json = jsonDecode(response.body);
        for (int i = 0; i < json.length; i++) {
          messagesJson.add(json[i]);
          Message m = Message(json[i]);
          messages.add(m);
          //gets rid of dups if called multiple times
          messagesJson = messagesJson.toSet().toList();
          messages = messages.toSet().toList();
        }
      } else {
        print('GET code ' + response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }

  //Sends the message
  Future sendMessage(int convoId, String body) async {
    final String token =
        Provider.of<AuthSettings>(context, listen: false).token;
    Map<String, dynamic> jsonMap = {
      'body': body,
    };
    // Encode
    String jsonString = json.encode(jsonMap);
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      String link =
          'https://localhelper-backend.herokuapp.com/api/users/convos/' +
              convoId.toString() +
              '/messages';

      // HTTP Post
      http.Response response = await http
          .post(
            link,
            headers: headers,
            body: jsonString,
          )
          .timeout(Duration(seconds: 20));

      // If it didn't work
      if (response.statusCode != 200) {
        print('POST code ' + response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }

// The send message bar at the bottom of the screen
  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textEditingController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                messageToSend = value;
              },
              decoration: InputDecoration.collapsed(
                  hintText: 'Enter a message here...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            onPressed: () async {
              if (messageToSend != "") {
                await sendMessage(widget.convoId, messageToSend);
                setState(() {
                  _textEditingController.clear();
                  _onRefresh();
                });
              }
            },
          )
        ],
      ),
    );
  }

  // Returns a container that represents a singel chat bubble
  _buildMessage(Message message, bool isMe) {
    return Container(
      margin: isMe
          ? EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 80.0,
            )
          : EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              right: 80.0,
            ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[400],
          borderRadius: isMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                )),
      child: Text(
        message.text,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    String chattingWith = widget.chattingWith;

    return Scaffold(
      backgroundColor:
          settings.darkMode ? settings.colorBackground : settings.colorOpposite,
      appBar: AppBar(
        backgroundColor: settings.darkMode
            ? settings.colorBackground
            : settings.colorOpposite,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          chattingWith,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: settings.darkMode ? Colors.indigo : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: SmartRefresher(
                    physics: BouncingScrollPhysics(),
                    reverse: true,
                    enablePullDown: true,
                    enablePullUp: false,
                    controller: _refreshController,
                    onRefresh: () => _onRefresh(),
                    onLoading: () => _onLoading(),
                    header: MaterialClassicHeader(),
                    child: ListView.builder(
                      reverse: false,
                      padding: EdgeInsets.only(top: 15.0),
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        List messagesReverse = List.from(messages.reversed);
                        Message message = messagesReverse[index];
                        bool isMe = message.senderId == authSettings.ownerId;
                        return _buildMessage(message, isMe);
                      },
                    ),
                  ),
                ),
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }
}

class Message {
  int senderId;
  String text;

  Message(Map<String, dynamic> data) {
    senderId = data['userId'];
    text = data['body'];
  }
}
