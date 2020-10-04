import 'package:flutter/material.dart';

class ChatWidget extends StatefulWidget {
  // Variables
  final String text;
  final String secondaryText;
  final String image;

  // Constructor
  ChatWidget({
    @required this.text,
    @required this.secondaryText,
    @required this.image,
  });
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(widget.image),
                maxRadius: 30,
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.text),
                  SizedBox(height: 6),
                  Text(
                    widget.secondaryText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
