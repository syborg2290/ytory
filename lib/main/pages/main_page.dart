import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytory/main/login_screen.dart';
import 'package:ytory/model/story.dart';
import 'package:timeago/timeago.dart' as timeago;
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
  User currentUser;
  List<double> distance = [];

  @override
  void initState() {
    super.initState();
    _authSerivice.getCurrentUser().then((fuser) {
      _authSerivice.getUserObj(fuser.uid).then((user) {
        setState(() {
          currentUser = User.fromDocument(user);
        });
      });
    });
  }

  distanceCalculate(Story story) async {
    if (story.latitude == null) {
      distance.add(0.0);
    } else {
      if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
        Position currentLocation = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        double dist = await Geolocator().distanceBetween(
          story.latitude,
          story.longitude,
          currentLocation.latitude,
          currentLocation.longitude,
        );

        distance.add(dist);
      } else {
        PermissionStatus permissionStatus = await Permission.location.request();
        if (permissionStatus.isGranted) {
          Position currentLocation = await Geolocator()
              .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
        title: Text(
          "Travel stories",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 5, top: 5, bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 6,
                        ),
                        borderRadius:
                            BorderRadius.all(Radius.circular(height * 0.035))),
                    child: CircleAvatar(
                      radius: height * 0.029,
                      backgroundImage: currentUser == null
                          ? AssetImage('assets/profilePhoto.png')
                          : currentUser.thumbnailUserPhotoUrl == null
                              ? AssetImage('assets/profilePhoto.png')
                              : NetworkImage(currentUser.thumbnailUserPhotoUrl),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 10,
                  ),
                  child: Container(
                    width: width * 0.75,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Color(0xffe0e0e0).withOpacity(0.4),
                        borderRadius: BorderRadius.all(
                          Radius.circular(65.0),
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        )),
                    child: Material(
                      elevation: 2,
                      color: Color(0xffe0e0e0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(65.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: TextField(
                          onChanged: (text) {},
                          style: TextStyle(color: Colors.black, fontSize: 16.0),
                          cursorColor: Colors.black,
                          readOnly: true,
                          textAlign: TextAlign.justify,
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: TextStyle(
                              fontSize: 18,
                            ),
                            filled: true,
                            fillColor: Color(0xffe0e0e0),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 32.0, vertical: 14.0),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(
                                color: Color(0xffe0e0e0),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                                child: InkWell(
                                  onTap: () {},
                                  child: Image.asset(
                                    'assets/icons/add-user.png',
                                    width: 10,
                                    height: 10,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                            ),
                            prefixIcon: Material(
                              color: Color(0xffe0e0e0),
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              child: InkWell(
                                onTap: () {},
                                child: Icon(
                                  Icons.search,
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

                    snapshot.data.documents.forEach((storyDoc) {
                      Story story = Story.fromDocument(storyDoc);
                      stories.add(story);
                      distanceCalculate(story);
                    });

                    return Container(
                      margin: EdgeInsets.all(25),
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
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3)),
                                        child: FancyShimmerImage(
                                          imageUrl:
                                              stories[index].thumbnailUrl[0],
                                          boxFit: BoxFit.cover,
                                          shimmerBackColor: Color(0xffe0e0e0),
                                          shimmerBaseColor: Color(0xffe0e0e0),
                                          shimmerHighlightColor:
                                              Colors.grey[200],
                                        )),
                                    UserInfo(
                                      userId: stories[index].userId,
                                      userImage: stories[index].thumbnailUser,
                                    ),
                                    distance.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                              left: 0,
                                              top: height * 0.325,
                                              bottom: 0,
                                              right: 0,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(2))),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Container(
                                                    child: ((distance[index] /
                                                                    1000)
                                                                .round()) <
                                                            1
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Image.asset(
                                                                'assets/icons/from.png',
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            3),
                                                                child: Text(
                                                                  '${(distance[index]).round()}' +
                                                                      " m",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
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
                                                                width: 20,
                                                                height: 20,
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
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        'assets/icons/timeago.png',
                                                        width: 15,
                                                        height: 15,
                                                        color: Colors.white,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: 3,
                                                        ),
                                                        child: Text(
                                                          timeago.format(
                                                                  stories[index]
                                                                      .timestamp
                                                                      .toDate(),
                                                                  locale:
                                                                      'en_short') +
                                                              " ago",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
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
          width: width * 0.14,
          height: height * 0.071,
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.all(Radius.circular(height * 0.06))),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Palette.mainAppColor,
                    width: 3,
                  ),
                  borderRadius:
                      BorderRadius.all(Radius.circular(height * 0.06))),
              child: CircleAvatar(
                radius: height * 0.06,
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
