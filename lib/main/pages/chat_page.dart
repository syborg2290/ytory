import 'package:flutter/material.dart';
import 'package:ytory/utils/pallete.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Palette.lightBackground,
    );
  }
}
