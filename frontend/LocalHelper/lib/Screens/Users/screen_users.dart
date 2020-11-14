import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Additions/Widgets/users.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

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

  // Booleans
  bool loading = false;

// =============================================================================
// FUNCTIONS ===================================================================

  void _onRefresh() {
    setState(() {
      // Reset start value
      Provider.of<Settings>(context, listen: false).userNum = 0;

      // Clear the lists
      userList.clear();

      // Find Images
      _onLoading();

      // Trigger controller complete
      _refreshController.refreshCompleted();
    });
  }

  void _onLoading() async {
    // VARIABLES ---------------------------------------------------------------

    setState(() {
      loading = true;
    });

    // Settings
    final int timeout = 10;
    final newAmount = 10;

    // Providers
    Provider.of<Settings>(context, listen: false).updateUserNum(newAmount);
    final String token =
        Provider.of<AuthSettings>(context, listen: false).token;

    // Header
    Map<String, String> headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      'authorization': token,
    };

    // -------------------------------------------------------------------------
    // MAIN --------------------------------------------------------------------

    try {
      // HTTP Get
      http.Response response = await http
          .get('https://localhelper-backend.herokuapp.com/api/users',
              headers: headers)
          .timeout(Duration(seconds: timeout));
      if (response.statusCode == 200) {
        userList = jsonDecode(response.body);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      loading = false;
      _refreshController.loadComplete();
    });
  }

// =============================================================================
// MAIN ========================================================================

  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
      body: SmartRefresher(
        physics: BouncingScrollPhysics(),
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onLoading: () => _onLoading(),
        onRefresh: () => _onRefresh(),
        header: MaterialClassicHeader(),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : userList.isNotEmpty
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
                          childCount: min(userList.length, settings.userNum),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'No Users Found...',
                      style: TextStyle(
                          color:
                              settings.darkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          fontSize: 20),
                    ),
                  ),
      ),
    );
  }
}
