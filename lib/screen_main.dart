import 'package:flutter/material.dart';

// Screens
import 'Pages/screen_myposts.dart';
import 'Pages/screen_search.dart';
import 'Pages/screen_settings.dart';
import 'Pages/screen_login.dart';
import 'Pages/screen_messages.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  List<Widget> pageList = List<Widget>();

  @override
  void initState() {
    pageList.add(ScreenLogin());
    pageList.add(ScreenMessages());
    pageList.add(ScreenMyPosts());
    pageList.add(ScreenSearch());
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
            label: 'Search',
            icon: Icon(Icons.search),
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