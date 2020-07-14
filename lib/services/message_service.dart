import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:ytory/config/collection.dart';

addMessageToDb(
    String senderId, String reciverId, String type, String message) async {
  var uuid = Uuid();

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
}


Stream<QuerySnapshot> streamingMessages(String currentUserid) {
  return messageRef.document(currentUserid).parent().snapshots();
    
}