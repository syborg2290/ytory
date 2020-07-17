import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class AudioPicker extends StatefulWidget {
  AudioPicker({Key key}) : super(key: key);

  @override
  _AudioPickerState createState() => _AudioPickerState();
}

class _AudioPickerState extends State<AudioPicker> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];

  @override
  void initState() {
    getAllAudios();
    super.initState();
  }

  getAllAudios() async {
    audioQuery.getSongs().then((value) {
      setState(() {
        songs = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
        appBar: AppBar(
      automaticallyImplyLeading: false,
      brightness: Brightness.light,
      backgroundColor: Colors.transparent,
      title: Text("Device gallery",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          )),
      elevation: 0.0,
      leading: IconButton(
          icon: Image.asset(
            'assets/icons/left-arrow.png',
            width: width * 0.07,
            height: height * 0.07,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
    ));
  }
}
