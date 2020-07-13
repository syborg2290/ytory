import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:ytory/main/create_account.dart';
import 'package:ytory/main/home_screen.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/utils/flush_bars.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/utils/progress_bars.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final AuthServcies _authServcies = AuthServcies();
  bool secureText = true;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
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
                Text("checking provided credintials...",
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
  }

  done() async {
    if (email.text.trim() != "") {
      if (password.text.trim() != "") {
        if (RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email.text.trim())) {
          pr.show();
          try {
            AuthResult _authenticatedUser =
                await _authServcies.signInWithEmailAndPasswordSe(
                    email.text.trim(), password.text.trim());
            if (_authenticatedUser.user.uid != null) {
              pr.hide().whenComplete(() {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              });
            } else {
              pr.hide();
              GradientSnackBar.showMessage(context, "Sorry! no account found!");
            }
          } catch (e) {
            switch (e.code) {
              case "ERROR_INVALID_EMAIL":
                pr.hide();
                GradientSnackBar.showMessage(context,
                    "Sorry! Your email address appears to be malformed!");
                break;
              case "ERROR_WRONG_PASSWORD":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! Your password is wrong!");
                break;
              case "ERROR_USER_NOT_FOUND":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! User with this email doesn't exist!");
                break;
              case "ERROR_USER_DISABLED":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! User with this email has been disabled!");
                break;
              case "ERROR_TOO_MANY_REQUESTS":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! no account found!");
                break;
              case "ERROR_OPERATION_NOT_ALLOWED":
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! no account found!");
                break;
              default:
                pr.hide();
                GradientSnackBar.showMessage(
                    context, "Sorry! no account found!");
            }
          }
        } else {
          GradientSnackBar.showMessage(context, "Please provide valid email!");
        }
      } else {
        GradientSnackBar.showMessage(context, "Password is required!");
      }
    } else {
      GradientSnackBar.showMessage(context, "Email is required!");
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return WillPopScope(
      onWillPop: () async {
        exit(0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        backgroundColor: Palette.lightBackground,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Welcome,",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Sign in to continue!",
                        style: TextStyle(
                            fontSize: 20, color: Colors.grey.shade400),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Image.asset(
                          'assets/splash_icon.png',
                          width: width * 0.3,
                          height: height * 0.15,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: <Widget>[
                      TextField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          labelStyle: TextStyle(
                              fontSize: 15, color: Colors.grey.shade400),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Palette.mainAppColor,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextField(
                        obscureText: secureText,
                        controller: password,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                              fontSize: 15, color: Colors.grey.shade400),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                if (secureText) {
                                  setState(() {
                                    secureText = false;
                                  });
                                } else {
                                  setState(() {
                                    secureText = true;
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  secureText
                                      ? 'assets/icons/eye_open.png'
                                      : 'assets/icons/eye_close.png',
                                  width: 30,
                                  height: 30,
                                ),
                              )),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Palette.mainAppColor,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          "Forgot Password ?",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 50,
                        width: double.infinity,
                        child: FlatButton(
                          onPressed: () async {
                            await done();
                          },
                          padding: EdgeInsets.all(0),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Palette.mainAppColor,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              constraints: BoxConstraints(
                                  maxWidth: double.infinity, minHeight: 50),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "I'm a new user.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CreateAccount();
                            }));
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Palette.mainAppColor,
                              fontSize: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
