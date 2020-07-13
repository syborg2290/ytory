import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ytory/config/collection.dart';

class AuthServcies {
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await auth.currentUser();
    return currentUser;
  }

  Future<QuerySnapshot> usernameCheckSe(String username) async {
    final result =
        await userRef.where('username', isEqualTo: username).getDocuments();
    return result;
  }

  Future<DocumentSnapshot> getUserObj(String id) async {
    DocumentSnapshot doc = await userRef.document(id).get();
    return doc;
  }

  Stream<QuerySnapshot> streamingUser(String currentUserId) {
    return userRef
        .where('id', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> emailCheckSe(String email) async {
    final result =
        await userRef.where('email', isEqualTo: email).getDocuments();
    return result;
  }

  Future<AuthResult> signInWithEmailAndPasswordSe(
      String email, String password) async {
    var _authenticatedUser =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _authenticatedUser;
  }

  Future<AuthResult> createUserWithEmailAndPasswordSe(
      String email, String password) async {
    AuthResult result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result;
  }

  createUserInDatabaseSe(
    String uid,
    String fullname,
    String username,
    String email,
  ) async {
    await userRef.document(uid).setData({
      "id": uid,
      "fullname": fullname,
      "username": username,
      "userPhotoUrl": null,
      "thumbnailUserPhotoUrl": null,
      "aboutYou": null,
      "email": email,
      "isOnline": true,
      "recentOnline": timestamp,
      "active": true,
      "androidNotificationToken": null,
      "timestamp": timestamp,
    });
  }

  createMessagingToken(String token, String currentUserId) async {
    await userRef
        .document(currentUserId)
        .updateData({"androidNotificationToken": token});
  }

  signout() async {
    await auth.signOut();
  }
}
