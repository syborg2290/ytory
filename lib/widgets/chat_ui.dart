import 'package:cached_network_image/cached_network_image.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytory/model/message.dart';
import 'package:ytory/model/user.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/services/message_service.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/utils/shimmers/chat_list.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final User reciever;
  ChatScreen({this.reciever, Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AuthServcies _authSerivice = AuthServcies();
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController =
      ScrollController(initialScrollOffset: 50.0);
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

  send() async {
    if (messageController.text != "") {
      await addMessageToDb(currentUser.id, currentUser, widget.reciever,
          widget.reciever.id, "text", messageController.text.trim());
      messageController.clear();
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
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.reciever.thumbnailUserPhotoUrl == null
                  ? AssetImage('assets/profilePhoto.png')
                  : NetworkImage(widget.reciever.thumbnailUserPhotoUrl),
              backgroundColor: Colors.grey,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.reciever.username,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
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
          IconButton(
              icon: Image.asset(
                'assets/icons/more.png',
                width: width * 0.07,
                height: height * 0.07,
              ),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
      body: isLoading
          ? shimmerEffectLoadingChatList(context)
          : Column(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder(
                    stream: streamingMessagesSpecificUser(
                        currentUser.id, widget.reciever.id),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return shimmerEffectLoadingChatList(context);
                      } else {
                        if (snapshot.data.documents.length == 0) {
                          return Center(
                              child: Image.asset(
                            'assets/empty.jpg',
                            width: width * 0.85,
                            height: height * 0.7,
                          ));
                        } else {
                          List<Message> chat = [];
                          snapshot.data.documents.forEach((doc) {
                            Message ga = Message.fromDocument(doc);
                            chat.add(ga);
                          });

                          if (chat.isEmpty) {
                            return Center(
                                child: Image.asset(
                              'assets/empty.jpg',
                              width: width * 0.85,
                              height: height * 0.7,
                            ));
                          } else {
                            return ListView.builder(
                                controller: _scrollController,
                                itemCount: chat.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment:
                                        chat[index].senderId == currentUser.id
                                            ? Alignment.bottomLeft
                                            : Alignment.bottomRight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        ListTile(
                                          title: Padding(
                                            padding: EdgeInsets.only(
                                              left: width * 0.01,
                                              top: 20,
                                            ),
                                            child: Container(
                                              decoration: new BoxDecoration(
                                                  color: Color(0xffe0e0e0)
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      new BorderRadius.only(
                                                    topLeft:
                                                        const Radius.circular(
                                                            20.0),
                                                    topRight:
                                                        const Radius.circular(
                                                            20.0),
                                                    bottomLeft:
                                                        const Radius.circular(
                                                            20.0),
                                                    bottomRight:
                                                        const Radius.circular(
                                                            20.0),
                                                  )),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(0.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: ExpandText(
                                                      chat[index].message,
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 18,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ),
                                          leading: GestureDetector(
                                            child: Container(
                                              width: 50.0,
                                              height: 50.0,
                                              padding: const EdgeInsets.all(
                                                  2.0), // borde width
                                              decoration: new BoxDecoration(
                                                color: Palette
                                                    .mainAppColor, // border color
                                                shape: BoxShape.circle,
                                              ),
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundImage: widget
                                                            .reciever ==
                                                        null
                                                    ? AssetImage(
                                                        'assets/profilePhoto.png')
                                                    : widget.reciever
                                                                .thumbnailUserPhotoUrl ==
                                                            null
                                                        ? AssetImage(
                                                            'assets/profilePhoto.png')
                                                        : CachedNetworkImageProvider(
                                                            widget.reciever
                                                                .thumbnailUserPhotoUrl),
                                                backgroundColor: Colors.grey,
                                                foregroundColor:
                                                    Palette.mainAppColor,
                                              ),
                                            ),
                                          ),
                                          subtitle: Text(timeago.format(
                                              chat[index].timestamp.toDate())),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }
                        }
                      }
                    },
                  ),
                ),
                Divider(),
                Center(
                  child: Container(
                    width: width * 0.96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Color.fromRGBO(129, 165, 168, 1),
                        width: 1,
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 5,
                        bottom: 5,
                        top: 5,
                        right: 5,
                      ),
                      child: TextFormField(
                        textAlign: TextAlign.start,
                        maxLines: null,
                        autofocus: true,
                        controller: messageController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              await send();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: new BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(40.0),
                                    topRight: const Radius.circular(40.0),
                                    bottomLeft: const Radius.circular(40.0),
                                    bottomRight: const Radius.circular(40.0),
                                  )),
                              child: Image(
                                image: AssetImage(
                                  'assets/icons/plane.png',
                                ),
                                color: Palette.mainAppColor,
                                height: 20,
                                width: 20,
                              ),
                            ),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                              top: 4.0,
                              bottom: 4.0,
                              left: 4.0,
                            ),
                            child: GestureDetector(
                              onTap: () async {},
                              child: Container(
                                padding: EdgeInsets.all(
                                  5,
                                ),
                                decoration: new BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(40.0),
                                      topRight: const Radius.circular(40.0),
                                      bottomLeft: const Radius.circular(40.0),
                                      bottomRight: const Radius.circular(40.0),
                                    )),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: Image(
                                    image: AssetImage(
                                      'assets/icons/gif.png',
                                    ),
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          hintText: "Type on your mind",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(129, 165, 168, 1),
                            fontSize: 19,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
    );
  }
}
