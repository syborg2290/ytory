import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:ytory/main/home_screen.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/utils/flush_bars.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/utils/progress_bars.dart';

class CreateAccount extends StatefulWidget {
  CreateAccount({Key key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController fullname = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final AuthServcies _authServcies = AuthServcies();
  ProgressDialog pr;
  bool isSecureText = true;
  bool status = false;
  bool secureText = true;
  List gender = ["Male"];

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
                Text("making your account...",
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
    if (fullname.text.trim() != "") {
      if (username.text.trim() != "") {
        if (email.text.trim() != "") {
          if (password.text.trim() != "") {
            if (status) {
              if (RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(email.text.trim())) {
                if (password.text.length > 6) {
                  try {
                    pr.show();
                    String usernameS = username.text.trim();

                    QuerySnapshot snapUser =
                        await _authServcies.usernameCheckSe(usernameS);
                    QuerySnapshot snapEmail =
                        await _authServcies.emailCheckSe(email.text.trim());

                    if (snapEmail.documents.isEmpty) {
                      if (snapUser.documents.isEmpty) {
                        AuthResult result = await _authServcies
                            .createUserWithEmailAndPasswordSe(
                                email.text.trim(), password.text.trim());
                        await _authServcies.createUserInDatabaseSe(
                            result.user.uid,
                            fullname.text.trim(),
                            username.text.trim(),
                            email.text.trim());

                        _firebaseMessaging.getToken().then((token) {
                          print("Firebase Messaging Token: $token\n");
                          _authServcies.createMessagingToken(
                              token, result.user.uid);
                        });

                        pr.hide().whenComplete(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                          );
                        });
                      } else {
                        pr.hide();
                        GradientSnackBar.showMessage(
                            context, "Username already used!");
                      }
                    } else {
                      pr.hide();
                      GradientSnackBar.showMessage(
                          context, "Email address already used!");
                    }
                  } catch (e) {
                    if (e.code == "ERROR_WEAK_PASSWORD") {
                      pr.hide();
                      GradientSnackBar.showMessage(context,
                          "Weak password, password should be at least 6 characters!");
                    }
                  }
                } else {
                  GradientSnackBar.showMessage(context,
                      "Weak password, password should be at least 6 characters long!");
                }
              } else {
                GradientSnackBar.showMessage(
                    context, "Please provide valid email!");
              }
            } else {
              GradientSnackBar.showMessage(context, "Your age must be 16+!");
            }
          } else {
            GradientSnackBar.showMessage(context, "Password is required!");
          }
        } else {
          GradientSnackBar.showMessage(context, "Email is required!");
        }
      } else {
        GradientSnackBar.showMessage(context, "Username is required!");
      }
    } else {
      GradientSnackBar.showMessage(context, "Your name is required!");
    }
  }

  Widget genderWidget(String type, String imagePath, bool isContain) {
    return GestureDetector(
      onTap: () {
        gender.clear();
        setState(() {
          gender.add(type);
        });
      },
      child: Container(
        width: 100,
        height: 100,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
            color: isContain ? Palette.mainAppColor : Colors.white,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        imagePath,
                        width: 40,
                        height: 40,
                        color: gender.contains(type)
                            ? Colors.white
                            : Colors.grey.shade400,
                      ),
                      Text(
                        type,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: gender.contains(type)
                              ? Colors.white
                              : Colors.grey.shade400,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
      ),
    );
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
      backgroundColor: Palette.lightBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Create Account,",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "Sign up to get started!",
                      style:
                          TextStyle(fontSize: 20, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Column(
                  children: <Widget>[
                    TextField(
                      controller: fullname,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Palette.mainAppColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: username,
                      decoration: InputDecoration(
                        labelText: "User Name",
                        labelStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Palette.mainAppColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        labelStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Palette.mainAppColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: password,
                      obscureText: secureText,
                      decoration: InputDecoration(
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
                        labelText: "Password",
                        labelStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Palette.mainAppColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Your gender",
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 10,
                      ),
                      child: SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            genderWidget("Male", "assets/icons/male.png",
                                gender.contains("Male")),
                            genderWidget("Female", "assets/icons/female.png",
                                gender.contains("Female")),
                            genderWidget("Other", "assets/icons/any.png",
                                gender.contains("Other")),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "I'm",
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Container(
                            child: FlutterSwitch(
                              activeTextColor: Colors.white,
                              width: 140.0,
                              inactiveTextColor: Colors.white,
                              height: 55.0,
                              valueFontSize: 35.0,
                              toggleSize: 45.0,
                              value: status,
                              borderRadius: 30.0,
                              activeColor: Palette.mainAppColor,
                              inactiveColor: Colors.grey.shade400,
                              padding: 8.0,
                              showOnOff: true,
                              onToggle: (val) {
                                setState(() {
                                  status = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 50,
                      child: FlatButton(
                        onPressed: () async {
                          await done();
                        },
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Palette.mainAppColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(
                                minHeight: 50, maxWidth: double.infinity),
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "I'm already a member.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Sign in.",
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
    );
  }
}
