import 'package:flutter/material.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:provider/provider.dart';

class MyPosts extends StatelessWidget {
  final String _title;
  final String _desc;
  final String _name;

  MyPosts(this._title, this._desc, this._name);
  @override
  Widget build(BuildContext context) {
    // Providers
    Settings settings = Provider.of<Settings>(context);
    final double rad = 30;

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: TextStyle(
                          color:
                              settings.darkMode ? Colors.black : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        DateTime.now().toString(),
                        style: TextStyle(
                          color:
                              settings.darkMode ? Colors.black : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Title
                  SizedBox(width: 30),
                  Expanded(
                    child: Container(
                      child: Text(
                        _title,
                        style: TextStyle(
                          color:
                              settings.darkMode ? Colors.black : Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  )
                ],
              ),

              // Description
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  child: Text(
                    _desc,
                    style: TextStyle(
                      color: settings.darkMode ? Colors.black : Colors.white,
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
