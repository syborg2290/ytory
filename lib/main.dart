import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytory/main/home_screen.dart';
import 'package:ytory/main/login_screen.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/utils/pallete.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthServcies _authServcies = AuthServcies();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'yTory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Palette.mainAppColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnimatedSplashScreen(
          duration: 3000,
          splash: Image.asset(
            'assets/splash_icon.png',
            width: 100,
            height: 100,
          ),
          nextScreen: FutureBuilder(
            future: _authServcies.getCurrentUser(),
            builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
              if (snapshot.hasData) {
                return HomeScreen();
              } else {
                return LoginScreen();
              }
            },
          ),
          splashTransition: SplashTransition.rotationTransition,
          backgroundColor: Palette.lightBackground),
    );
  }
}
