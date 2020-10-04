import 'package:flutter/material.dart';

// Screens
import 'MainPages/Messages/screen_messages.dart';
import 'MainPages/screen_myposts.dart';
import 'MainPages/screen_settings.dart';
import 'MainPages/screen_posts.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  List<Widget> pageList = List<Widget>();

  @override
  void initState() {
    pageList.add(ScreenPosts());
    pageList.add(ScreenMessages());
    pageList.add(ScreenMyPosts());
    pageList.add(ScreenSettings());
    super.initState();
  }

  int _currentIndex = 0;

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pageList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: setIndex,
        backgroundColor: Colors.black,
        fixedColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            label: 'Local Posts',
            icon: Icon(Icons.local_activity),
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            label: 'Messages',
            icon: Icon(Icons.message),
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            label: 'My Posts',
            icon: Icon(Icons.post_add),
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(Icons.settings),
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
