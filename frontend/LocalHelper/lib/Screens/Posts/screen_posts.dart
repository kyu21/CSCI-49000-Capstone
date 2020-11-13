import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:localhelper/Additions/Widgets/posts_widget.dart';
import 'package:localhelper/Additions/Providers/settings.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

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

  bool loading = false;

  List<bool> isSelection = [false, false];

// =============================================================================
// FUNCTIONS ===================================================================

  @override
  void dispose() {
    zipController.dispose();
    super.dispose();
  }

  void _onRefresh(String token, String z) async {
    setState(() {
      // Reset start value
      Provider.of<Settings>(context, listen: false).updateListNum(0);

      // Clear the lists
      postInfo.clear();

      // Find Images
      _onLoading(token, z);

      // Trigger controller complete
      _refreshController.refreshCompleted();
    });
  }

  void _onLoading(String token, String z) async {
    // Settings
    int maxLoad = 5;
    int timeout = 10;

    setState(() {
      loading = true;
    });

    // Starting index
    int startI = Provider.of<Settings>(context, listen: false).listNum;

    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': token,
      };

      http.Response response = await http
          .get('https://localhelper-backend.herokuapp.com/api/posts',
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

              // Loop through zips
              if (z != "") {
                bool _found = false;

                for (int i = 0; i < json[newIndex]['zips'].length; i++) {
                  if (json[newIndex]['zips'][i]['zip'] == z) {
                    postInfo.add(json[newIndex]);
                    _found = true;
                    Provider.of<Settings>(context, listen: false)
                        .updateListNum(newIndex + 1);
                    break;
                  }
                }

                // If couldn't find
                if (!_found) {
                  maxLoad++;
                  Provider.of<Settings>(context, listen: false)
                      .updateListNum(newIndex + 1);
                }

                // Scan normally
              } else {
                postInfo.add(json[newIndex]);
                // Remember placement
                Provider.of<Settings>(context, listen: false)
                    .updateListNum(newIndex + 1);
              }
            }
          }
        });

        // Stop the refresh animation
        _refreshController.loadComplete();
        setState(() {
          loading = false;
        });
      } else {
        // handle it
        print("Can't get info.");

        // Stop the refresh animation
        _refreshController.loadComplete();
        setState(() {
          loading = false;
        });
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      _refreshController.loadComplete();
      setState(() {
        loading = false;
      });
    } on SocketException {
      _refreshController.loadComplete();
      setState(() {
        loading = false;
      });
    }
  }

// =============================================================================
// WIDGETS =====================================================================

  TextFormField zipSearch(Settings settings, AuthSettings authSettings) {
    return TextFormField(
      cursorColor: settings.darkMode ? Colors.white : Colors.black,
      keyboardType: TextInputType.number,
      onEditingComplete: () =>
          _onRefresh(authSettings.token, zipController.text),
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
      Settings settings, AuthSettings authSettings, String z) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ToggleButtons(
        splashColor: Colors.transparent,
        borderColor: Colors.transparent,
        selectedBorderColor: Colors.transparent,
        selectedColor: Colors.transparent,
        fillColor: Colors.transparent,
        children: [
          // Request
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 80,
              height: 25,
              decoration: BoxDecoration(
                  color: isSelection[0]
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
                  color: isSelection[0]
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
                  color: isSelection[1]
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
                  color: isSelection[1]
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
          setState(() async {
            isSelection[index] = !isSelection[index];
            await _onRefresh(authSettings.token, z);
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
      _onRefresh(authSettings.token, zipController.text);
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
            onLoading: () => _onLoading(authSettings.token, zipController.text),
            onRefresh: () => _onRefresh(authSettings.token, zipController.text),
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
                              sliverToggleButtons(
                                  settings, authSettings, zipController.text),
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
                              return Posts(postInfo[index]);
                            }
                          },
                          childCount: postInfo.length,
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
                              sliverToggleButtons(
                                  settings, authSettings, zipController.text),
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
                              child: CircularProgressIndicator(),
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
