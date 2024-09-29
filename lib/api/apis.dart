import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:talkie/api/get_server_key.dart';
import 'package:talkie/models/chat_user.dart';
import 'package:talkie/models/message.dart';
import 'package:http/http.dart' as http;

class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firestore
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for return current user
  static User get user => auth.currentUser!;

  //for storing self info
  static late ChatUser me;

  //for accessing firebase messaging(push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push token: $t');
      }
    });
  }

  //Server key
  static Future<String> getAccessToken() async {
    GetServerKey getServerKey = GetServerKey();
    return await getServerKey
        .getServerKeyToken(); // This will fetch the token using the method you wrote earlier
  }

  //to send push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final accessToken = await getAccessToken(); // Fetch the OAuth token

      final body = {
        "message": {
          "token": chatUser.pushToken, // Use device token here
          "notification": {
            "title": chatUser.name,
            "body": msg,
          },
        }
      };

      final url =
          'https://fcm.googleapis.com/v1/projects/talkie-a355f/messages:send';

      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $accessToken', // Use OAuth token instead of API key
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        log('Response status: ${res.statusCode}');
        log('Response body: ${res.body}');
      } else {
        log('Failed to send notification: ${res.statusCode}');
        log('Error: ${res.body}');
      }
    } catch (e) {
      log('\nsendPushNotification Error: $e');
    }
  }

//for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for user info
  static Future<bool> getSelfInfo() async {
    try {
      // Get the user's document from Firestore
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // If the user exists, set the 'me' object and return true
        me = ChatUser.fromJson(userDoc.data()!);
        await getFirebaseMessagingToken();

        //serverkey
        // GetServerKey getServerKey = GetServerKey();
        // String accessToken = await getServerKey.getServerKeyToken();
        // print(accessToken);

        //set user active status to active
        APIs.updateActiveStatus(true);
        return true;
      } else {
        // If the user doesn't exist, create the user and return false
        await createUser();
        return false;
      }
    } catch (e) {
      log('Error getting user info: $e');
      return false; // Return false in case of error
    }
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

  //getting specific user data from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where("id", isEqualTo: chatUser.id)
        .snapshots();
  }

  //Update Active Status
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  //update profile picture
  static Future<void> updateProfilePicture(File file) async {
    try {
      // Get the file extension (e.g., jpg, png)
      final ext = file.path.split('.').last;
      log('Extension: $ext');

      // Create a reference to the profile_picture directory with the user's UID
      final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

      // Upload the file to Firebase Storage
      await ref.putFile(file);

      // Retrieve the download URL after the file has been uploaded
      me.image = await ref.getDownloadURL();

      // Update the user's image URL in Firestore
      await firestore.collection('users').doc(user.uid).update({
        'image': me.image,
      });

      log('Profile picture updated successfully');
    } catch (e) {
      log('Failed to upload profile picture: $e');
    }
  }

  //**********Chat Screen Related APIs **********/

  //getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of a specific conversation from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending message
  static Future sendMessage(ChatUser chatUser, String msg, Type type) async {
    //message sending time(use as id also)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: "",
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');

    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //getting last message of a chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //Send chat image
  static Future sendChatImage(ChatUser chatUser, File file) async {
    try {
      // Get the file extension (e.g., jpg, png)
      final ext = file.path.split('.').last;
      log('File Extension: $ext');

      // Create a reference to the images directory in Firebase Storage
      final ref = storage.ref().child(
          'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

      // Upload the file to Firebase Storage
      await ref.putFile(file);
      log('Image uploaded successfully');

      // Retrieve the download URL after the file has been uploaded
      final imageUrl = await ref.getDownloadURL();
      log('Image URL: $imageUrl');

      // Send the image URL as a message in Firestore
      await sendMessage(chatUser, imageUrl, Type.image);
      log('Image message sent successfully');
    } catch (e) {
      log('Error uploading image: $e');
    }
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }
}
