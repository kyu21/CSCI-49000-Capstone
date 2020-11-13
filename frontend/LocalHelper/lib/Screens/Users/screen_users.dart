import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Additions/Widgets/users.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

class ScreenUsers extends StatefulWidget {
  @override
  _ScreenUsersState createState() => _ScreenUsersState();
}

class _ScreenUsersState extends State<ScreenUsers> {
// VARIABLES ===================================================================

  // Controllers
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  // Lists
  List userList = List();

// =============================================================================
// FUNCTIONS ===================================================================

  void _onRefresh(String token) async {
    setState(() {
      // Reset start value
      Provider.of<Settings>(context, listen: false).updateUserNum(0);

      // Clear the lists
      userList.clear();

      // Find Images
      _onLoading(token);

      // Trigger controller complete
      _refreshController.refreshCompleted();
    });
  }

  void _onLoading(String token) async {
    // Settings
    final maxLoad = 10;
    int timeout = 10;

    // Starting index
    int startI = Provider.of<Settings>(context, listen: false).userNum;

    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };
      http.Response response = await http
          .get('https://localhelper-backend.herokuapp.com/api/users',
              headers: headers)
          .timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        // Set state
        setState(() {
          // Save the variable in a json
          List json = jsonDecode(response.body);

          // If there's more to the posts...
          if (startI <= json.length) {
            for (int i = 0; (i < (json.length - startI)) && i < maxLoad; i++) {
              // Add from the saved placement
              int newIndex = startI + i;
              userList.add(json[newIndex]);

              // Remember placement
              Provider.of<Settings>(context, listen: false)
                  .updateUserNum(newIndex + 1);
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

// =============================================================================
// MAIN ========================================================================

  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);
    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
      body: SmartRefresher(
        physics: BouncingScrollPhysics(),
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onLoading: () => _onLoading(authSettings.token),
        onRefresh: () => _onRefresh(authSettings.token),
        header: MaterialClassicHeader(),
        child: userList.isNotEmpty
            ? CustomScrollView(
                reverse: true,
                slivers: [
                  // Users
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (userList.isEmpty) {
                          return Container(
                            color: Colors.black,
                          );
                        } else {
                          return Users(userList[index]);
                        }
                      },
                      childCount: userList.length,
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  'No Users Found...',
                  style: TextStyle(
                      color: settings.darkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontSize: 20),
                ),
              ),
      ),
    );
  }
}
