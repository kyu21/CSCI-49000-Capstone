import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Additions/Screens/screen_full.dart';
import 'package:provider/provider.dart';

class Posts extends StatelessWidget {
// VARIABLES ===================================================================

  final info;

// =============================================================================
// FUNCTIONS ===================================================================

  Posts(this.info);

// =============================================================================

  @override
  Widget build(BuildContext context) {
    int postID;
    String title;
    String description;
    bool request;
    bool free;

    postID = info['id'];
    title = info['title'];
    description = info['description'];
    request = info['is_request'];
    free = info['free'];

    // Providers
    Settings settings = Provider.of<Settings>(context);
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ScreenPostsFull(postID);
        }));
        settings.refreshPage();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(
                color: settings.darkMode ? Colors.white : Colors.black,
                width: 5),
            bottom: BorderSide(
                color: settings.darkMode ? Colors.white : Colors.black,
                width: 5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Container(
                  child: FittedBox(
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (request)
                          Icon(Icons.star, color: Colors.purple[800]),
                        if (!free)
                          Icon(Icons.monetization_on,
                              color: Colors.yellow[800]),
                      ],
                    ),
                  ),
                ),
              ),

              // Description
              SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 300,
                ),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    description,
                    style: TextStyle(
                      height: 1.5,
                      fontSize: 20,
                      color: settings.darkMode ? Colors.white : Colors.black,
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

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
