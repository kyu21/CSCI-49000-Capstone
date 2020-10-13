import 'package:flutter/material.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:provider/provider.dart';

class MyPosts extends StatelessWidget {
  final String _title;
  final String _desc;
  final String _name;
  final String _address;

  MyPosts(this._title, this._desc, this._name, this._address);
  @override
  Widget build(BuildContext context) {
    // Providers
    Settings settings = Provider.of<Settings>(context);

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
        child: ListView(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _title,
                style: TextStyle(
                  color: settings.darkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
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
            // Address
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _address,
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
  }
}
