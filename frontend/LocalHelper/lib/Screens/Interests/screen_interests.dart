import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Widgets/posts_widget.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class ScreenInterests extends StatefulWidget {
  @override
  _ScreenInterests createState() => _ScreenInterests();
}

class _ScreenInterests extends State<ScreenInterests> {
// VARIABLES ===================================================================

  // Controllers
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  // Lists
  List interestList = List();

  // Booleans
  bool loading = false;
  bool postsFound = false;

  // Toggle booleans
  final int bAll = 0;
  final int bRequest = 1;
  final int bFree = 2;
  List<bool> isSelection = [
    true, // All
    false, // Request
    false, // Free
  ];

// =============================================================================
// FUNCTIONS ===================================================================

  void _onRefresh() async {
    setState(() {
      // Reset start value
      Provider.of<Settings>(context, listen: false).interestNum = 0;

      // Clear the lists
      interestList.clear();

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
      postsFound = false;
    });

    // Settings
    final int timeout = 10;
    final newAmount = 10;

    // Providers
    Provider.of<Settings>(context, listen: false).updateInterestNum(newAmount);
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
          .get('https://localhelper-backend.herokuapp.com/api/users/me',
              headers: headers)
          .timeout(Duration(seconds: timeout));

      var json = jsonDecode(response.body);

      // If got a response
      if (response.statusCode == 200) {
        interestList = json['interests'];
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
// WIDGETS =====================================================================

// Toggle Buttons
  Widget sliverToggleButtons(Settings settings, AuthSettings authSettings) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ToggleButtons(
          splashColor: Colors.transparent,
          borderColor: Colors.transparent,
          selectedBorderColor: Colors.transparent,
          selectedColor: Colors.transparent,
          fillColor: Colors.transparent,
          children: [
            // All
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 80,
                height: 25,
                decoration: BoxDecoration(
                    color: isSelection[bAll]
                        ? settings.darkMode
                            ? Colors.white
                            : Colors.black
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelection[bAll]
                        ? settings.darkMode
                            ? Colors.black
                            : Colors.white
                        : Colors.white70,
                  ),
                )),
              ),
            ),

            // Request
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 80,
                height: 25,
                decoration: BoxDecoration(
                    color: isSelection[bRequest]
                        ? settings.darkMode
                            ? Colors.white
                            : Colors.black
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(
                  'Request',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelection[bRequest]
                        ? settings.darkMode
                            ? Colors.black
                            : Colors.white
                        : Colors.white70,
                  ),
                )),
              ),
            ),

            // Free
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 80,
                height: 25,
                decoration: BoxDecoration(
                    color: isSelection[bFree]
                        ? settings.darkMode
                            ? Colors.white
                            : Colors.black
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(
                  'Free',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelection[bFree]
                        ? settings.darkMode
                            ? Colors.black
                            : Colors.white
                        : Colors.white70,
                  ),
                )),
              ),
            ),
          ],
          onPressed: (index) {
            setState(() {
              // ALL
              if (index == bAll) {
                if (!isSelection[bAll]) {
                  for (int i = 0; i < isSelection.length; i++) {
                    isSelection[i] = false;
                  }
                  isSelection[bAll] = true;
                } else {
                  isSelection[bAll] = false;
                }

                // Others
              } else {
                isSelection[bAll] = false;
                isSelection[index] = !isSelection[index];
              }
              _onRefresh();
            });
          },
          isSelected: isSelection,
        ),
      ),
    );
  }

// Found Posts
  CustomScrollView foundPosts(Settings settings, AuthSettings authSettings) {
    return CustomScrollView(
      reverse: true,
      slivers: [
        // Toggle Buttons
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          pinned: false,
          floating: false,
          flexibleSpace: sliverToggleButtons(settings, authSettings),
        ),

        // Posts
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (interestList.isEmpty) {
                return Container(
                  color: Colors.black,
                );
              } else {
                // CHECKS----------------------------------------
                bool checkRequest = false;
                bool checkFree = false;

                // Check if request
                if (interestList[index]['is_request'] == isSelection[bRequest])
                  checkRequest = true;

                // Check Free
                if (interestList[index]['free'] == isSelection[bFree])
                  checkFree = true;

                // -----------------------------------------------

                // ALL
                if (isSelection[bAll]) {
                  postsFound = true;
                  return Posts(interestList[index]);
                  // NOT ALL
                } else {
                  if (checkRequest && checkFree) {
                    postsFound = true;
                    return Posts(interestList[index]);
                  } else {
                    if (index == interestList.length - 1) {
                      if (!postsFound) {
                        return Container(
                          height: 550,
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              'No Posts Found...',
                              style: TextStyle(
                                  color: settings.darkMode
                                      ? settings.colorBlue
                                      : Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 20),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    } else {
                      return Container();
                    }
                  }
                }
              }
            },
            childCount: min(interestList.length, settings.personalNum),
          ),
        ),
      ],
    );
  }

// No Posts
  CustomScrollView noPosts(Settings settings, AuthSettings authSettings) {
    return CustomScrollView(
      reverse: true,
      slivers: [
        // Toggle Buttons
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          pinned: false,
          floating: false,
          flexibleSpace: sliverToggleButtons(settings, authSettings),
        ),

        // No Posts Found
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              height: 500,
              color: Colors.transparent,
              child: Center(
                child: loading
                    ? CircularProgressIndicator()
                    : Text(
                        'No Interests Made...',
                        style: TextStyle(
                            color: settings.darkMode
                                ? settings.colorBlue
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
    );
  }

// =============================================================================
// MAIN ========================================================================

  @override
  Widget build(BuildContext context) {
    // Providers
    Settings settings = Provider.of<Settings>(context);
    AuthSettings authSettings = Provider.of<AuthSettings>(context);

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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: settings.darkMode
                  ? [
                      settings.colorBackground,
                      settings.colorBackground,
                      Colors.black87,
                    ]
                  : [Colors.white, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SmartRefresher(
            physics: BouncingScrollPhysics(),
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            onLoading: () => _onLoading(),
            onRefresh: () => _onRefresh(),
            header: MaterialClassicHeader(),
            child: interestList.isNotEmpty
                ? foundPosts(settings, authSettings)
                : noPosts(settings, authSettings),
          ),
        ),
      ),
    );
  }
}
