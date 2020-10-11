import 'package:flutter/material.dart';
import 'package:localhelper/settings.dart';
import 'package:provider/provider.dart';

// Screens
import 'MainPages/Messages/screen_messages.dart';
import 'MainPages/MyPosts/screen_myposts.dart';
import 'MainPages/screen_settings.dart';
import 'MainPages/screen_posts.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  List<Widget> pageList = List<Widget>();
  int _currentIndex = 0;
  Settings settings;

  @override
  void initState() {
    // Clear the list and add the pages
    pageList.clear();
    pageList.add(ScreenPosts());
    pageList.add(ScreenMessages());
    pageList.add(ScreenMyPosts());
    pageList.add(ScreenSettings());
    settings = context.read<Settings>();
    super.initState();
  }

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Update the values on change
    settings = context.watch<Settings>();

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
            label: 'Local Posts',
            icon: Icon(Icons.local_activity),
          ),
          BottomNavigationBarItem(
            label: 'Messages',
            icon: Icon(Icons.message),
          ),
          BottomNavigationBarItem(
            label: 'My Posts',
            icon: Icon(Icons.post_add),
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
