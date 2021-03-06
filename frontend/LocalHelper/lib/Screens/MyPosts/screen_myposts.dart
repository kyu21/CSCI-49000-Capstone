import 'package:chips_choice/chips_choice.dart';
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
  TextEditingController termController = TextEditingController();

  // Lists
  List _testList = List();

  // Booleans
  bool loading = false;
  bool postsFound = false;

  // Filters
  List<String> filterOption = ['All'];
  List<String> filter = [
    'All',
    'Request',
    'Free',
  ];

  // Categories
  List<String> categoryOptions = ['All'];
  List<String> category = [
    'All',
    'Teaching',
    'Shopping',
    'Entertainment',
    'Repair',
    'Delivery',
    'Babysitting',
    'Tech Support',
    'Coaching',
    'Cleaning',
    'Other',
  ];

  // Languages
  List<String> languageOption = ['All'];
  List<String> language = [
    'All',
    'English',
    'Spanish',
    'Chinese',
    'Hindi',
    'Arabic',
    'Bengali',
    'Portuguese',
    'Russian',
    'Japanese',
  ];

// =============================================================================
// FUNCTIONS ===================================================================

  void _onRefresh() async {
    if (this.mounted) {
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
  }

  void _onLoading() async {
    // VARIABLES ---------------------------------------------------------------

    if (this.mounted) {
      setState(() {
        loading = true;
        postsFound = false;
      });
    }

    // Settings
    final int timeout = 10;
    final newAmount = 10;

    // Providers
    Provider.of<Settings>(context, listen: false).updatePersonalNum(newAmount);
    final String token =
        Provider.of<AuthSettings>(context, listen: false).token;
    final int ownerID =
        Provider.of<AuthSettings>(context, listen: false).ownerId;

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

      var json = jsonDecode(response.body);

      // If got a response
      if (response.statusCode == 200) {
        _testList = json;
      }

      // CHECKERS ==============================================================

      List tempList = [];

      // Checks
      for (int i = 0; i < _testList.length; i++) {
        bool checkRequest = false;
        bool checkFree = false;
        bool checkCategory = false;
        bool checkLanguage = false;
        bool checkSelf = false;

        // Filters
        if (filterOption.contains('All')) {
          // Request
          if (filterOption.contains('Request')) {
            checkRequest = _testList[i]['is_request'];
          } else {
            checkRequest = true;
          }

          // Free
          if (filterOption.contains('Free')) {
            checkFree = _testList[i]['free'];
          } else {
            checkFree = true;
          }
        } else {
          // Request
          if (filterOption.contains('Request') == _testList[i]['is_request']) {
            checkRequest = true;
          }
          // Request
          if (filterOption.contains('Free') == _testList[i]['free']) {
            checkFree = true;
          }
        }

        // Categories
        if (categoryOptions.contains('All')) {
          checkCategory = true;
        } else {
          if (_testList[i]['categories'].length > 0) {
            for (int j = 0; j < _testList[i]['categories'].length; j++) {
              if (categoryOptions
                  .contains(_testList[i]['categories'][j]['name'])) {
                checkCategory = true;
              }
            }
          }
        }

        // Languages
        if (languageOption.contains('All')) {
          checkLanguage = true;
        } else {
          if (_testList[i]['languages'].length > 0) {
            for (int j = 0; j < _testList[i]['languages'].length; j++) {
              if (languageOption
                  .contains(_testList[i]['languages'][j]['name'])) {
                checkLanguage = true;
              }
            }
          }
        }

        // Self Check
        if (_testList[i]['ownerId'] == ownerID) checkSelf = true;

        // Add to temp list
        if (checkRequest &&
            checkFree &&
            checkCategory &&
            checkLanguage &&
            checkSelf) tempList.add(_testList[i]);
      }

      _testList.clear();
      _testList = tempList;

      // =======================================================================

    } catch (e) {
      print(e);
    }
    if (this.mounted) {
      setState(() {
        loading = false;
        _refreshController.loadComplete();
      });
    }
  }

// =============================================================================
// WIDGETS =====================================================================

  // Filter
  Widget filterDrop(Settings settings) {
    return Column(
      children: [
        // Categories
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ChipsChoice<String>.multiple(
            choiceActiveStyle: C2ChoiceStyle(
              brightness: Brightness.dark,
              color: settings.darkMode ? settings.colorBlue : Colors.black,
              labelStyle: TextStyle(
                  color: settings.darkMode
                      ? settings.colorBackground
                      : Colors.white),
            ),
            choiceStyle: C2ChoiceStyle(
              color: settings.darkMode ? settings.colorBackground : Colors.grey,
              brightness: Brightness.dark,
            ),
            scrollPhysics: BouncingScrollPhysics(),
            value: filterOption,
            onChanged: (val) {
              setState(() {
                filterOption = val;
                _onRefresh();
              });
            },
            choiceItems: C2Choice.listFrom<String, String>(
              source: filter,
              value: (i, v) => v,
              label: (i, v) => v,
            ),
          ),
        ),
      ],
    );
  }

  // Language
  Widget languageDrop(Settings settings) {
    return Column(
      children: [
        // Categories
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ChipsChoice<String>.multiple(
            choiceActiveStyle: C2ChoiceStyle(
              brightness: Brightness.dark,
              color: settings.darkMode ? settings.colorBlue : Colors.black,
              labelStyle: TextStyle(
                  color: settings.darkMode
                      ? settings.colorBackground
                      : Colors.white),
            ),
            choiceStyle: C2ChoiceStyle(
              color: settings.darkMode ? settings.colorBackground : Colors.grey,
              brightness: Brightness.dark,
            ),
            scrollPhysics: BouncingScrollPhysics(),
            value: languageOption,
            onChanged: (val) {
              setState(() {
                final bool allBefore = languageOption.contains('All');
                languageOption = val;
                if (allBefore) {
                  if (languageOption.length > 1) {
                    if (languageOption.contains('All')) {
                      languageOption.remove('All');
                    }
                  }
                } else {
                  if (languageOption.contains('All')) {
                    languageOption.clear();
                    languageOption.add('All');
                  }
                }
                _onRefresh();
              });
            },
            choiceItems: C2Choice.listFrom<String, String>(
              source: language,
              value: (i, v) => v,
              label: (i, v) => v,
            ),
          ),
        ),
      ],
    );
  }

  // Categories
  Widget categoryDrop(Settings settings) {
    return Column(
      children: [
        // Categories
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ChipsChoice<String>.multiple(
            choiceActiveStyle: C2ChoiceStyle(
              brightness: Brightness.dark,
              color: settings.darkMode ? settings.colorBlue : Colors.black,
              labelStyle: TextStyle(
                  color: settings.darkMode
                      ? settings.colorBackground
                      : Colors.white),
            ),
            choiceStyle: C2ChoiceStyle(
              color: settings.darkMode ? settings.colorBackground : Colors.grey,
              brightness: Brightness.dark,
            ),
            scrollPhysics: BouncingScrollPhysics(),
            value: categoryOptions,
            onChanged: (val) {
              setState(() {
                final bool allBefore = categoryOptions.contains('All');
                categoryOptions = val;
                if (allBefore) {
                  if (categoryOptions.length > 1) {
                    if (categoryOptions.contains('All')) {
                      categoryOptions.remove('All');
                    }
                  }
                } else {
                  if (categoryOptions.contains('All')) {
                    categoryOptions.clear();
                    categoryOptions.add('All');
                  }
                }
                _onRefresh();
              });
            },
            choiceItems: C2Choice.listFrom<String, String>(
              source: category,
              value: (i, v) => v,
              label: (i, v) => v,
            ),
          ),
        ),
      ],
    );
  }

  // TermSearch
  TextFormField termSearch(Settings settings, AuthSettings authSettings) {
    return TextFormField(
      cursorColor: settings.darkMode ? Colors.white : Colors.black,
      onEditingComplete: () => _onRefresh(),
      controller: termController,
      style: TextStyle(color: settings.darkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle:
            TextStyle(color: settings.darkMode ? Colors.white : Colors.black),
        icon: Icon(
          Icons.search,
          color: settings.darkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

// Found Posts
  CustomScrollView foundPosts(Settings settings, AuthSettings authSettings) {
    return CustomScrollView(
      reverse: true,
      slivers: [
        // Create a Post
        SliverAppBar(
          automaticallyImplyLeading: false,
          floating: true,
          backgroundColor: settings.darkMode ? Colors.black : Colors.white,
          elevation: 0,
          flexibleSpace: FlatButton(
            splashColor:
                settings.darkMode ? settings.colorOpposite : Colors.black,
            highlightColor:
                settings.darkMode ? settings.colorOpposite : Colors.grey,
            minWidth: double.infinity,
            height: 75,
            child: Text(
              'Create New Post',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: settings.darkMode ? settings.colorLight : Colors.black,
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ScreenCreatePosts();
              }));
            },
          ),
        ),

        // Languages
        SliverAppBar(
            backgroundColor: settings.darkMode ? Colors.black : Colors.white,
            toolbarHeight: 20,
            expandedHeight: 35,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Center(child: languageDrop(settings))),

        // Categories
        SliverAppBar(
            backgroundColor: settings.darkMode ? Colors.black : Colors.white,
            toolbarHeight: 20,
            expandedHeight: 35,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Center(child: categoryDrop(settings))),

        // Filters
        SliverAppBar(
            backgroundColor: settings.darkMode ? Colors.black : Colors.white,
            toolbarHeight: 20,
            expandedHeight: 35,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Center(child: filterDrop(settings))),

        // Term Search
        SliverAppBar(
          backgroundColor: settings.darkMode ? Colors.black : Colors.white,
          floating: true,
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 40,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(10),
            child: termSearch(settings, authSettings),
          ),
        ),

        // Posts
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Posts(_testList[index]);
            },
            childCount: min(_testList.length, settings.personalNum),
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
        // Create a Post
        SliverAppBar(
          automaticallyImplyLeading: false,
          floating: true,
          backgroundColor: settings.darkMode ? Colors.black : Colors.white,
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
                color: settings.darkMode ? settings.colorLight : Colors.black,
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ScreenCreatePosts();
              }));
            },
          ),
        ),

        // Languages
        SliverAppBar(
            backgroundColor: settings.darkMode ? Colors.black : Colors.white,
            toolbarHeight: 20,
            expandedHeight: 35,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Center(child: languageDrop(settings))),

        // Categories
        SliverAppBar(
            backgroundColor: settings.darkMode ? Colors.black : Colors.white,
            toolbarHeight: 20,
            expandedHeight: 35,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Center(child: categoryDrop(settings))),

        // Filters
        SliverAppBar(
            backgroundColor: settings.darkMode ? Colors.black : Colors.white,
            toolbarHeight: 20,
            expandedHeight: 35,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Center(child: filterDrop(settings))),

        // Term Search
        SliverAppBar(
          backgroundColor: settings.darkMode ? Colors.black : Colors.white,
          floating: true,
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 40,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(10),
            child: termSearch(settings, authSettings),
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
                        'No Posts Created...',
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
            child: _testList.isNotEmpty
                ? foundPosts(settings, authSettings)
                : noPosts(settings, authSettings),
          ),
        ),
      ),
    );
  }
}
