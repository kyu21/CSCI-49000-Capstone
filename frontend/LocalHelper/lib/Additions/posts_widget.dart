import 'package:flutter/material.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:localhelper/Screens/MainPages/Posts/screen_owner.dart';
import 'package:localhelper/Screens/MainPages/Posts/screen_full.dart';
import 'package:provider/provider.dart';

class Posts extends StatelessWidget {
  final double rad = 30;
  final info;
  Posts(this.info);
  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: settings.darkMode ? Colors.white : Colors.black,
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
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ScreenOwner(info['owner']['id']);
                      }));
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
                              color: settings.darkMode
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            info['post']['dateCreated'],
                            style: TextStyle(
                              color: settings.darkMode
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 10,
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
                          color:
                              settings.darkMode ? Colors.black : Colors.white,
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
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ScreenPostsFull(info['post']['id']);
                    }));
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
