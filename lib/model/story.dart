import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String userId;
  final String username;
  final String thumbnailUser;
  final List mediaUrl;
  final List thumbnailUrl;
  final List types;
  final double latitude;
  final double longitude;
  final Timestamp timestamp;

  Story({
    this.id,
    this.userId,
    this.username,
    this.thumbnailUser,
    this.mediaUrl,
    this.thumbnailUrl,
    this.types,
    this.latitude,
    this.longitude,
    this.timestamp,
  });

  factory Story.fromDocument(DocumentSnapshot doc) {
    return Story(
      id: doc['id'],
      userId: doc['userId'],
      username: doc['username'],
      thumbnailUser: doc['thumbnailUser'],
      mediaUrl: doc['mediaUrl'],
      thumbnailUrl: doc['thumbnailUrl'],
      types: doc['types'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      timestamp: doc['timestamp'],
    );
  }
}
