import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:ytory/config/collection.dart';
import 'package:ytory/config/settings.dart';
import 'package:ytory/model/message.dart';
import 'package:ytory/model/user.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/services/message_service.dart';
import 'package:ytory/utils/compressMedia.dart';
import 'package:ytory/utils/gallery_pick_chat/media_picker_chat.dart';
import 'package:ytory/utils/pallete.dart';
import 'package:ytory/utils/progress_bars.dart';
import 'package:ytory/utils/shimmers/chat_list.dart';
import 'package:ytory/utils/video_players/chat_videoPlayer.dart';

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
  bool startedUploading = false;
  double totalBytesTransfered = 0.0;

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

  textsend() async {
    if (messageController.text.trim() != "") {
      String message = messageController.text.trim();
      messageController.clear();
      await addMessageToDb(currentUser.id, currentUser, widget.reciever,
          widget.reciever.id, "text", message);
    }
  }

  gifSend(String downUrl) async {
    await addMessageToDb(currentUser.id, currentUser, widget.reciever,
        widget.reciever.id, "gif", downUrl);
  }

  sendMedia(String type, String oriUrl, String thumb) async {
    await addMessageToDbMedia(currentUser.id, currentUser, widget.reciever,
        widget.reciever.id, type, oriUrl, thumb);
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }

    return time;
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
          mainAxisAlignment: MainAxisAlignment.start,
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
                  fontSize: 16,
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
          startedUploading
              ? Row(
                  children: <Widget>[
                    Text(
                      (totalBytesTransfered / 1024.round()).toString() + " Kbs",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                      ),
                      child: Image.asset(
                        'assets/icons/upload-to-cloud.gif',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.black,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          )
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

                          return GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: ListView.builder(
                                // controller: _scrollController,
                                itemCount: chat.length,
                                reverse: true,
                                itemBuilder: (context, index) {
                                  return ChatBubbleUi(
                                    isMe: chat[index].type == "sender"
                                        ? chat[index].receiverId ==
                                            currentUser.id
                                        : chat[index].senderId ==
                                            currentUser.id,
                                    messageType: chat[index].type,
                                    message: chat[index].type == "image"
                                        ? chat[index].thumbnailUrl
                                        : chat[index].type == "video"
                                            ? chat[index].url
                                            : chat[index].message,
                                    profileImg: chat[index].id == currentUser.id
                                        ? currentUser.thumbnailUserPhotoUrl
                                        : widget.reciever.thumbnailUserPhotoUrl,
                                    time: readTimestamp(
                                        chat[index].timestamp.seconds),
                                  );
                                }),
                          );
                        }
                      }
                    },
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: width * 0.81,
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
                          bottom: 2,
                          top: 2,
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
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(
                                right: 4.0,
                                top: 4.0,
                                bottom: 4.0,
                                left: 4.0,
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  var media = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MediaPickerChat()),
                                  );
                                  if (media != null) {
                                    if (media["type"] == "gallery") {
                                      List<AssetEntity> mediaFromGallery =
                                          media["mediaList"];
                                      setState(() {
                                        startedUploading = true;
                                      });
                                      var uuid = Uuid();
                                      String path = uuid.v1().toString() +
                                          new DateTime.now().toString();

                                      mediaFromGallery.forEach((element) async {
                                        if (element.type.toString() ==
                                            "AssetType.image") {
                                          // 80% compressed image
                                          StorageUploadTask
                                              uploadTaskOrigImage = storageRef
                                                  .child(
                                                      "chat/message_image/user_$path.jpg")
                                                  .putFile(
                                                      await compressImageFile(
                                                          await element.file,
                                                          80));

                                          uploadTaskOrigImage.events
                                              .listen((event) {
                                            setState(() {
                                              totalBytesTransfered = event
                                                  .snapshot.bytesTransferred
                                                  .round()
                                                  .toDouble();
                                            });
                                          });

                                          // 40% compressed image

                                          StorageUploadTask
                                              uploadTaskThumbImage = storageRef
                                                  .child(
                                                      "chat/messageThumb_image/user_$path.jpg")
                                                  .putFile(
                                                      await getThumbnailForImage(
                                                          await element.file,
                                                          40));

                                          uploadTaskThumbImage.events
                                              .listen((event) {
                                            setState(() {
                                              totalBytesTransfered = event
                                                  .snapshot.bytesTransferred
                                                  .round()
                                                  .toDouble();
                                            });
                                          });

                                          // 80% compressed image
                                          StorageTaskSnapshot
                                              storageSnapshotOrig =
                                              await uploadTaskOrigImage
                                                  .onComplete;
                                          String origi =
                                              await storageSnapshotOrig.ref
                                                  .getDownloadURL();
                                          // 40% compressed image
                                          StorageTaskSnapshot
                                              storageSnapshotThumb =
                                              await uploadTaskThumbImage
                                                  .onComplete;
                                          String thumb =
                                              await storageSnapshotThumb.ref
                                                  .getDownloadURL();

                                          await sendMedia(
                                              "image", origi, thumb);
                                          setState(() {
                                            startedUploading = false;
                                          });
                                        } else {
                                          StorageUploadTask uploadTaskVideo =
                                              storageRef
                                                  .child(
                                                      "chat/message_video/user_$path.mp4")
                                                  .putFile(
                                                      await compressVideoFile(
                                                    await element.file,
                                                  ));
                                          uploadTaskVideo.events
                                              .listen((event) {
                                            setState(() {
                                              totalBytesTransfered = event
                                                  .snapshot.bytesTransferred
                                                  .round()
                                                  .toDouble();
                                            });
                                          });
                                          StorageTaskSnapshot
                                              storageSnapshotVideo =
                                              await uploadTaskVideo.onComplete;
                                          String origi =
                                              await storageSnapshotVideo.ref
                                                  .getDownloadURL();

                                          StorageUploadTask uploadTaskThumb =
                                              storageRef
                                                  .child(
                                                      "chat/message_videoThumb/user_$path.jpg")
                                                  .putFile(
                                                      await getThumbnailForVideo(
                                                    await element.file,
                                                  ));

                                          uploadTaskThumb.events
                                              .listen((event) {
                                            setState(() {
                                              totalBytesTransfered = event
                                                  .snapshot.bytesTransferred
                                                  .round()
                                                  .toDouble();
                                            });
                                          });

                                          StorageTaskSnapshot
                                              storageSnapshotThumb =
                                              await uploadTaskThumb.onComplete;
                                          String thumb =
                                              await storageSnapshotThumb.ref
                                                  .getDownloadURL();

                                          await sendMedia(
                                              "video", origi, thumb);
                                          setState(() {
                                            startedUploading = false;
                                          });
                                        }
                                      });
                                    }
                                    if (media[1] == "image") {}
                                    if (media[1] == "video") {}
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(
                                    5,
                                  ),
                                  decoration: new BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(40.0),
                                        topRight: const Radius.circular(40.0),
                                        bottomLeft: const Radius.circular(40.0),
                                        bottomRight:
                                            const Radius.circular(40.0),
                                      )),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image(
                                        image: AssetImage(
                                          'assets/icons/gallery.png',
                                        ),
                                        height: 20,
                                        width: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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
                                onTap: () async {
                                  final gif = await GiphyPicker.pickGif(
                                    searchText: 'Type here for pick a gif',
                                    context: context,
                                    apiKey: GiphyApi_key,
                                    showPreviewPage: false,
                                    onError: (error) {
                                      print(error);
                                    },
                                  );
                                  if (gif != null) {
                                    await gifSend(gif.images.original.url);
                                  }
                                },
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
                                        bottomRight:
                                            const Radius.circular(40.0),
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
                    GestureDetector(
                      onTap: () async {
                        await textsend();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: new BoxDecoration(
                              color: Colors.black,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(40.0),
                                topRight: const Radius.circular(40.0),
                                bottomLeft: const Radius.circular(40.0),
                                bottomRight: const Radius.circular(40.0),
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 5,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image(
                              image: AssetImage(
                                'assets/icons/plane.png',
                              ),
                              color: Palette.mainAppColor,
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
    );
  }
}

class ChatBubbleUi extends StatelessWidget {
  final bool isMe;
  final String profileImg;
  final String message;
  final String messageType;
  final String time;
  const ChatBubbleUi({
    Key key,
    this.isMe,
    this.profileImg,
    this.message,
    this.messageType,
    this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    if (isMe) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: messageType != "text"
                            ? Colors.transparent
                            : Palette.mainAppColor,
                        borderRadius: getMessageType(messageType)),
                    child: messageType == "gif" || messageType == "image"
                        ? ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: CachedNetworkImage(
                              color: Color(0xffe0e0e0),
                              imageUrl: message,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: messageType == "image"
                                    ? height * 0.4
                                    : height * 0.3,
                                width: messageType == "image"
                                    ? width * 0.6
                                    : width * 0.5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.fill),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                  height: height * 0.3,
                                  width: width * 0.5,
                                  color: Color(0xffe0e0e0),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: flashProgress(),
                                  ))),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              useOldImageOnUrlChange: true,
                            ),
                          )
                        : messageType == "video"
                            ? Container(
                                height: height * 0.4,
                                width: width * 0.6,
                                child: ChatViewVideoplayer(
                                  video: message,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Text(
                                  message,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      time,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5), fontSize: 14),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: profileImg == null
                            ? AssetImage('assets/profilePhoto.png')
                            : CachedNetworkImageProvider(profileImg),
                        fit: BoxFit.cover)),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Flexible(
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: messageType != "text"
                            ? Colors.transparent
                            : Color(0xffe0e0e0),
                        borderRadius: getMessageType(messageType)),
                    child: messageType == "gif" || messageType == "image"
                        ? ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: CachedNetworkImage(
                              color: Color(0xffe0e0e0),
                              imageUrl: message,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: height * 0.3,
                                width: width * 0.5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.fill),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                  height: height * 0.3,
                                  width: width * 0.5,
                                  color: Color(0xffe0e0e0),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: flashProgress(),
                                  ))),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              useOldImageOnUrlChange: true,
                            ),
                          )
                        : messageType == "video"
                            ? ChatViewVideoplayer(
                                video: message,
                              )
                            : Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Text(
                                  message,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      time,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5), fontSize: 14),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    }
  }

  getMessageType(messageType) {
    if (isMe) {
      // start message
      if (messageType == "Text") {
        return BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(5),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      }
      // middle message
      else if (messageType == "image") {
        return BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(5),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      } else if (messageType == "gif") {
        return BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(5),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      }
      // end message
      else if (messageType == "video") {
        return BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(30),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      }
      // standalone message
      else {
        return BorderRadius.all(Radius.circular(30));
      }
    }
    // for sender bubble
    else {
      // start message
      if (messageType == "text") {
        return BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      }
      // middle message
      else if (messageType == "image") {
        return BorderRadius.only(
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      } else if (messageType == "gif") {
        return BorderRadius.only(
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      }
      // end message
      else if (messageType == "video") {
        return BorderRadius.only(
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      }
      // standalone message
      else {
        return BorderRadius.all(Radius.circular(30));
      }
    }
  }
}
