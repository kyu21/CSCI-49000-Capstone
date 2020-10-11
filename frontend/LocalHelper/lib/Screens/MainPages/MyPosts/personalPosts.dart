import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localhelper/settings.dart';

// This is the Container for personal posts

class MyPosts extends StatelessWidget {
  final String _name;
  final String _desc;
  MyPosts(this._name, this._desc);
  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            color: settings.darkMode ? Colors.white : Colors.black,
          ),
          child: Column(
            children: [
              // Name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _name,
                  style: TextStyle(
                    color: settings.darkMode ? Colors.black : Colors.white,
                  ),
                ),
              ),
              // Description
              Text(
                _desc,
                style: TextStyle(
                  fontSize: 30,
                  color: settings.darkMode ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
