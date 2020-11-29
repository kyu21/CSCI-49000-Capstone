import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Messaging extends StatefulWidget {
  // userId is the YOU, the person sending the messages
  final chattingWith;
  final senderName;
  final convoId;
  Messaging(this.chattingWith, this.senderName, this.convoId);
  @override
  _MessagingState createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  // Variables
  RefreshController _refreshController = RefreshController();
  ScrollController _scrollController = ScrollController();
  TextEditingController _textController = TextEditingController();
/*
  _buildMessages(message, bool isMe) {
    return Container();
  }
*/
  @override
  Widget build(BuildContext context) {
    String chattingWith = widget.chattingWith;
    String myName = widget.senderName;
    List<_MessageItems> messageList = [
      _MessageItems(
        body: 'Hello theres sir.',
        isMe: true,
        senderName: myName,
      ),
      _MessageItems(
        body: 'Hi',
        isMe: false,
        senderName: chattingWith,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          chattingWith,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messageList[1],
            ),
            Expanded(
              child: messageList[0],
            ),
            Container(
              color: Colors.white,
              height: 56.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: CupertinoTextField(
                        controller: _textController,
                        placeholder: 'Enter your message here.',
                        onSubmitted: (s) {
                          messageList.insert(
                              0,
                              _MessageItems(
                                body: s,
                                senderName: 'Alex',
                                isMe: true,
                              ));
                          setState(() {});
                          _scrollController.jumpTo(0.0);
                          _textController.clear();
                        },
                      ),
                      margin: EdgeInsets.all(10.0),
                    ),
                  ),
                  RaisedButton(
                    child: Text(
                      'Send',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blueAccent,
                    onPressed: () {
                      _scrollController.jumpTo(0.0);
                      messageList.insert(
                          0,
                          _MessageItems(
                            body: _textController.text,
                            senderName: 'Alex',
                            isMe: true,
                          ));
                      setState(() {});
                      _textController.clear();
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MessageItems extends StatelessWidget {
  final String body;
  final String senderName;
  final bool isMe;
  _MessageItems({this.body, this.senderName, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.black,
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      margin: EdgeInsets.only(top: 10.0),
      child: Wrap(
        textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
        children: <Widget>[
          Container(width: 8.0),
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                // color: Colors.yellow,
                height: 30.0,
                width: 200.0,
                alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                child: Text(
                  senderName,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minWidth: 1.0,
                  minHeight: 25.0,
                  maxWidth: 200.0,
                ),
                alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  body,
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black, fontSize: 18),
                ),
                padding: EdgeInsets.all(10.0),
              )
            ],
          )
        ],
      ),
    );
  }
}
