import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:talkie/models/chat_user.dart';

class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firestore
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  static late ChatUser me;

//for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for user info
  static Future getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

//for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I am using Talkie",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  //getting user data from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  //for updating user info
  static Future updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //update profile picture
  static Future updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred : ${p0.bytesTransferred / 1000} kb');
    });

    //updating image data in firestore
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }
}
