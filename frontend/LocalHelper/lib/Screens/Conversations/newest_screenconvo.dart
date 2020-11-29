import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localhelper/Additions/Providers/authSettings.dart';
import 'package:provider/provider.dart';
import 'package:localhelper/Additions/Widgets/convo_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScreenConvo extends StatefulWidget {
  @override
  _ScreenConvoState createState() => _ScreenConvoState();
}

class _ScreenConvoState extends State<ScreenConvo> {
  List convoList = List();
  List usersList = List();
  List<int> ofConvoId = List();
  bool loading = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  // pass in a convo id and it should return a list of users related to the convo
  void getUserList(int convoId) async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
      };
      String link =
          'https://localhelper-backend.herokuapp.com/api/convos/uofc/' +
              convoId.toString();

      // HTTP Get
      http.Response response =
          await http.get(link, headers: headers).timeout(Duration(seconds: 20));

      // If it worked
      if (response.statusCode == 200) {
        List json = jsonDecode(response.body);
        usersList = json;
      }
    } catch (e) {
      print(e);
    }
  }

  // pass in the logged in user's id and it returns a list of convos
  void getConvoList(int ownerId) async {
    setState(() {
      loading = true;
    });

    try {
      Map<String, String> headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
      };
      String link =
          'https://localhelper-backend.herokuapp.com/api/convos/cofu/' +
              ownerId.toString();

      // HTTP Get
      http.Response response =
          await http.get(link, headers: headers).timeout(Duration(seconds: 20));

      // If it worked
      if (response.statusCode == 200) {
        List json = jsonDecode(response.body);
        convoList = json;
        for (int i = 0; i < convoList.length; i++) {
          ofConvoId.add(convoList[i]['id']);
        }
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      loading = false;
      _refreshController.loadComplete();
    });
  }

  void _onRefresh() async {
    setState(() {
      // Clear the lists
      convoList.clear();
      usersList.clear();
      ofConvoId.clear();

      // Trigger controller complete
      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthSettings authSettings = Provider.of<AuthSettings>(context);

    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Conversation Screen',
          ),
        ),
        body: SmartRefresher(
          physics: BouncingScrollPhysics(),
          enablePullDown: true,
          controller: _refreshController,
          onLoading: () => getConvoList(authSettings.ownerId),
          onRefresh: () => _onRefresh(),
          header: MaterialClassicHeader(),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  convoList.toString(),
                  // usersList.toString(),
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          // body: ListView(
          //   children: [
          //     //  IDK if this is nescessary
          //     Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Text(
          //         convoList.toString(),
          //         // usersList.toString(),
          //         style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          //         textAlign: TextAlign.start,
          //       ),
          //     ),
          //Convos(convoList[0], authSettings.ownerId),
          // Convos(convoList[1], authSettings.ownerId),
          // Convos(convoList[2], authSettings.ownerId)
          // MESSAGE 1
          // Padding(
          //   padding:
          //       const EdgeInsets.only(top: 35, left: 16, right: 16, bottom: 16),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.grey,
          //       borderRadius: BorderRadius.all(
          //         Radius.circular(18),
          //       ),
          //     ),
          //     width: double.infinity,
          //     height: 75,
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             children: [
          //               SizedBox(
          //                 width: 210,
          //                 child: Text(
          //                   'Zachary Garces',
          //                   style: TextStyle(
          //                     fontSize: 25,
          //                   ),
          //                   textAlign: TextAlign.start,
          //                 ),
          //               ),
          //               Container(
          //                 // color: Colors.white,
          //                 alignment: Alignment.bottomRight,
          //                 width: 150,
          //                 height: 55,
          //                 child: Text(
          //                   'Last message at 7:16 pm',
          //                   style: TextStyle(
          //                     fontSize: 16,
          //                   ),
          //                   textAlign: TextAlign.end,
          //                 ),
          //               )
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // // MESSAGE 2
          // Padding(
          //   padding:
          //       const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.grey,
          //       borderRadius: BorderRadius.all(
          //         Radius.circular(18),
          //       ),
          //     ),
          //     width: double.infinity,
          //     height: 75,
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             children: [
          //               SizedBox(
          //                 width: 210,
          //                 child: Text(
          //                   'Kun Yu',
          //                   style: TextStyle(
          //                     fontSize: 25,
          //                   ),
          //                   textAlign: TextAlign.start,
          //                 ),
          //               ),
          //               Container(
          //                 // color: Colors.white,
          //                 alignment: Alignment.bottomRight,
          //                 width: 150,
          //                 height: 55,
          //                 child: Text(
          //                   'Last message at 4:44 am',
          //                   style: TextStyle(
          //                     fontSize: 16,
          //                   ),
          //                   textAlign: TextAlign.end,
          //                 ),
          //               )
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // // MESSAGE 3
          // Padding(
          //   padding:
          //       const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.grey,
          //       borderRadius: BorderRadius.all(
          //         Radius.circular(18),
          //       ),
          //     ),
          //     width: double.infinity,
          //     height: 75,
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             children: [
          //               SizedBox(
          //                 width: 210,
          //                 child: Text(
          //                   'Thomas Westfall',
          //                   style: TextStyle(
          //                     fontSize: 25,
          //                   ),
          //                   textAlign: TextAlign.start,
          //                 ),
          //               ),
          //               Container(
          //                 // color: Colors.white,
          //                 alignment: Alignment.bottomRight,
          //                 width: 150,
          //                 height: 55,
          //                 child: Text(
          //                   'Last message at 6:25 pm',
          //                   style: TextStyle(
          //                     fontSize: 16,
          //                   ),
          //                   textAlign: TextAlign.end,
          //                 ),
          //               )
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // // MESSAGE 4
          // Padding(
          //   padding:
          //       const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.grey,
          //       borderRadius: BorderRadius.all(
          //         Radius.circular(18),
          //       ),
          //     ),
          //     width: double.infinity,
          //     height: 75,
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             children: [
          //               SizedBox(
          //                 width: 210,
          //                 child: Text(
          //                   'Alexander Yang',
          //                   style: TextStyle(
          //                     fontSize: 25,
          //                   ),
          //                   textAlign: TextAlign.start,
          //                 ),
          //               ),
          //               Container(
          //                 // color: Colors.white,
          //                 alignment: Alignment.bottomRight,
          //                 width: 150,
          //                 height: 55,
          //                 child: Text(
          //                   'Last message at 1:30 am',
          //                   style: TextStyle(
          //                     fontSize: 16,
          //                   ),
          //                   textAlign: TextAlign.end,
          //                 ),
          //               )
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // // MESSAGE 5
          // Padding(
          //   padding:
          //       const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.grey,
          //       borderRadius: BorderRadius.all(
          //         Radius.circular(18),
          //       ),
          //     ),
          //     width: double.infinity,
          //     height: 75,
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             children: [
          //               SizedBox(
          //                 width: 210,
          //                 child: Text(
          //                   'Test User123',
          //                   style: TextStyle(
          //                     fontSize: 25,
          //                   ),
          //                   textAlign: TextAlign.start,
          //                 ),
          //               ),
          //               Container(
          //                 // color: Colors.white,
          //                 alignment: Alignment.bottomRight,
          //                 width: 150,
          //                 height: 55,
          //                 child: Text(
          //                   'Last message at 12:00 am',
          //                   style: TextStyle(
          //                     fontSize: 16,
          //                   ),
          //                   textAlign: TextAlign.end,
          //                 ),
          //               )
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // // MESSAGE 6
          // Padding(
          //   padding:
          //       const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.grey,
          //       borderRadius: BorderRadius.all(
          //         Radius.circular(18),
          //       ),
          //     ),
          //     width: double.infinity,
          //     height: 75,
          //     child: Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             children: [
          //               SizedBox(
          //                 width: 210,
          //                 child: Text(
          //                   'Overflow Test',
          //                   style: TextStyle(
          //                     fontSize: 25,
          //                   ),
          //                   textAlign: TextAlign.start,
          //                 ),
          //               ),
          //               Container(
          //                 // color: Colors.white,
          //                 alignment: Alignment.bottomRight,
          //                 width: 150,
          //                 height: 55,
          //                 child: Text(
          //                   'Last message at 11:11 am',
          //                   style: TextStyle(
          //                     fontSize: 16,
          //                   ),
          //                   textAlign: TextAlign.end,
          //                 ),
          //               )
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          //],
        ),
      ),
    );
  }
}
