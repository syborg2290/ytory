import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytory/model/user.dart';
import 'package:ytory/services/auth_service.dart';
import 'package:ytory/services/message_service.dart';
import 'package:ytory/utils/customTile.dart';
import 'package:ytory/utils/shimmers/chat_list.dart';
import 'package:ytory/widgets/chat_ui.dart';

class ChatSearch extends StatefulWidget {
  ChatSearch({Key key}) : super(key: key);

  @override
  _ChatSearchState createState() => _ChatSearchState();
}

class _ChatSearchState extends State<ChatSearch> {
  List<User> allUsersList = [];
  AuthServcies _authSerivice = AuthServcies();
  bool isLoading = true;
  String query = "";
  User currentUser;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllUser();
    _authSerivice.getCurrentUser().then((fuser) {
      _authSerivice.getUserObj(fuser.uid).then((user) {
        setState(() {
          currentUser = User.fromDocument(user);
          isLoading = false;
        });
      });
    });
  }

  getAllUser() async {
    QuerySnapshot allUsers = await getAllUsers();
    allUsers.documents.forEach((user) {
      setState(() {
        allUsersList.add(User.fromDocument(user));
      });
    });
  }

  buildSuggestions(String query) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final List<User> suggestionList = query.isEmpty
        ? []
        : allUsersList != null
            ? allUsersList.where((User user) {
                String _getUsername = user.username.toLowerCase();
                String _query = query.toLowerCase();
                String _getName = user.fullname.toLowerCase();
                bool matchesUsername = _getUsername.contains(_query);
                bool matchesName = _getName.contains(_query);

                return (matchesUsername || matchesName);

                // (User user) => (user.username.toLowerCase().contains(query.toLowerCase()) ||
                //     (user.name.toLowerCase().contains(query.toLowerCase()))),
              }).toList()
            : [];

    return suggestionList.isEmpty
        ? Center(
            child: Image.asset(
              'assets/empty_chat.jpg',
              width: width * 0.85,
              height: height * 0.7,
            ),
          )
        : ListView.builder(
            itemCount: suggestionList.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              User searchedUser = User(
                id: suggestionList[index].id,
                fullname: suggestionList[index].fullname,
                username: suggestionList[index].username,
                thumbnailUserPhotoUrl:
                    suggestionList[index].thumbnailUserPhotoUrl,
              );

              return allUsersList[index].id == currentUser.id
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: CustomTile(
                        mini: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      reciever: searchedUser,
                                    )),
                          );
                        },
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              searchedUser.thumbnailUserPhotoUrl == null
                                  ? AssetImage('assets/profilePhoto.png')
                                  : NetworkImage(
                                      searchedUser.thumbnailUserPhotoUrl),
                          backgroundColor: Colors.grey,
                        ),
                        title: Text(
                          searchedUser.username,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        subtitle: Text(
                          searchedUser.fullname,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
            }),
          );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.all(0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  query = val;
                });
              },
              controller: searchController,
              autofocus: true,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6), fontSize: 20.0),
              cursorColor: Colors.black,
              textAlign: TextAlign.justify,
              decoration: InputDecoration(
                hintText: "Search Friends",
                hintStyle: TextStyle(
                  fontSize: 18,
                ),
                fillColor: Color(0xffe0e0e0),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 5.0, vertical: 12.0),
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
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: IconButton(
                          icon: Image.asset(
                            'assets/icons/left-arrow.png',
                            width: width * 0.07,
                            height: height * 0.07,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
                  ),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: false,
      body: isLoading
          ? shimmerEffectLoadingChatList(context)
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Divider(
                    thickness: 1,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                allUsersList.isEmpty
                    ? Image.asset(
                        'assets/empty_chat.jpg',
                        width: width * 0.85,
                        height: height * 0.7,
                      )
                    : searchController.text != ""
                        ? buildSuggestions(query)
                        : Expanded(
                            child: ListView.builder(
                              itemCount: allUsersList.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return allUsersList[index].id == currentUser.id
                                    ? SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: CustomTile(
                                          mini: false,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                        reciever:
                                                            allUsersList[index],
                                                      )),
                                            );
                                          },
                                          leading: CircleAvatar(
                                            radius: 30,
                                            backgroundImage: allUsersList[index]
                                                        .thumbnailUserPhotoUrl ==
                                                    null
                                                ? AssetImage(
                                                    'assets/profilePhoto.png')
                                                : NetworkImage(
                                                    allUsersList[index]
                                                        .thumbnailUserPhotoUrl),
                                            backgroundColor: Colors.grey,
                                          ),
                                          title: Text(
                                            allUsersList[index].username,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
                                          ),
                                          subtitle: Text(
                                            allUsersList[index].fullname,
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      );
                              },
                            ),
                          ),
              ],
            ),
    );
  }
}
