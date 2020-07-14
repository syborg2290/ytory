import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytory/main/pages/chat_page.dart';
import 'package:ytory/main/pages/main_page.dart';
import 'package:ytory/main/pages/notifivation_page.dart';
import 'package:ytory/main/pages/profile_page.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  AuthServcies _authSerivice = AuthServcies();
  int pageIndex = 0;
  String currentUserId;

  @override
  void initState() {
    super.initState();
    _authSerivice.getCurrentUser().then((user) {
      setState(() {
        currentUserId = user.uid;
      });
    });
    pageController = PageController();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return WillPopScope(
      onWillPop: () async {
        AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: Center(
            child: Text(
              'Are you sure to continue?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          btnOkColor: Palette.mainAppColor,
          btnCancelColor: Palette.mainAppColor,
          btnOkText: 'Yes',
          btnCancelText: 'No',
          btnOkOnPress: () {
            exit(0);
          },
          btnCancelOnPress: () {},
        )..show();
        return false;
      },
      child: Scaffold(
        backgroundColor: Palette.lightBackground,
        body: Container(
          color: Palette.lightBackground,
          width: width,
          height: height,
          child: PageView(
            allowImplicitScrolling: true,
            children: <Widget>[
              MainPage(),
              NotificationPage(),
              ChatPage(),
              ProfilePage(
                profileId: currentUserId,
              ),
            ],
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Palette.lightBackground,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10)),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 0),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
            child: BottomAppBar(
              shape: CircularNotchedRectangle(),
              notchMargin: 6.0,
              elevation: 9.0,
              clipBehavior: Clip.antiAlias,
              color: Palette.lightBackground,
              child: Container(
                height: 55,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      iconSize: pageIndex == 0 ? 35.0 : 30.0,
                      padding: EdgeInsets.only(left: 28.0),
                      icon: Image(
                        image: AssetImage("assets/icons/diary.png"),
                        color: pageIndex == 0
                            ? Palette.mainAppColor
                            : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(0);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 1 ? 35.0 : 30.0,
                      padding: EdgeInsets.only(right: 28.0),
                      icon: Image(
                        image: AssetImage("assets/icons/bell.png"),
                        color: pageIndex == 1
                            ? Palette.mainAppColor
                            : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(1);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 2 ? 35.0 : 30.0,
                      padding: EdgeInsets.only(right: 28.0),
                      icon: Image(
                        image: AssetImage("assets/icons/chat.png"),
                        color: pageIndex == 2
                            ? Palette.mainAppColor
                            : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(2);
                      },
                    ),
                    IconButton(
                      iconSize: pageIndex == 3 ? 35.0 : 30.0,
                      padding: EdgeInsets.only(right: 28.0),
                      icon: Image(
                        image: AssetImage("assets/icons/user.png"),
                        color: pageIndex == 3
                            ? Palette.mainAppColor
                            : Colors.black54,
                      ),
                      onPressed: () {
                        onTap(3);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
