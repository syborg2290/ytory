import 'package:cloud_firestore/cloud_firestore.dart';

class ChatLast {
  String uid;
  String sender;
  String receiver;
  String type;
  String lastType;
  String message;
  bool isRead;
  Timestamp addedOn;

  ChatLast({
    this.uid,
    this.sender,
    this.receiver,
    this.type,
    this.lastType,
    this.message,
    this.isRead,
    this.addedOn,
  });

  factory ChatLast.fromDocument(DocumentSnapshot doc) {
    return ChatLast(
      uid: doc['uid'],
      sender: doc['sender'],
      receiver: doc['receiver'],
      type: doc['type'],
      lastType: doc['lastType'],
      message: doc['message'],
      isRead: doc['isRead'],
      addedOn: doc['addedOn'],
    );
  }
}
