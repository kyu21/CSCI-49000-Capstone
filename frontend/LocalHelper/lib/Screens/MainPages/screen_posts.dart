import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScreenPosts extends StatefulWidget {
  @override
  _ScreenPostsState createState() => _ScreenPostsState();
}

class _ScreenPostsState extends State<ScreenPosts> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<String> _backgroundsList = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SmartRefresher(
        physics: BouncingScrollPhysics(),
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        header: MaterialClassicHeader(),
        child: CustomScrollView(
          slivers: [
            // Title
            SliverAppBar(
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              pinned: false,
              centerTitle: true,
              title: Text(
                'LocalPosts',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              floating: false,
            ),
            // Search Bar
            SliverAppBar(
              floating: true,
              pinned: false,
              expandedHeight: 100,
              backgroundColor: Colors.black,
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Posts(_backgroundsList[index]);
                },
                childCount: _backgroundsList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRefresh() async {
    _backgroundsList.clear();
    _onLoading();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // Get five dog pictures
    for (int i = 0; i < 5; i++) {
      final response =
          await http.get('https://dog.ceo/api/breeds/image/random');

      if (response.statusCode == 200) {
        setState(() {
          _backgroundsList.add(jsonDecode(response.body)['message']);
        });
      } else {
        throw Exception('Failed to load image');
      }
    }
    _refreshController.loadComplete();
  }
}

// POSTS STUFF
class Posts extends StatelessWidget {
  final double rad = 30;
  final bUrl;
  Posts(this.bUrl);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(bUrl),
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
    );
  }
}
