import 'package:flutter/material.dart';

class ScreenPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            expandedHeight: 75,
            backgroundColor: Colors.black,
            centerTitle: true,
            title: Text(
              'Local Posts',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Posts(),
              Posts(),
              Posts(),
              Posts(),
              Posts(),
              Posts(),
              Posts(),
              Posts(),
              Posts(),
              Posts(),
              Posts(),
              Posts(),
            ]),
          ),
        ],
      ),
    );
  }
}

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final double rad = 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
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
