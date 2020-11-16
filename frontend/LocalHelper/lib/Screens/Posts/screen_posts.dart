import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Widgets/posts_widget.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class ScreenPosts extends StatefulWidget {
  @override
  _ScreenPostsState createState() => _ScreenPostsState();
}

class _ScreenPostsState extends State<ScreenPosts> {
// VARIABLES ===================================================================

  // Controllers
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  TextEditingController zipController = TextEditingController();

  List postInfo = List(); // Holds a json of people

  // Booleans
  bool loading = false;
  bool postsFound = false;

  // Toggle booleans
  final int bAll = 0;
  final int bRequest = 1;
  final int bLocal = 2;
  final int bSelf = 3;
  List<bool> isSelection = [
    true, // All
    false, // Request
    false, // Local
    false, // Self
  ];

// =============================================================================
// FUNCTIONS ===================================================================

  @override
  void dispose() {
    zipController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    setState(() {
      // Reset start value
      Provider.of<Settings>(context, listen: false).listNum = 0;

      // Clear the lists
      postInfo.clear();

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
      postsFound = false;
    });

    // Settings
    final int timeout = 10;
    final int newAmount = 5;

    // Providers
    Provider.of<Settings>(context, listen: false).updateListNum(newAmount);
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
          .get('https://localhelper-backend.herokuapp.com/api/posts',
              headers: headers)
          .timeout(Duration(seconds: timeout));

      // If it worked
      if (response.statusCode == 200) {
        List json = jsonDecode(response.body);
        postInfo = json;
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

  TextFormField zipSearch(Settings settings, AuthSettings authSettings) {
    return TextFormField(
      enabled: !isSelection[bLocal],
      cursorColor: settings.darkMode ? Colors.white : Colors.black,
      keyboardType: TextInputType.number,
      onEditingComplete: () => _onRefresh(),
      controller: zipController,
      style: TextStyle(color: settings.darkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: 'Zip',
        hintStyle:
            TextStyle(color: settings.darkMode ? Colors.white : Colors.black),
        icon: Icon(
          Icons.search,
          color: settings.darkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  SingleChildScrollView sliverToggleButtons(
      Settings settings, AuthSettings authSettings) {
    return SingleChildScrollView(
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

          // Local
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 80,
              height: 25,
              decoration: BoxDecoration(
                  color: isSelection[bLocal]
                      ? settings.darkMode
                          ? Colors.white
                          : Colors.black
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(
                'Local',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelection[bLocal]
                      ? settings.darkMode
                          ? Colors.black
                          : Colors.white
                      : Colors.white70,
                ),
              )),
            ),
          ),

          // Self
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 80,
              height: 25,
              decoration: BoxDecoration(
                  color: isSelection[bSelf]
                      ? settings.darkMode
                          ? Colors.white
                          : Colors.black
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(
                'Self',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelection[bSelf]
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

              if (isSelection[bLocal]) {
                zipController.clear();
              }
            }

            _onRefresh();
          });
        },
        isSelected: isSelection,
      ),
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
    if (settings.refreshPosts) {
      settings.refreshPosts = false;
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
            child: postInfo.isNotEmpty
                ? CustomScrollView(
                    reverse: true,
                    slivers: [
                      SliverAppBar(
                        backgroundColor:
                            settings.darkMode ? Colors.black : Colors.white,
                        floating: true,
                        automaticallyImplyLeading: false,
                        elevation: 0,
                        expandedHeight: 105,
                        flexibleSpace: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              // Zip Search
                              zipSearch(settings, authSettings),

                              // Toggle Buttons
                              SizedBox(height: 10),
                              sliverToggleButtons(settings, authSettings),
                            ],
                          ),
                        ),
                      ),
                      // Posts
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (postInfo.isEmpty) {
                              return Container(
                                color: Colors.black,
                              );
                            } else {
                              // CHECKS----------------------------------------
                              bool checkRequest = false;
                              bool checkZip = false;
                              bool checkSelf = false;

                              // Check if request
                              if (postInfo[index]['post']['is_request'] ==
                                  isSelection[bRequest]) checkRequest = true;

                              // Check Zips
                              if (zipController.text.isNotEmpty) {
                                for (int i = 0;
                                    i < postInfo[index]['zips'].length;
                                    i++) {
                                  if (postInfo[index]['zips'][i]['zip'] ==
                                      zipController.text) {
                                    checkZip = true;
                                    break;
                                  }
                                }
                              } else {
                                if (isSelection[bLocal]) {
                                  if (postInfo[index]['zips'].length > 0) {
                                    if (postInfo[index]['zips'].last['zip'] ==
                                        authSettings.zip) checkZip = true;

                                    if (authSettings.zip == "None")
                                      checkZip = false;
                                  }
                                } else {
                                  checkZip = true;
                                }
                              }

                              // Self Check
                              if (isSelection[bSelf]) {
                                if (postInfo[index]['owner']['id'] ==
                                    authSettings.ownerId) {
                                  checkSelf = true;
                                }
                              } else {
                                if (postInfo[index]['owner']['id'] !=
                                    authSettings.ownerId) {
                                  checkSelf = true;
                                }
                              }

                              // -----------------------------------------------

                              // ALL
                              if (isSelection[bAll]) {
                                if (checkZip) {
                                  postsFound = true;
                                  return Posts(postInfo[index]);
                                } else {
                                  return Container();
                                }

                                // NOT ALL
                              } else {
                                if (checkRequest && checkZip && checkSelf) {
                                  postsFound = true;
                                  return Posts(postInfo[index]);
                                } else {
                                  if (index == postInfo.length - 1) {
                                    if (!postsFound) {
                                      return Container(
                                        height: 550,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            'No Posts Found...',
                                            style: TextStyle(
                                                color: settings.darkMode
                                                    ? Colors.white
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
                          childCount: min(postInfo.length, settings.listNum),
                        ),
                      ),
                    ],
                  )
                : CustomScrollView(
                    reverse: true,
                    slivers: [
                      SliverAppBar(
                        backgroundColor:
                            settings.darkMode ? Colors.black : Colors.white,
                        floating: true,
                        automaticallyImplyLeading: false,
                        elevation: 0,
                        expandedHeight: 105,
                        flexibleSpace: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              // Zip Search
                              zipSearch(settings, authSettings),

                              // Toggle Buttons
                              SizedBox(height: 10),
                              sliverToggleButtons(settings, authSettings),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            height: 500,
                            color: Colors.transparent,
                            child: Center(
                              child: loading
                                  ? CircularProgressIndicator()
                                  : Text(
                                      'No Posts...',
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
                  )),
      ),
    );
  }
}
