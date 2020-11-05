import 'package:flutter/material.dart';

class ScreenConvo extends StatefulWidget {
  @override
  _ScreenConvoState createState() => _ScreenConvoState();
}

class _ScreenConvoState extends State<ScreenConvo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Messages'),
      ),
    );
  }
}
