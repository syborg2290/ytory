import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:ytory/config/collection.dart';
import 'package:ytory/model/user.dart';

addMessageToDb(String senderId, User sender, User reciever, String reciverId,
    String type, String message) async {
  var uuid = Uuid();
  User user = User();

  await messageRef.document(senderId).collection(reciverId).add({
    "id": uuid.v1().toString() + new DateTime.now().toString(),
    "senderId": senderId,
    "receiverId": reciverId,
    "message": message,
    "type": type,
    "timestamp": timestamp,
  });
  
   await messageRef.document(reciverId).collection(senderId).add({
    "id": uuid.v1().toString() + new DateTime.now().toString(),
    "senderId": senderId,
    "receiverId": reciverId,
    "message": message,
    "type": type,
    "timestamp": timestamp,
  });

  await lastMessageRef.add({
    "uid": senderId,
    "sender": json.encode(user.toMap(sender)),
    "receiver": json.encode(user.toMap(reciever)),
    "type": "sender",
    "lastType": type,
    "message": message,
    "isRead": false,
    "addedOn": timestamp,
  });
  await lastMessageRef.add({
    "uid": reciverId,
    "sender": json.encode(user.toMap(sender)),
    "receiver": json.encode(user.toMap(reciever)),
    "type": "reciever",
    "lastType": type,
    "message": message,
    "isRead": false,
    "addedOn": timestamp,
  });
}

Stream<QuerySnapshot> streamingMessages(String currentUserid) {
  return lastMessageRef.where("uid", isEqualTo: currentUserid).snapshots();
}

Stream<QuerySnapshot> streamingMessagesSpecificUser(
    String currentUserId, String specificUserId) {
  return messageRef
      .document(currentUserId)
      .collection(specificUserId)
      .orderBy("timestamp", descending: true)
      .snapshots();
}

Future<QuerySnapshot> getAllUsers() async {
  return await userRef.getDocuments();
}
