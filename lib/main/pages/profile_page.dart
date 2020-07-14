import 'package:flutter/material.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  final String profileId;
  ProfilePage({this.profileId, Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
          onPressed: () async {},
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
              onPressed: () async {},
            ),
          )
        ],
      ),
      backgroundColor: Palette.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 110,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      image: DecorationImage(
                          image: AssetImage('assets/profilePhoto.png'),
                          fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "profile.title",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    child: Text(
                      "profile.subtitle",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              "0",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text('Post')
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '0',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text('Followers')
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '0',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text('Following')
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
