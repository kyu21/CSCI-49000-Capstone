import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Widgets/posts_widget.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:localhelper/Screens/MyPosts/screen_createposts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class ScreenMyPosts extends StatefulWidget {
  @override
  _ScreenMyPosts createState() => _ScreenMyPosts();
}

class _ScreenMyPosts extends State<ScreenMyPosts> {
// VARIABLES ===================================================================

  // Controllers
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  // Lists
  List _testList = List();

  // Booleans
  bool loading = false;

// =============================================================================
// FUNCTIONS ===================================================================

  void _onRefresh() async {
    setState(() {
      // Reset start value
      Provider.of<Settings>(context, listen: false).personalNum = 0;

      // Clear the lists
      _testList.clear();

      // Find Personal Posts again
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
    Provider.of<Settings>(context, listen: false).updatePersonalNum(newAmount);
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
          .get('https://localhelper-backend.herokuapp.com/api/posts/me',
              headers: headers)
          .timeout(Duration(seconds: timeout));

      // If got a response
      if (response.statusCode == 200) {
        _testList = jsonDecode(response.body);
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
    // Providers
    Settings settings = Provider.of<Settings>(context);

    // Refresh on Command
    if (settings.refreshMyposts) {
      settings.refreshMyposts = false;
      _onRefresh();
    }

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
          onLoading: () => _onLoading(),
          onRefresh: () => _onRefresh(),
          header: MaterialClassicHeader(),
          child: loading
              ? Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  reverse: true,
                  slivers: [
                    SliverAppBar(
                      leading: Container(),
                      floating: true,
                      backgroundColor:
                          settings.darkMode ? Colors.black : Colors.white,
                      elevation: 0,
                      flexibleSpace: FlatButton(
                        splashColor:
                            settings.darkMode ? Colors.red : Colors.black,
                        highlightColor:
                            settings.darkMode ? Colors.red : Colors.grey,
                        minWidth: double.infinity,
                        height: 75,
                        child: Text(
                          'Create New Post',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                settings.darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ScreenCreatePosts();
                          }));
                        },
                      ),
                    ),
                    _testList.length > 0
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Posts(_testList[index]);
                              },
                              childCount:
                                  min(_testList.length, settings.personalNum),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildListDelegate([
                              Container(
                                width: double.infinity,
                                height: 625,
                                child: Center(
                                  child: Text(
                                    'No Created Posts...',
                                    style: TextStyle(
                                        color: settings.darkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                  ],
                ),
        ),
      ),
    );
  }
}
