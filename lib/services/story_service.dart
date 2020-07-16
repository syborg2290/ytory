import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:ytory/config/collection.dart';

addStory(
    String currentUserId,
    String username,
    String thumbnailUser,
    List<String> mediUrl,
    List<String> thumbUrl,
    List<String> types,
    double latitude,
    double longitude) async {
  var uuid = Uuid();
  await storyRef.add({
    "id": uuid.v1().toString() + new DateTime.now().toString(),
    "userId": currentUserId,
    "username": username,
    "thumbnailUser": thumbnailUser,
    "mediaUrl": mediUrl,
    "thumbnailUrl": thumbUrl,
    "types": types,
    "latitude": latitude,
    "longitude": longitude,
    "timestamp": timestamp,
  });
}

Stream<QuerySnapshot> streamingStories() {
  return storyRef.orderBy('timestamp', descending: true).snapshots();
}

Future<String> uploadImageToStory(File imageFile) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();

  StorageUploadTask uploadTask =
      storageRef.child("story/story_image/user_$path.jpg").putFile(imageFile);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadImageToStoryThumb(File imageFile) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();

  StorageUploadTask uploadTask = storageRef
      .child("story/storyThumb_image/user_$path.jpg")
      .putFile(imageFile);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadVideoToStory(File video) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();
  StorageUploadTask uploadTask =
      storageRef.child("story/story_video/user_$path.mp4").putFile(video);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<String> uploadVideoToStoryThumb(File video) async {
  var uuid = Uuid();
  String path = uuid.v1().toString() + new DateTime.now().toString();
  StorageUploadTask uploadTask =
      storageRef.child("story/story_videoThumb/user_$path.jpg").putFile(video);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  String downloadURL = await storageSnapshot.ref.getDownloadURL();
  return downloadURL;
}
