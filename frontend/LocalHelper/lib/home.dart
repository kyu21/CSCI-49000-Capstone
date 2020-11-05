import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Additions/settings.dart';
import 'Screens/MainPages/Conversations/screen_convo.dart';
import 'Screens/MainPages/MyPosts/screen_myposts.dart';
import 'Screens/MainPages/Posts/screen_posts.dart';
import 'Screens/MainPages/Settings/screen_settings.dart';
import 'Screens/MainPages/Users/screen_users.dart';

/*
  This is the main module that holds all the screens in a list.

*/

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  List<Widget> pageList = List<Widget>();
  int _currentIndex = 0;

  @override
  void initState() {
    // Clear the list and add the pages
    pageList.clear();
    pageList.add(ScreenPosts());
    pageList.add(ScreenUsers());
    pageList.add(ScreenConvo());
    pageList.add(ScreenMyPosts());
    pageList.add(ScreenSettings());
    super.initState();
  }

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
            label: 'Local Posts',
            icon: Icon(Icons.local_activity),
          ),
          BottomNavigationBarItem(
            label: 'Users',
            icon: Icon(Icons.supervised_user_circle),
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
