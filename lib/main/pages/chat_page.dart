import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytory/model/user.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/services/message_service.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/utils/shimmers/chat_list.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  AuthServcies _authSerivice = AuthServcies();
  User currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _authSerivice.getCurrentUser().then((fuser) {
      _authSerivice.getUserObj(fuser.uid).then((user) {
        setState(() {
          currentUser = User.fromDocument(user);
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      backgroundColor: Palette.lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        title: Text(
          "Chats",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, right: 0, top: 5, bottom: 5),
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
      ),
      body: isLoading
          ? shimmerEffectLoadingChatList(context)
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    child: Center(
                      child: Container(
                        width: width * 0.85,
                        height: 55,
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
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              cursorColor: Colors.black,
                              textAlign: TextAlign.justify,
                              decoration: InputDecoration(
                                hintText: "Search",
                                hintStyle: TextStyle(
                                  fontSize: 18,
                                ),
                                filled: true,
                                fillColor: Color(0xffe0e0e0),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 12.0),
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
                                        'assets/icons/chat_user.png',
                                        width: 10,
                                        height: 10,
                                        color: Colors.black.withOpacity(0.5),
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
                  ),
                  StreamBuilder(
                      stream: streamingMessages(currentUser.id),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return shimmerEffectLoadingChatList(context);
                        } else {
                          if (snapshot.data.documents.length == 0) {
                            return Center(
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/empty_chat.jpg',
                                    width: width * 0.85,
                                    height: height * 0.7,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("",
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
                            return Container();
                          }
                        }
                      }),
                ],
              ),
            ),
    );
  }
}
