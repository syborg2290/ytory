import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullScreenStoryFile extends StatefulWidget {
  final String type;
  final File media;
  FullScreenStoryFile({this.type, this.media, Key key}) : super(key: key);

  @override
  _FullScreenStoryFileState createState() => _FullScreenStoryFileState();
}

class _FullScreenStoryFileState extends State<FullScreenStoryFile> {
  VideoPlayerController _controller;
  int position = 0;

  @override
  void initState() {
    super.initState();
    if (widget.type == "video") {
      _controller = VideoPlayerController.file(widget.media)
        ..addListener(() {
          setState(() {
            position = _controller.value.position.inSeconds;
          });
        })
        ..initialize().then((_) {
          _controller.play();
          setState(() {
            _controller.setLooping(true);
          });
        });
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    if (widget.type == "video") {
      _controller.dispose();
    }
    super.dispose();
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
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.all(Radius.circular(height * 0.09))),
            child: IconButton(
                icon: Image.asset(
                  'assets/icons/left-arrow.png',
                  width: width * 0.07,
                  height: height * 0.07,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: AspectRatio(
        aspectRatio: 8.0 / 16,
        child: widget.type == "image"
            ? Image.file(
                widget.media,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              )
            : GestureDetector(
                onTap: () {
                  if (_controller.value.isPlaying) {
                    setState(() {
                      _controller.pause();
                    });
                  } else {
                    setState(() {
                      _controller.play();
                    });
                  }
                },
                child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Stack(
                      children: <Widget>[
                        VideoPlayer(_controller),
                        _controller.value.isPlaying
                            ? SizedBox.shrink()
                            : Center(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _controller.play();
                                    });
                                  },
                                  child: Container(
                                    width: width * 0.16,
                                    height: height * 0.08,
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(height * 0.09))),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/icons/play.png',
                                        width: width * 0.12,
                                        height: height * 0.1,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: height * 0.9,
                            left: 10,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.black,
                              border: Border.all(
                                width: 3,
                                color: Colors.black,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _printDuration(Duration(
                                  seconds: position,
                                )),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
      ),
    );
  }
}
