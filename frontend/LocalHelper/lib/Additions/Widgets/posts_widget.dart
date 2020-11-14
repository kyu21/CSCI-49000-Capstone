import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Additions/Screens/screen_full.dart';
import 'package:provider/provider.dart';

class Posts extends StatelessWidget {
// VARIABLES ===================================================================

  final double rad = 30;
  final info;

// =============================================================================
// FUNCTIONS ===================================================================

  Posts(this.info);

// =============================================================================

  @override
  Widget build(BuildContext context) {
    // Info
    final String first = info['owner']['first'];
    final String last = info['owner']['last'];
    final String title = info['post']['title'];
    final String description = info['post']['description'];
    final int postId = info['post']['id'];

    // Providers
    Settings settings = Provider.of<Settings>(context);

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
              // Title
              Center(
                  child: Container(
                      child: Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ))),

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
