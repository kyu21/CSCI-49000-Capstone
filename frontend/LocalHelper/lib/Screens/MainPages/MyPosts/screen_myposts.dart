import 'package:flutter/material.dart';
import 'package:localhelper/Additions/settings.dart';
import 'package:localhelper/Screens/MainPages/MyPosts/personalPosts.dart';
import 'package:localhelper/Screens/MainPages/MyPosts/screen_createposts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScreenMyPosts extends StatefulWidget {
  @override
  _ScreenMyPosts createState() => _ScreenMyPosts();
}

class _ScreenMyPosts extends State<ScreenMyPosts> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  List<MyPosts> _testList = List();

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
              SliverList(
                delegate: SliverChildListDelegate([
                  FlatButton(
                    splashColor: settings.darkMode ? Colors.red : Colors.black,
                    highlightColor:
                        settings.darkMode ? Colors.red : Colors.grey,
                    minWidth: double.infinity,
                    height: 70,
                    child: Text(
                      'Create New Post',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: settings.darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onPressed: () async {
                      var navResults = await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ScreenCreatePosts();
                      }));
                      if (navResults != null) {
                        setState(() {
                          _testList.add(navResults);
                        });
                      }
                    },
                  ),
                ]),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (_testList.isEmpty)
                      return Column(
                        children: [
                          Icon(
                            Icons.device_unknown_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'You have no posts...',
                            style: TextStyle(
                              color: settings.darkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 300),
                        ],
                      );
                    else
                      return _testList[index];
                  },
                  childCount: _testList.isEmpty ? 1 : _testList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FUNCTIONS

  void _onRefresh() async {
    setState(() {
      _testList.clear();
    });

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

// Search Bar
class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
