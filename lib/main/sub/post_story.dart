import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:ytory/main/home_screen.dart';
import 'package:ytory/model/user.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/services/story_service.dart';
import 'package:ytory/utils/compressMedia.dart';
import 'package:ytory/utils/gallery_pick_stories/media_picker.dart';
import 'package:ytory/utils/image_cropper.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/utils/progress_bars.dart';
import 'package:ytory/utils/video_players/storyfile_videoplayer.dart';
import 'package:ytory/widgets/fullScreenStoryFile.dart';
import 'package:ytory/utils/video_trimmer.dart';

class PostStory extends StatefulWidget {
  final List<AssetEntity> media;
  final List<File> allPreviousFile;
  final List<String> allType;
  final File cameraVideoOrImage;
  final String cameraType;
  PostStory(
      {this.media,
      this.allPreviousFile,
      this.allType,
      this.cameraVideoOrImage,
      this.cameraType,
      Key key})
      : super(key: key);

  @override
  _PostStoryState createState() => _PostStoryState();
}

double cardAspectRatio = 8.0 / 16.0;
double widgetAspectRatio = cardAspectRatio * 1.2;

class _PostStoryState extends State<PostStory> {
  int current = 0;
  List<File> mediaEn = [];
  List<String> type = [];
  PageController pageController;
  double pageOffset = 0.0;
  int position = 0;
  bool isLoading = true;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();

    pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.8,
    )..addListener(() {
        setState(() {
          pageOffset = pageController.page;
          current = pageController.page.toInt();
        });
      });

    if (widget.cameraVideoOrImage == null) {
      if (widget.media != null) {
        widget.media.forEach((assetenti) {
          if (assetenti.type.toString() == "AssetType.image") {
            assetenti.file.then((value) {
              setState(() {
                type.add("image");
                mediaEn.add(value);
              });
            });
          } else {
            assetenti.file.then((value) {
              setState(() {
                type.add("video");
                mediaEn.add(value);
              });
            });
          }
        });
      } else {
        setState(() {
          mediaEn = widget.allPreviousFile;
          type = widget.allType;
        });
      }
    } else {
      setState(() {
        type.add(widget.cameraType);
        mediaEn.add(widget.cameraVideoOrImage);
      });
    }
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      textDirection: TextDirection.ltr,
      isDismissible: false,
      customBody: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        width: 100,
        height: 100,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 10,
            ),
            child: Column(
              children: <Widget>[
                flashProgress(),
                Text("posting your story...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(129, 165, 168, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
      ),
      showLogs: false,
    );
    isLoading = false;
  }

  post() async {
    pr.show();
    Position currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<String> mediaUrl = [];
    List<String> thubnailUrl = [];

    for (var i = 0; i < mediaEn.length; i++) {
      if (type[i] == "image") {
        String medImageUrl =
            await uploadImageToStory(await compressImageFile(mediaEn[i], 90));
        mediaUrl.add(medImageUrl);
        String medImageThumbUrl = await uploadImageToStoryThumb(
            await getThumbnailForImage(mediaEn[i], 45));
        thubnailUrl.add(medImageThumbUrl);
      } else {
        String medVideoUrl =
            await uploadVideoToStory(await compressVideoFile(mediaEn[i]));
        mediaUrl.add(medVideoUrl);
        String medVideoThumbUrl = await uploadVideoToStoryThumb(
            await getThumbnailForVideo(mediaEn[i]));
        thubnailUrl.add(medVideoThumbUrl);
      }
    }
    AuthServcies authServcies = AuthServcies();
    FirebaseUser currentUser = await authServcies.getCurrentUser();
    User user =
        User.fromDocument(await authServcies.getUserObj(currentUser.uid));

    await addStory(
      currentUser.uid,
      user.username,
      user.thumbnailUserPhotoUrl,
      mediaUrl,
      thubnailUrl,
      type,
      currentLocation.latitude == null ? null : currentLocation.latitude,
      currentLocation.longitude == null ? null : currentLocation.longitude,
    );
    pr.hide().whenComplete(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return isLoading
        ? Container(
            color: Palette.lightBackground,
            child: Center(child: circularProgress()))
        : Container(
            decoration: BoxDecoration(color: Palette.lightBackground),
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                brightness: Brightness.light,
                backgroundColor: Colors.transparent,
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
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      onPressed: () async {
                        await post();
                      },
                      child: Center(
                          child: Text("Post",
                              style: TextStyle(
                                fontSize: 19,
                                color: Colors.white,
                              ))),
                      color: Palette.mainAppColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                          side: BorderSide(
                            color: Palette.mainAppColor,
                          )),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Today story",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 40.0,
                                fontFamily: "Calibre-Semibold",
                                letterSpacing: 1.0,
                              )),
                          IconButton(
                            icon: Image.asset(
                              'assets/icons/plus.png',
                              width: width * 0.09,
                              height: height * 0.09,
                            ),
                            onPressed: () async {
                              List<AssetEntity> remedia = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MediaPicker(
                                          fromStory: true,
                                        )),
                              );
                              if (remedia != null) {
                                if (remedia.isNotEmpty) {
                                  remedia.forEach((assetenti) {
                                    if (assetenti.type.toString() ==
                                        "AssetType.image") {
                                      assetenti.file.then((value) {
                                        setState(() {
                                          type.add("image");
                                          mediaEn.add(value);
                                        });
                                      });
                                    } else {
                                      assetenti.file.then((value) {
                                        setState(() {
                                          type.add("video");
                                          mediaEn.add(value);
                                        });
                                      });
                                    }
                                  });
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(height * 0.09))),
                          child: IconButton(
                              icon: Image.asset(
                                'assets/icons/close.png',
                                width: width * 0.09,
                                height: height * 0.09,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  type.removeAt(current);
                                  mediaEn.removeAt(current);
                                });
                                if (mediaEn.isEmpty) {
                                  Navigator.pop(context);
                                }
                              }),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(height * 0.09))),
                          child: IconButton(
                              icon: Image.asset(
                                'assets/icons/cropcut.png',
                                width: width * 0.08,
                                height: height * 0.08,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                if (type[current] == "image") {
                                  File cropImage = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ImageCropper(
                                              image: mediaEn[current],
                                            )),
                                  );
                                  if (cropImage != null) {
                                    setState(() {
                                      mediaEn[current] = cropImage;
                                    });
                                  }
                                } else {
                                  final Trimmer _trimmer = Trimmer();
                                  await _trimmer.loadVideo(
                                      videoFile: mediaEn[current]);
                                  File trimmedVideo =
                                      await Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                    return VideoTrimmer(
                                      trimmer: _trimmer,
                                      allFile: mediaEn,
                                      allType: type,
                                      currentIndex: current,
                                    );
                                  }));

                                  if (trimmedVideo != null) {
                                    setState(() {
                                      mediaEn[current] = trimmedVideo;
                                    });
                                  }
                                }
                              }),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.65,
                      child: PageView.builder(
                          controller: pageController,
                          itemCount: mediaEn.length,
                          itemBuilder: (context, index) {
                            double scale = 0.0;
                            double angle = 0.0;
                            if (pageOffset != null) {
                              if (!pageOffset.isNegative) {
                                scale = max(
                                        0.8,
                                        (1 - (pageOffset.abs() - index)).abs() +
                                            0.8)
                                    .abs();
                                angle = (pageOffset.abs() - index).abs();
                                if (angle.abs() > 0.5) {
                                  angle = (1 - angle).abs();
                                }
                              }
                            }

                            return Padding(
                              padding: EdgeInsets.only(
                                right: 10,
                                left: 10,
                                top: (40 - scale.abs() * 30).abs(),
                                bottom: 10,
                              ),
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle.abs()),
                                alignment: Alignment.center,
                                child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(height * 0.03),
                                    child: Material(
                                      elevation: 2,
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: AspectRatio(
                                          aspectRatio: cardAspectRatio,
                                          child: mediaEn[index] == null
                                              ? Container(
                                                  color: Colors.white,
                                                  child: Center(
                                                      child:
                                                          circularProgress()),
                                                )
                                              : type[index] == "image"
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  FullScreenStoryFile(
                                                                    media: mediaEn[
                                                                        index],
                                                                    type: type[
                                                                        index],
                                                                  )),
                                                        );
                                                      },
                                                      child: Image.file(
                                                        mediaEn[index],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {},
                                                      child:
                                                          StoryFileVideoPlayer(
                                                        aspectRatio:
                                                            cardAspectRatio,
                                                        video: mediaEn[index],
                                                      ),
                                                    ),
                                        ),
                                      ),
                                    )),
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: 50,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: width * 0.1,
                          right: width * 0.1,
                        ),
                        child: ListView.builder(
                            itemCount: mediaEn.length,
                            reverse: false,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Palette.mainAppColor,
                                ),
                                width: current == index ? 40.0 : 10.0,
                                height: current == index ? 40.0 : 10.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
