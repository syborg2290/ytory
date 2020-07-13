import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytory/main/login_screen.dart';
import 'package:ytory/model/story.dart';
import 'package:ytory/model/user.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/services/story_service.dart';
import 'package:ytory/utils/gallery_pick_stories/media_picker.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/utils/shimmers/story_viewShimmer.dart';
import 'package:ytory/widgets/story_view.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  AuthServcies _authSerivice = AuthServcies();
  List<double> distance = [];

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
        elevation: 0.0,
        leading: IconButton(
          iconSize: 30.0,
          padding: EdgeInsets.only(left: 28.0),
          icon: Image(
            image: AssetImage("assets/icons/more.png"),
            color: Colors.black54,
          ),
          onPressed: () async {
            await _authSerivice.signout();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 15,
            ),
            child: IconButton(
              iconSize: 40.0,
              padding: EdgeInsets.only(left: 28.0),
              icon: Image(
                image: AssetImage("assets/icons/export.png"),
                color: Colors.black,
              ),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MediaPicker(
                            fromStory: false,
                          )),
                );
              },
            ),
          )
        ],
      ),
      backgroundColor: Palette.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: streamingStories(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return shimmerEffectLoadingStory(context);
                } else {
                  if (snapshot.data.documents.length == 0) {
                    return Center(
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'assets/empty_story.png',
                            width: width * 0.8,
                            height: height * 0.5,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Today stories",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 36.0,
                                  fontFamily: "Calibre-Semibold",
                                  letterSpacing: 1.0,
                                )),
                          ),
                        ],
                      ),
                    );
                  } else {
                    List<Story> stories = [];

                    snapshot.data.documents.forEach((storyDoc) async {
                      Story story = Story.fromDocument(storyDoc);
                      stories.add(story);
                      if (story.latitude == null) {
                        distance.add(0.0);
                      } else {
                        if (await Permission
                            .locationWhenInUse.serviceStatus.isEnabled) {
                          Position currentLocation = await Geolocator()
                              .getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high);
                          double dist = await Geolocator().distanceBetween(
                            story.latitude,
                            story.longitude,
                            currentLocation.latitude,
                            currentLocation.longitude,
                          );
                          distance.add(dist);
                        } else {
                          PermissionStatus permissionStatus =
                              await Permission.location.request();
                          if (permissionStatus.isGranted) {
                            Position currentLocation = await Geolocator()
                                .getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high);
                            double dist = await Geolocator().distanceBetween(
                              story.latitude,
                              story.longitude,
                              currentLocation.latitude,
                              currentLocation.longitude,
                            );

                            distance.add(dist);
                          } else {
                            distance.add(0.0);
                          }
                        }
                      }
                    });

                    return Container(
                      margin: EdgeInsets.all(12),
                      child: StaggeredGridView.countBuilder(
                          physics: ScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          itemCount: stories.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StoryView(
                                            story: stories[index],
                                          )),
                                );
                              },
                              child: Container(
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          child: FancyShimmerImage(
                                            imageUrl:
                                                stories[index].thumbnailUrl[0],
                                            boxFit: BoxFit.cover,
                                            shimmerBackColor: Color(0xffe0e0e0),
                                            shimmerBaseColor: Color(0xffe0e0e0),
                                            shimmerHighlightColor:
                                                Colors.grey[200],
                                          )),
                                    ),
                                    UserInfo(
                                      userId: stories[index].userId,
                                      userImage: stories[index].thumbnailUser,
                                    ),
                                    distance.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                              left: 10,
                                              top: height * 0.29,
                                              bottom: 10,
                                              right: width * 0.18,
                                            ),
                                            child: Container(
                                              alignment: Alignment.bottomLeft,
                                              decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              height * 0.02))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(7.0),
                                                child: ((distance[index] / 1000)
                                                            .round()) <
                                                        1
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Image.asset(
                                                            'assets/icons/from.png',
                                                            width: 30,
                                                            height: 30,
                                                            color: Colors.white,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 3),
                                                            child: Text(
                                                              '${(distance[index]).round()}' +
                                                                  " m",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Image.asset(
                                                            'assets/icons/from.png',
                                                            width: 30,
                                                            height: 30,
                                                            color: Colors.white,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 3,
                                                            ),
                                                            child: Text(
                                                              '${(distance[index] / 1000).round()}' +
                                                                  " km",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink()
                                  ],
                                ),
                              ),
                            );
                          },
                          staggeredTileBuilder: (index) {
                            return new StaggeredTile.count(
                                1, index.isEven ? 1.5 : 1.5);
                          }),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final String userId;
  final String userImage;

  const UserInfo({this.userId, this.userImage, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: width * 0.15,
          height: height * 0.075,
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.all(Radius.circular(height * 0.04))),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Palette.mainAppColor,
                    width: 3,
                  ),
                  borderRadius:
                      BorderRadius.all(Radius.circular(height * 0.04))),
              child: CircleAvatar(
                radius: height * 0.04,
                backgroundImage: userImage == null
                    ? AssetImage('assets/profilePhoto.png')
                    : NetworkImage(userImage),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
