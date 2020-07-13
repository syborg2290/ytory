import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ytory/main/sub/post_story.dart';
import 'package:ytory/utils/gallery_pick_stories/gallery_view.dart';
import 'package:ytory/utils/pallete.dart';

class MediaPicker extends StatefulWidget {
  final bool fromStory;
  MediaPicker({this.fromStory, Key key}) : super(key: key);

  @override
  _MediaPickerState createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
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
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: IconButton(
                icon: Image.asset(
                  'assets/icons/camera.png',
                  width: width * 0.08,
                  height: height * 0.08,
                ),
                onPressed: () async {
                  final pickedFile = await ImagePicker().getImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PostStory(
                                cameraVideoOrImage: File(pickedFile.path),
                                cameraType: "image",
                              )),
                    );
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: IconButton(
                icon: Image.asset(
                  'assets/icons/video-camera.png',
                  width: width * 0.08,
                  height: height * 0.08,
                ),
                onPressed: () async {
                  final pickedFile = await ImagePicker().getVideo(
                      source: ImageSource.camera,
                      maxDuration: Duration(
                        minutes: 5,
                      ));
                  if (pickedFile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PostStory(
                                cameraVideoOrImage: File(pickedFile.path),
                                cameraType: "video",
                              )),
                    );
                  }
                }),
          )
        ],
      ),
      backgroundColor: Palette.lightBackground,
      body: GalleryView(
        fromStory: widget.fromStory,
      ),
    );
  }
}
