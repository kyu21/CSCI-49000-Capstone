import 'package:flutter/material.dart';
import 'package:localhelper/Additions/authSettings.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:localhelper/Screens/MainPages/Posts/screen_owner.dart';
import 'package:localhelper/Screens/MainPages/Posts/screen_full.dart';
import 'package:localhelper/Screens/MainPages/Settings/screen_userSettings.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; //for date format

class Posts extends StatelessWidget {
  final double rad = 30;
  final info;
  Posts(this.info);

  String convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('dd-MM-yyyy');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: settings.darkMode ? Colors.grey[900] : Colors.blue[600],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(rad),
            topRight: Radius.circular(rad),
            bottomLeft: Radius.circular(rad),
            bottomRight: Radius.circular(rad),
          ),
        ),
        width: double.infinity,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Name / Date
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        final ownerId = info['owner']['id'];
                        if (ownerId != authSettings.ownerId)
                          return ScreenOwner(ownerId);
                        else
                          return ScreenUserSettings();
                      }));
                      settings.refreshPage();
                    },
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info['owner']['first'] +
                                ' ' +
                                info['owner']['last'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            info['post']['createdAt'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Requests
                          SizedBox(height: 5),
                          info['post']['is_request']
                              ? Text(
                                  'Request: Yes',
                                  style: TextStyle(
                                    color: Colors.lightGreen,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'Request: No',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),

                  // Title
                  SizedBox(width: 30),
                  Expanded(
                    child: Container(
                      child: Text(
                        info['post']['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  )
                ],
              ),

              // Description
              SizedBox(height: 30),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ScreenPostsFull(info['post']['id']);
                    }));
                    settings.refreshPage();
                  },
                  child: Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        info['post']['description'],
                        style: TextStyle(
                          color:
                              settings.darkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: settings.darkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
