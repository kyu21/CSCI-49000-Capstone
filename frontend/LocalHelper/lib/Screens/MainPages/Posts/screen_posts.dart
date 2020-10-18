import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScreenPosts extends StatefulWidget {
  @override
  _ScreenPostsState createState() => _ScreenPostsState();
}

class _ScreenPostsState extends State<ScreenPosts> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  List postInfo = List(); // Holds a json of people

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
                              hintStyle: TextStyle(color: Colors.grey.shade400),
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
                    return Posts(postInfo[index]);
                  },
                  childCount: postInfo.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRefresh() async {
    setState(() {
      // Reset start value
      Provider.of<Settings>(context, listen: false).updateListNum(0);

      // Clear the lists
      postInfo.clear();

      // Find Images
      _onLoading();

      // Trigger controller complete
      _refreshController.refreshCompleted();
    });
  }

  void _onLoading() async {
    // Settings
    final maxLoad = 3;

    // Starting index
    int startI = Provider.of<Settings>(context, listen: false).listNum;

    // Api information
    final response =
        await http.get('https://localhelper-backend.herokuapp.com/api/posts');

    // What happens when getting a response
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
            postInfo.add(json[newIndex]);

            // Remember placement
            Provider.of<Settings>(context, listen: false)
                .updateListNum(newIndex + 1);
          }
        }
      });

      // Stop the refresh animation
      _refreshController.loadComplete();
    }
  }
}

// POSTS STUFF
class Posts extends StatelessWidget {
  final double rad = 30;
  final info;
  Posts(this.info);
  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: settings.darkMode ? Colors.white : Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(rad),
            topRight: Radius.circular(rad),
            bottomLeft: Radius.circular(rad),
            bottomRight: Radius.circular(rad),
          ),
        ),
        width: double.infinity,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Name / Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info['owner']['first'] + ' ' + info['owner']['last'],
                        style: TextStyle(
                          color:
                              settings.darkMode ? Colors.black : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        info['post']['dateCreated'],
                        style: TextStyle(
                          color:
                              settings.darkMode ? Colors.black : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Title
                  SizedBox(width: 30),
                  Expanded(
                    child: Container(
                      child: Text(
                        info['post']['title'],
                        style: TextStyle(
                          color:
                              settings.darkMode ? Colors.black : Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  )
                ],
              ),

              // Description
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  child: Text(
                    info['post']['description'],
                    style: TextStyle(
                      color: settings.darkMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
