import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Screens/Conversations/screen_convo.dart';
import 'package:localhelper/Screens/Interests/screen_interests.dart';
import 'package:localhelper/Screens/MyPosts/screen_myposts.dart';
import 'package:localhelper/Screens/Posts/screen_posts.dart';
import 'package:localhelper/Screens/Settings/screen_settings.dart';
import 'package:provider/provider.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
// VARIABLES ===================================================================

  List<Widget> pageList = List<Widget>();
  int _currentIndex = 0;

  @override
  void initState() {
    // Clear the list and add the pages
    pageList.clear();
    pageList.add(ScreenPosts());
    pageList.add(ScreenInterests());
    pageList.add(ScreenMyPosts());
    pageList.add(ScreenConvo());
    pageList.add(ScreenSettings());
    super.initState();
  }

// =============================================================================
// FUNCTIONS ===================================================================

  void setIndex(int index) {
    if (this.mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

// =============================================================================
// MAIN ========================================================================

  @override
  Widget build(BuildContext context) {
    final Settings settings = context.watch<Settings>();

    // Widget
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pageList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: setIndex,
        elevation: 0,
        unselectedItemColor: Colors.grey,
        backgroundColor: settings.darkMode ? Colors.black : Colors.white,
        selectedItemColor: settings.darkMode ? Colors.white : Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            label: 'Posts',
            icon: Icon(Icons.local_activity),
          ),
          BottomNavigationBarItem(
            label: 'Interests',
            icon: Icon(Icons.file_copy),
          ),
          BottomNavigationBarItem(
            label: 'My Posts',
            icon: Icon(Icons.post_add),
          ),
          BottomNavigationBarItem(
            label: 'Messages',
            icon: Icon(Icons.message),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
