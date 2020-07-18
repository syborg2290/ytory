import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:ytory/utils/progress_bars.dart';

class ChatAudio extends StatefulWidget {
  final String audio;
  final String image;
  final String songName;
  ChatAudio({this.audio, this.image, this.songName, Key key}) : super(key: key);

  @override
  _ChatAudioState createState() => _ChatAudioState();
}

class _ChatAudioState extends State<ChatAudio> {
  VideoPlayerController _controller;
  int position = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.audio)
      ..addListener(() {
        setState(() {
          position = _controller.value.position.inSeconds;
        });
      })
      ..initialize().then((_) {
        setState(() {});
      });
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
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return GestureDetector(
      onTap: () {
        if (_controller.value.isPlaying) {
          setState(() {
            _controller.pause();
          });
        }
      },
      child: _controller.value.initialized
          ? Stack(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(height * 0.03),
                    child: VideoPlayer(_controller)),
                widget.image == null
                    ? Image.asset(
                        'assets/icons/audio_empty.png',
                        height: height * 0.33,
                        width: width * 0.5,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        widget.image,
                        height: height * 0.33,
                        width: width * 0.5,
                        fit: BoxFit.cover,
                      ),
                _controller.value.isBuffering
                    ? Center(child: circularProgress())
                    : SizedBox.shrink(),
                _controller.value.isPlaying
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.pause();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: width * 0.16,
                              height: height * 0.08,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(height * 0.09))),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/sound.gif',
                                  width: width * 0.25,
                                  height: height * 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.play();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(height * 0.05)),
                        color: Colors.black.withOpacity(0.6)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.songName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: height * 0.5,
                    left: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
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
            )
          : Container(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
