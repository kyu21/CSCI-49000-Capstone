import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:provider/provider.dart';
import 'package:localhelper/Additions/Widgets/convo_widget.dart';

class ScreenConvo extends StatefulWidget {
  @override
  _ScreenConvoState createState() => _ScreenConvoState();
}

class _ScreenConvoState extends State<ScreenConvo> {
  @override
  Widget build(BuildContext context) {
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Conversations'),
      ),
      body: FlatButton(
        color: Colors.blue[300],
        height: 50,
        minWidth: double.infinity,
        child: Text(
          'Create Conversation',
          style: TextStyle(fontSize: 30),
        ),
        onPressed: () async {
          Map<String, dynamic> jsonMap = {
            'users': [20], //This is the person you're talking to
          };

          // Encode
          String jsonString = json.encode(jsonMap);
          try {
            Map<String, String> headers = {
              'content-type': 'application/json',
              'accept': 'application/json',
            };
            String link =
                'https://localhelper-backend.herokuapp.com/api/convos/' +
                    authSettings.ownerId.toString(); //This is logged in user
            var result =
                await http.post(link, headers: headers, body: jsonString);
            if (result.statusCode == 200) {
              print('yo we made it');
            }
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
