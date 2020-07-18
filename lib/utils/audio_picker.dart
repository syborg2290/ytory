import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/utils/progress_bars.dart';
import 'package:ytory/utils/shimmers/gallery_shimmer.dart';

class AudioPicker extends StatefulWidget {
  AudioPicker({Key key}) : super(key: key);

  @override
  _AudioPickerState createState() => _AudioPickerState();
}

class _AudioPickerState extends State<AudioPicker> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> audios = [];
  List<int> selectedIndex = [];
  List<SongInfo> selectedMedia = [];
  bool isLoading = true;

  @override
  void initState() {
    getPermission();
    isLoading = false;
    super.initState();
  }

  getAllAudios() async {
    audioQuery.getSongs().then((value) {
      setState(() {
        audios = value;
      });
    });
  }

  getPermission() async {
    PermissionStatus result = await Permission.storage.request();
    if (result.isGranted) {
      await getAllAudios();
    } else {
      AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.NO_HEADER,
        body: Center(
          child: Text(
            'Problem with your permissions!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        btnOkText: 'Goto app settings',
        btnCancelText: 'Cancel',
        btnOkColor: Palette.mainAppColor,
        btnCancelColor: Palette.mainAppColor,
        btnOkOnPress: () {
          openAppSettings();
          if (!mounted) {
            return;
          }
          setState(() {
            isLoading = false;
          });
        },
        btnCancelOnPress: () {
          Navigator.pop(context);
        },
      )..show();
    }
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
        title: Text("Device audio",
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
      ),
      body: isLoading
          ? shimmerEffectLoadingGallery(context)
          : Column(children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                ),
                child: GridView.builder(
                    itemCount: audios.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (BuildContext context, int index2) {
                      return GestureDetector(
                          onTap: () {
                            if (selectedIndex.contains(index2)) {
                              setState(() {
                                selectedIndex.remove(index2);
                                selectedMedia.remove(audios[index2]);
                              });
                            } else {
                              setState(() {
                                selectedIndex.add(index2);
                                selectedMedia.add(audios[index2]);
                              });
                            }
                          },
                          child: Stack(
                            children: <Widget>[
                              audios[index2] == null
                                  ? circularProgress()
                                  : Stack(
                                      children: <Widget>[
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.black38,
                                                width: 0,
                                              ),
                                              image: DecorationImage(
                                                image: audios[index2]
                                                            .albumArtwork ==
                                                        null
                                                    ? AssetImage(
                                                        'assets/icons/audio_empty.png',
                                                      )
                                                    : AssetImage(audios[index2]
                                                        .albumArtwork),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    audios[index2].displayName,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              selectedIndex.contains(index2)
                                  ? Container(
                                      child: Center(
                                          child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 2,
                                              color: Colors.white,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      )),
                                      decoration: BoxDecoration(
                                          color: Palette.mainAppColor
                                              .withOpacity(0.6),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))))
                                  : SizedBox.shrink(),
                            ],
                          ));
                    }),
              )),
            ]),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: height * 0.35),
        child: Column(
          children: <Widget>[
            FloatingActionButton(
              onPressed: () {},
              heroTag: "selectedCountTag",
              backgroundColor: Palette.mainAppColor,
              elevation: 10.0,
              child: Text(
                selectedIndex.length.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            FloatingActionButton(
              onPressed: () {
                if (selectedMedia.isNotEmpty) {
                  Navigator.pop(context, selectedMedia);
                }
              },
              heroTag: "continueTag",
              backgroundColor: Palette.mainAppColor,
              elevation: 10.0,
              child: Image.asset(
                'assets/icons/forward.png',
                color: Colors.white,
                width: width * 0.07,
                height: height * 0.07,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
