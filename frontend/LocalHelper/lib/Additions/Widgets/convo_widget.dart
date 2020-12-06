import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Screens/Conversations/screen_messages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Convos extends StatelessWidget {
// VARIABLES ===================================================================
  final recipientName;
  final senderName;
  final convoId;
// =============================================================================
// FUNCTIONS ===================================================================

  Convos(this.recipientName, this.senderName, this.convoId);

// =============================================================================

  @override
  Widget build(BuildContext context) {
    // Info
    var chattingWith = recipientName;

    // Providers
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: settings.darkMode
              ? settings.colorBackground
              : settings.colorMiddle,
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
        ),
        width: double.infinity,
        height: 75,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Messaging(chattingWith, senderName, convoId);
                      }));
                      settings.refreshConvos();
                    },
                    child: SizedBox(
                      width: 210,
                      child: Text(
                        //Left side of the conversation box; the user's name
                        chattingWith,
                        style: TextStyle(
                          fontSize: 25,
                          color:
                              settings.darkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  Container(
                    // color: Colors.white,
                    alignment: Alignment.bottomRight,
                    width: 150,
                    height: 55,
                    // add something here maybe
                    child: Text(
                      'CONVO ID: ' + convoId.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: settings.darkMode ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
