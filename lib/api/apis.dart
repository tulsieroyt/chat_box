import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:http/http.dart';

import 'package:chat_box/data/models/chat_user.dart';
import 'package:chat_box/data/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static late ChatUser me;

  static User get user => auth.currentUser!;

  ///For accessing firebase messaging (Push Notification)
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await firebaseMessaging.requestPermission();

    await firebaseMessaging.getToken().then(
      (t) {
        if (t != null) {
          me.pushToken = t;
          log('Push Token: $t');
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> sendFirebasePushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final messageBody = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAp_fN_W4:APA91bGDPqzUkdDm-zR62UWrbqVh2l9vBTxZWLKSLwnW6L8bchKHZ6_HJBe0frxq8xOGwaxP8giwHDsKaW5mmiCdFhiIVcxgi2P2fDjnkUDc8fBGwPmb3RbZFC8yJbHI_0OqtXT4npIl'
              },
              body: jsonEncode(messageBody));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  ///To check user exist or not
  static Future<bool> userExists() async {
    return (await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  ///To get self info
  static Future<void> getSelfInfo() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then(
      (user) async {
        if (user.exists) {
          me = ChatUser.fromJson(user.data()!);

          ///To get the access token from user
          await getFirebaseMessagingToken();

          ///To update active status
          APIs.updateActiveStatus(true);
        } else {
          await createUser().then((value) => getSelfInfo());
        }
      },
    );
  }

  ///To create a new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using Chat Box",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return (await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson()));
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }


  ///To get the all user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> usersId) {
    return firestore
        .collection('users')
        .where('id', whereIn: usersId)
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  ///To get active status
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    await firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  ///To update user info
  static Future<void> updateUserInfo() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  ///To update user profile picture
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');
    await ref.putFile(file).then((p0) {
      log('Data transfered: ${p0.bytesTransferred}/1000 kb');
    });

    me.image = await ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  ///----------------Chat related API ----------------------

  ///To generate conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  ///To get all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('send', descending: true)
        .snapshots();
  }

  ///To send message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: type,
        fromId: user.uid,
        send: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendFirebasePushNotification(
            chatUser, type == Type.text ? msg : 'image'));
  }

  ///To update message read status
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.send)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  ///To get last message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('send', descending: true)
        .limit(1)
        .snapshots();
  }

  ///To send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref.putFile(file).then((p0) {
      log('Data transfered: ${p0.bytesTransferred}/1000 kb');
    });

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.send)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.send)
        .update({'msg': updatedMsg});
  }
}
