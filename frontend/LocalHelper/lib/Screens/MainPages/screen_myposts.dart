// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localhelper/settings.dart';

// import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScreenMyPosts extends StatefulWidget {
  @override
  _ScreenMyPosts createState() => _ScreenMyPosts();
}

class _ScreenMyPosts extends State<ScreenMyPosts> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  List<String> _backgroundInfo = List(); // Holds the background images url
  List<dynamic> _networkInfo = List(); // Holds a json of people

  Settings settings;

  @override
  void initState() {
    settings = context.read<Settings>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) {
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
                  // Search Bar
                  SliverPadding(
                    padding: EdgeInsets.only(left: 4, right: 4),
                    sliver: SliverAppBar(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      floating: true,
                      pinned: false,
                      expandedHeight: 100,
                      backgroundColor:
                          settings.darkMode ? Colors.black45 : Colors.white54,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        titlePadding: EdgeInsetsDirectional.only(top: 75),
                        collapseMode: CollapseMode.parallax,
                        background: Column(
                          children: [
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextField(
                                onSubmitted: (str) {
                                  print(str);
                                  // Empty for now
                                },
                                decoration: InputDecoration(
                                  hintText: "Search...",
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade400),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade100,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Posts(
                            _networkInfo[index], _backgroundInfo[index]);
                      },
                      childCount: _networkInfo.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onRefresh() async {
    // Clear the lists
    _networkInfo.clear();
    _backgroundInfo.clear();

    // Find Images
    _onLoading();

    // Trigger controller complete
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // Used to load posts from My stuff
    // NOT IMPLMENTED YET!!!

    _refreshController.loadComplete();
  }
}

// POSTS STUFF
class Posts extends StatelessWidget {
  final double rad = 30;
  final Map<String, dynamic> info;
  final String background;
  Posts(this.info, this.background);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(background),
                fit: BoxFit.cover,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(rad),
                topRight: Radius.circular(rad),
                bottomLeft: Radius.circular(rad),
                bottomRight: Radius.circular(rad),
              ),
            ),
            width: double.infinity,
            height: 300,
          ),
          Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(info['results'][0]['picture']['large']),
                    radius: 25,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(info['results'][0]['name']['first'] +
                          ' ' +
                          info['results'][0]['name']['last']),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
