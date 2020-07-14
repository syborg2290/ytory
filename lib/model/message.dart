import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String type;
  final Timestamp timestamp;

  Message({
    this.id,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      id: doc['id'],
      senderId: doc['senderId'],
      receiverId: doc['receiverId'],
      message: doc['message'],
      type: doc['type'],
      timestamp: doc['timestamp'],
    );
  }
}
