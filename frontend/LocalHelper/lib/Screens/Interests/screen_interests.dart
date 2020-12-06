import 'package:chips_choice/chips_choice.dart';
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
  TextEditingController termController = TextEditingController();

  // Lists
  List interestList = List();

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
    'General',
    'Other',
  ];

  // Languages
  List<String> languageOption = ['All'];
  List<String> language = [
    'All',
    'English',
    'Spanish',
    'Chinese',
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
          .get('https://localhelper-backend.herokuapp.com/api/users/me',
              headers: headers)
          .timeout(Duration(seconds: timeout));

      var json = jsonDecode(response.body);

      // If got a response
      if (response.statusCode == 200) {
        interestList = json['interests'];
      }

      // CHECKERS ==============================================================

      List tempList = [];

      // Checks
      for (int i = 0; i < interestList.length; i++) {
        bool checkRequest = false;
        bool checkFree = false;
        bool checkCategory = false;
        bool checkLanguage = false;
        bool checkSelf = false;

        // Filters
        if (filterOption.contains('All')) {
          checkRequest = true;
          checkFree = true;
        } else {
          // Request
          if (filterOption.contains('Request') ==
              interestList[i]['is_request']) {
            checkRequest = true;
          }
          // Request
          if (filterOption.contains('Free') == interestList[i]['free']) {
            checkFree = true;
          }
        }

        // Categories
        if (categoryOptions.contains('All')) {
          checkCategory = true;
        } else {
          if (interestList[i]['categories'].length > 0) {
            for (int j = 0; j < interestList[i]['categories'].length; j++) {
              if (categoryOptions
                  .contains(interestList[i]['categories'][j]['name'])) {
                checkCategory = true;
              }
            }
          }
        }

        // Languages
        if (languageOption.contains('All')) {
          checkLanguage = true;
        } else {
          if (interestList[i]['languages'].length > 0) {
            for (int j = 0; j < interestList[i]['languages'].length; j++) {
              if (languageOption
                  .contains(interestList[i]['languages'][j]['name'])) {
                checkLanguage = true;
              }
            }
          }
        }

        // Self Check
        if (interestList[i]['ownerId'] != ownerID) checkSelf = true;

        // Add to temp list
        if (checkRequest &&
            checkFree &&
            checkCategory &&
            checkLanguage &&
            checkSelf) tempList.add(interestList[i]);
      }

      interestList.clear();
      interestList = tempList;

      // =======================================================================

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
                if (filterOption.contains('All')) {
                  filterOption.clear();
                  filterOption.add('All');
                }
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
                languageOption = val;
                if (languageOption.contains('All')) {
                  languageOption.clear();
                  languageOption.add('All');
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
                categoryOptions = val;
                if (categoryOptions.contains('All')) {
                  categoryOptions.clear();
                  categoryOptions.add('All');
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
              return Posts(interestList[index]);
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
