import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localhelper/Additions/posts_widget.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:localhelper/Screens/MainPages/MyPosts/screen_createposts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ScreenMyPosts extends StatefulWidget {
  @override
  _ScreenMyPosts createState() => _ScreenMyPosts();
}

class _ScreenMyPosts extends State<ScreenMyPosts> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  List _testList = List();

  @override
  Widget build(BuildContext context) {
    // Providers
    Settings settings = Provider.of<Settings>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: settings.darkMode ? Colors.black : Colors.white,
        body: SmartRefresher(
          physics: BouncingScrollPhysics(),
          enablePullDown: true,
          enablePullUp: true,
          controller: _refreshController,
          onLoading: _onLoading,
          onRefresh: _onRefresh,
          header: MaterialClassicHeader(),
          child: CustomScrollView(
            reverse: true,
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor:
                    settings.darkMode ? Colors.black : Colors.white,
                elevation: 0,
                flexibleSpace: FlatButton(
                  splashColor: settings.darkMode ? Colors.red : Colors.black,
                  highlightColor: settings.darkMode ? Colors.red : Colors.grey,
                  minWidth: double.infinity,
                  height: 75,
                  child: Text(
                    'Create New Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: settings.darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ScreenCreatePosts();
                    }));
                  },
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Posts(_testList[index]);
                  },
                  childCount: _testList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FUNCTIONS
  void _onRefresh() async {
    setState(() {
      // Reset start value
      Provider.of<Settings>(context, listen: false).updatePersonalNum(0);

      // Clear the lists
      _testList.clear();

      // Find Personal Posts again
      _onLoading();

      // Trigger controller complete
      _refreshController.refreshCompleted();
    });
  }

  void _onLoading() async {
    // Settings
    final maxLoad = 3;
    int timeout = 10;

    // Starting index
    int startI = Provider.of<Settings>(context, listen: false).personalNum;

    try {
      // Get the user info
      http.Response response = await http
          .get('https://localhelper-backend.herokuapp.com/api/users/1')
          .timeout(Duration(seconds: timeout));

      // If got a response
      if (response.statusCode == 200) {
        // Set state
        setState(() {
          // Save the variable in a json
          List json = jsonDecode(response.body)['posts'];

          // If there's more to the posts...
          if (startI <= json.length) {
            for (int i = 0; (i < (json.length - startI)) && i < maxLoad; i++) {
              // Add from the saved placement
              int newIndex = startI + i;

              var ownerStuff = {
                "owner": {
                  'id': jsonDecode(response.body)['id'],
                  'first': jsonDecode(response.body)['first'],
                  'last': jsonDecode(response.body)['last']
                },
                "post": json[newIndex],
              };

              _testList.add(ownerStuff);
              // Remember placement
              Provider.of<Settings>(context, listen: false)
                  .updatePersonalNum(newIndex + 1);
            }
          }
        });

        // Stop the refresh animation
        _refreshController.loadComplete();
      } else {
        // handle it
        print("Can't get info.");
        // Stop the refresh animation
        _refreshController.loadComplete();
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      _refreshController.loadComplete();
    } on SocketException {
      _refreshController.loadComplete();
    }
  }
}
