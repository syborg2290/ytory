import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String fullname;
  final String username;
  final String userPhotoUrl;
  final String thumbnailUserPhotoUrl;
  final String aboutYou;
  final String email;
  final bool isOnline;
  final Timestamp recentOnline;
  final bool active;
  final String androidNotificationToken;
  final Timestamp timestamp;

  User(
      {this.id,
      this.fullname,
      this.username,
      this.userPhotoUrl,
      this.thumbnailUserPhotoUrl,
      this.aboutYou,
      this.email,
      this.isOnline,
      this.recentOnline,
      this.active,
      this.androidNotificationToken,
      this.timestamp});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc["id"],
        fullname: doc['fullname'],
        username: doc['username'],
        userPhotoUrl: doc['userPhotoUrl'],
        thumbnailUserPhotoUrl: doc['thumbnailUserPhotoUrl'],
        aboutYou: doc['aboutYou'],
        email: doc['email'],
        isOnline: doc['isOnline'],
        recentOnline: doc['recentOnline'],
        active: doc['active'],
        androidNotificationToken: doc['androidNotificationToken'],
        timestamp: doc['timestamp']);
  }
}
