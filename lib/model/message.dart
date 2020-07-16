import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String id;
  String senderId;
  String receiverId;
  String message;
  String thumbnailUrl;
  String url;
  String type;
  Timestamp timestamp;

  Message({
    this.id,
    this.senderId,
    this.receiverId,
    this.message,
    this.url,
    this.thumbnailUrl,
    this.type,
    this.timestamp,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      id: doc['id'],
      senderId: doc['senderId'],
      receiverId: doc['receiverId'],
      url: doc['url'],
      thumbnailUrl: doc['thumbnailUrl'],
      message: doc['message'],
      type: doc['type'],
      timestamp: doc['timestamp'],
    );
  }
}
