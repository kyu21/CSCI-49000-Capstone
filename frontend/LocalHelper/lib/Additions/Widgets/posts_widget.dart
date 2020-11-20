import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Additions/Screens/screen_full.dart';
import 'package:provider/provider.dart';

class Posts extends StatelessWidget {
// VARIABLES ===================================================================

  final info;
  final int type;

// =============================================================================
// FUNCTIONS ===================================================================

  Posts(this.info, {this.type = 0});

// =============================================================================

  @override
  Widget build(BuildContext context) {
    String title;
    String description;
    int postId;
    // Info
    switch (type) {
      case 0:
        title = info['post']['title'];
        description = info['post']['description'];
        postId = info['post']['id'];
        break;
      case 1:
        title = info['title'];
        description = info['description'];
        postId = info['id'];
        break;
    }

    // Providers
    Settings settings = Provider.of<Settings>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
              color: settings.darkMode ? Colors.white : Colors.black, width: 5),
          bottom: BorderSide(
              color: settings.darkMode ? Colors.white : Colors.black, width: 5),
        ),
      ),
      width: double.infinity,
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Container(
                child: Text(
                  title,
                  style: TextStyle(
                      color: settings.darkMode ? Colors.white : Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Description
            SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return ScreenPostsFull(postId);
                  }));
                  settings.refreshPage();
                },
                child: Container(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
