import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:ytory/config/collection.dart';
import 'package:ytory/model/user.dart';

addMessageToDb(String senderId, User sender, User reciever, String reciverId,
    String type, String message) async {
  User user = User();

  await messageRef.document(senderId).collection(reciverId).add({
    "id": senderId,
    "senderId": senderId,
    "receiverId": reciverId,
    "message": message,
    "type": type,
    "timestamp": timestamp,
  });

  await messageRef.document(reciverId).collection(senderId).add({
    "id": reciverId,
    "senderId": senderId,
    "receiverId": reciverId,
    "message": message,
    "type": type,
    "timestamp": timestamp,
  });

  QuerySnapshot snpse =
      await lastMessageRef.where("uid", isEqualTo: senderId).getDocuments();
  QuerySnapshot snpre =
      await lastMessageRef.where("uid", isEqualTo: reciverId).getDocuments();

  if (snpse.documents.isNotEmpty) {
    if (snpse.documents[0].exists) {
      await lastMessageRef.document(snpse.documents[0].documentID).delete();
    }
  }
  if (snpre.documents.isNotEmpty) {
    if (snpre.documents[0].exists) {
      await lastMessageRef.document(snpre.documents[0].documentID).delete();
    }
  }

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

addMessageToDbMedia(String senderId, User sender, User reciever,
    String reciverId, String type, String originalUrl, String thumbUrl) async {
  User user = User();

  await messageRef.document(senderId).collection(reciverId).add({
    "id": senderId,
    "senderId": senderId,
    "receiverId": reciverId,
    "url": originalUrl,
    "thumbnailUrl": thumbUrl,
    "message": null,
    "type": type,
    "timestamp": timestamp,
  });

  await messageRef.document(reciverId).collection(senderId).add({
    "id": reciverId,
    "senderId": senderId,
    "receiverId": reciverId,
    "url": originalUrl,
    "thumbnailUrl": thumbUrl,
    "message": null,
    "type": type,
    "timestamp": timestamp,
  });

  QuerySnapshot snpse =
      await lastMessageRef.where("uid", isEqualTo: senderId).getDocuments();
  QuerySnapshot snpre =
      await lastMessageRef.where("uid", isEqualTo: reciverId).getDocuments();

  if (snpse.documents.isNotEmpty) {
    if (snpse.documents[0].exists) {
      await lastMessageRef.document(snpse.documents[0].documentID).delete();
    }
  }
  if (snpre.documents.isNotEmpty) {
    if (snpre.documents[0].exists) {
      await lastMessageRef.document(snpre.documents[0].documentID).delete();
    }
  }

  await lastMessageRef.add({
    "uid": senderId,
    "sender": json.encode(user.toMap(sender)),
    "receiver": json.encode(user.toMap(reciever)),
    "type": "sender",
    "lastType": type,
    "message": thumbUrl,
    "isRead": false,
    "addedOn": timestamp,
  });
  await lastMessageRef.add({
    "uid": reciverId,
    "sender": json.encode(user.toMap(sender)),
    "receiver": json.encode(user.toMap(reciever)),
    "type": "reciever",
    "lastType": type,
    "message": thumbUrl,
    "isRead": false,
    "addedOn": timestamp,
  });
}

Stream<QuerySnapshot> streamingMessages(String currentUserid) {
  return lastMessageRef
      .where("uid", isEqualTo: currentUserid)
      .orderBy("addedOn", descending: true)
      .snapshots();
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

Future<String> uploadImageToMessages(File imageFile) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();

  StorageUploadTask uploadTask =
      storageRef.child("chat/message_image/user_$path.jpg").putFile(imageFile);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadImageToMessagesThumb(File imageFile) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();

  StorageUploadTask uploadTask = storageRef
      .child("chat/messageThumb_image/user_$path.jpg")
      .putFile(imageFile);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadVideoToMessages(File video) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();
  StorageUploadTask uploadTask =
      storageRef.child("chat/message_video/user_$path.mp4").putFile(video);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadVideoToMessagesThumb(File video) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();
  StorageUploadTask uploadTask =
      storageRef.child("chat/message_videoThumb/user_$path.jpg").putFile(video);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}
