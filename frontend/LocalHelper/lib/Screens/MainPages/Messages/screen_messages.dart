import 'package:flutter/material.dart';

import 'widget_chat.dart';

class ScreenMessages extends StatelessWidget {
  final List<ChatWidget> chatTest = [
    ChatWidget(
      text: "Terrence G",
      secondaryText: "Thanks!",
      image: 'assets/images/userImage1.jpeg',
    ),
    ChatWidget(
      text: "Mark Brown",
      secondaryText: "Where do you want to meet?",
      image: 'assets/images/userImage2.jpeg',
    ),
    ChatWidget(
      text: "Alissa White",
      secondaryText: "At central park",
      image: 'assets/images/userImage3.jpeg',
    ),
    ChatWidget(
      text: "Harry Bow",
      secondaryText: "i can wait",
      image: 'assets/images/userImage4.jpeg',
    ),
    ChatWidget(
      text: "Aria G",
      secondaryText: "nvm",
      image: 'assets/images/userImage5.jpeg',
    ),
    ChatWidget(
      text: "Jennifer",
      secondaryText: "lol whats this?",
      image: 'assets/images/userImage6.jpeg',
    ),
    ChatWidget(
      text: "Alexa",
      secondaryText: "Remember to be here by 8pm",
      image: 'assets/images/userImage7.jpeg',
    ),
    ChatWidget(
      text: "Jessica Wassiak",
      secondaryText: "Whens the party again?",
      image: 'assets/images/userImage8.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WORK IN PROGRESS',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.pink[50],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.pink,
                          ),
                          Text(
                            'New',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
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
            ListView.builder(
              itemCount: chatTest.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ChatWidget(
                  text: chatTest[index].text,
                  secondaryText: chatTest[index].secondaryText,
                  image: chatTest[index].image,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
