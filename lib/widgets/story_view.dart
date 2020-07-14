import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:ytory/model/story.dart';
import 'package:ytory/model/user.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/utils/progress_bars.dart';

class StoryView extends StatefulWidget {
  final Story story;
  StoryView({this.story, Key key}) : super(key: key);

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  AnimationController _animattionController;
  VideoPlayerController _videoPlayerController;
  int _currentIndex = 0;
  AuthServcies authServcies = AuthServcies();
  bool videoPlayerIsInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animattionController = AnimationController(vsync: this);

    _loadStory(
        mediaUrl: widget.story.mediaUrl[0],
        type: widget.story.types[0],
        animateToPage: true);

    _animattionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animattionController.stop();
        _animattionController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.story.mediaUrl.length) {
            _currentIndex += 1;
            _loadStory(
                mediaUrl: widget.story.mediaUrl[_currentIndex],
                type: widget.story.types[_currentIndex],
                animateToPage: true);
          } else {
            // Out of bounds - loop story
            // You can also Navigator.of(context).pop() here
            _currentIndex = 0;
            _loadStory(
                mediaUrl: widget.story.mediaUrl[_currentIndex],
                type: widget.story.types[_currentIndex],
                animateToPage: true);
          }
        });
      }
    });
  }

  void _loadStory({String mediaUrl, String type, bool animateToPage = true}) {
    _animattionController.stop();
    _animattionController.reset();
    if (type == "image") {
      _animattionController.duration = Duration(seconds: 3);
      _animattionController.forward();
    } else {
      _videoPlayerController = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = VideoPlayerController.network(mediaUrl)
        ..initialize().then((_) {
          setState(() {
            videoPlayerIsInitialized = true;
          });
          if (_videoPlayerController.value.initialized) {
            _animattionController.duration =
                _videoPlayerController.value.duration;
            _videoPlayerController.play();
            _animattionController.forward();
          }
        });
    }

    if (animateToPage) {
      if (_pageController.hasClients)
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeInOut,
        );
    }
  }

  @override
  void dispose() {
    if (videoPlayerIsInitialized) {
      _videoPlayerController.dispose();
    }

    _animattionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          _onTapDown(details);
        },
        child: Stack(
          children: <Widget>[
            PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.story.mediaUrl.length,
                itemBuilder: (context, index) {
                  if (widget.story.types[index] == "image") {
                    return CachedNetworkImage(
                      imageUrl: widget.story.mediaUrl[index],
                      fit: BoxFit.cover,
                      fadeInCurve: Curves.easeIn,
                      placeholder: (context, url) =>
                          Center(child: Container(child: circularProgress())),
                    );
                  } else {
                    if (_videoPlayerController != null &&
                        _videoPlayerController.value.initialized) {
                      return FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoPlayerController.value.size.width,
                          height: _videoPlayerController.value.size.height,
                          child: VideoPlayer(_videoPlayerController),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                }),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 1.5,
                  vertical: 10.0,
                ),
                child: Container(
                  child: UserInfo(
                    thumbUser: widget.story.thumbnailUser,
                    username: widget.story.username,
                  ),
                ),
              ),
            ),
            Positioned(
              top: height * 0.78,
              left: 20.0,
              right: 20.0,
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1.5,
                    vertical: 10.0,
                  ),
                  child: ReactRow()),
            ),
            Positioned(
              top: height * 0.87,
              left: 10.0,
              right: 10.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 1.5,
                  vertical: 20.0,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: Colors.white,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new TextField(
                      textAlign: TextAlign.center,
                      readOnly: true,
                      decoration: new InputDecoration(
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(
                            right: 1,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: new BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(30.0),
                                  topRight: const Radius.circular(30.0),
                                  bottomLeft: const Radius.circular(30.0),
                                  bottomRight: const Radius.circular(30.0),
                                )),
                            child: Image(
                              image: AssetImage(
                                'assets/icons/plane.png',
                              ),
                              color: Palette.mainAppColor,
                              height: 15,
                              width: 15,
                            ),
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                            right: 1.0,
                            top: 1.0,
                            bottom: 1.0,
                            left: 3.0,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(
                              5,
                            ),
                            decoration: new BoxDecoration(
                                color: Palette.mainAppColor.withOpacity(0.9),
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(30.0),
                                  topRight: const Radius.circular(30.0),
                                  bottomLeft: const Radius.circular(30.0),
                                  bottomRight: const Radius.circular(30.0),
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30.0),
                              child: Image(
                                image: AssetImage(
                                  'assets/icons/gif.png',
                                ),
                                height: 30,
                                width: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        border: new OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 3,
                          ),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(30.0),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.6),
                        hintStyle: new TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                        ),
                        hintText: "Reply to " + widget.story.username,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;

    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(
              mediaUrl: widget.story.mediaUrl[_currentIndex],
              type: widget.story.types[_currentIndex],
              animateToPage: true);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.story.mediaUrl.length) {
          _currentIndex += 1;
          _loadStory(
              mediaUrl: widget.story.mediaUrl[_currentIndex],
              type: widget.story.types[_currentIndex],
              animateToPage: true);
        } else {
          _currentIndex = 0;
          _loadStory(
              mediaUrl: widget.story.mediaUrl[_currentIndex],
              type: widget.story.types[_currentIndex],
              animateToPage: true);
        }
      });
    } else {
      if (widget.story.types[_currentIndex] == "video") {
        if (_videoPlayerController.value.isPlaying) {
          _videoPlayerController.pause();
          _animattionController.stop();
        } else {
          _videoPlayerController.play();
          _animattionController.forward();
        }
      }
    }
  }
}

class UserInfo extends StatelessWidget {
  final String thumbUser;
  final String username;

  const UserInfo({
    Key key,
    @required this.thumbUser,
    @required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              border: Border.all(
                color: Palette.mainAppColor,
                width: 3,
              ),
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.grey[300],
                backgroundImage: thumbUser == null
                    ? AssetImage('assets/profilePhoto.png')
                    : CachedNetworkImageProvider(
                        thumbUser,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: username == null
              ? SizedBox.shrink()
              : Container(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text(
                        "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                size: 30.0,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );
  }
}

class ReactRow extends StatelessWidget {
  const ReactRow({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/like_light.png',
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/heart_light.png',
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/fire_light.png',
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/cheers_color.png',
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/fuck_color.png',
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
