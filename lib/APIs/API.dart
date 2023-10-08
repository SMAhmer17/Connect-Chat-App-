import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Api{
  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // For Accessing cloud firestore database 
  static FirebaseFirestore Firestore = FirebaseFirestore.instance;

    // For Accessing cloud firestore storage
  static FirebaseStorage storage = FirebaseStorage.instance;
  
    // For accessing firebase messenging
    static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

    // For getting firebase message token
    static Future<void> getFirebaseMessangingToker()async{

     await fmessaging.requestPermission();

      await fmessaging.getToken().then((token) {
        if(token != null){
          me.pushToken = token;
          log('Push Token $token');
        }
      });

      // To get logs of foreground messages 


//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   log('Got a message whilst in the foreground!');
//   log('Message data: ${message.data}');

//   if (message.notification != null) {
//     log('Message also contained a notification: ${message.notification}');
//   }
// });
    }


// To return current user
static User get user => auth.currentUser!;



// For storing Self INfo
static late ChatUser me;
static Future<void> getSelfInfo()async{
   await Firestore.collection('user').doc(user.uid).get().
   then((user) async {
    if(user.exists){
      me = ChatUser.fromJson(user.data()!);
      await getFirebaseMessangingToker();
    }else{
      await createUser().then((value) => getSelfInfo());
    }

   });
}


// For checking if user exist or not?

static Future<bool> userExist()async{
  return (await Firestore.collection('user').doc(user.uid).get()).exists;
}

  // For creating a new User

  static Future<void> createUser()async{
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(image: user.photoURL.toString(), about: 'Hey, We are using Connect Chat Application', name: user.displayName.toString(), createdAt: time, isOnline: false, id: auth.currentUser!.uid, lastActive: time, email:user.email.toString(), pushToken: '');
  return (await Firestore.collection('user').
  doc(user.uid).set(chatUser.toJson()));
}

// For getting all users from Firestore Database
static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(){
  return Firestore.collection('user').
  where('id' , isNotEqualTo: user.uid).snapshots();
}


 // for getting specific userInfo

  static Stream<QuerySnapshot<Map<String , dynamic>>> getUserInfo(ChatUser chatUser){
    return Firestore.collection('user').
  // for specific user
  where('id' , isEqualTo: chatUser.id).snapshots();
 }

// update online or last active status of user
static Future<void> updateActiveStatus(bool isOnline)async{
     Firestore.collection('user').doc(user.uid).update({
      'is_online' : isOnline ,
      'last_active' : DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token' : me.pushToken});}
  

// For updating UserInfo

static Future<void> updateUserInfo()async{
   await Firestore.collection('user').
   doc(user.uid).update({
   'name': me.name,
   'about' : me.about
   });
}


// For updating profile picture of a user
static Future<void> updateProfilePicture(File file) async {
  // getting image file extension
  final ext = file.path.split('.').last;
  debugPrint('Extension: $ext');

  // storage file ref with path
  final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
  
  // uploading image - push file in db
  await
  ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0){
    debugPrint('Data Transferred : ${p0.bytesTransferred / 1000} kb');

  });
  
  // updating image in firestore database
  me.image = await ref.getDownloadURL(); // url of download image
     await Firestore.collection('user').
     doc(user.uid).
     update({'image' : me.image});
}
     //***************CHAT SCREEN RELATED API's***************

// useful for getting conversation id
    // it will generate unique uid
static String getConversationID (String id) => user.uid.hashCode <= id.hashCode 
? '${user.uid}_$id'
: '${id}_${user.uid}';


// For getting all msgs from  specific conversationFirestore Database - Fetching msg API
static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user){
  return Firestore.collection('chats/${getConversationID(user.id)}/messages/')
  .orderBy('sent' , descending: true) // for showing last recent msg
  .snapshots();
}

 // Chats (collection) -->conversation_ID (doc) --> (messages (doc))

// for sending message

static Future<void> sendMessage(ChatUser chatUser , String msg , Type msgType) async{
  // messsage sending time also used as id
  final time = DateTime.now().millisecondsSinceEpoch.toString();

  // Message to send

  final Message message = Message(toID: chatUser.id, msg: msg,
   read: '', type: msgType, fromID: user.uid, sent: time);
 
  final ref = Firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
   await ref.doc(time).set(message.toJson()).then((value){
    sendPushNotfication(chatUser, msgType == Type.text ? msg : 'imgae');
   });
}


      //update read status of message

static Future<void> updateMessageReadStatus(Message message) async {
  Firestore.
  collection('chats/${getConversationID(message.fromID)}/messages/').
  doc(message.sent).update({'read' : DateTime.now().millisecondsSinceEpoch.toString() });
}

      // For getting last msgs from  specific conversationFirestore Database - Fetching msg API
static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(ChatUser user){
  return Firestore.
  collection('chats/${getConversationID(user.id)}/messages/')
  .orderBy('sent' , descending: true) // for showing last recent msg
  .limit(1)
  .snapshots();
}

    // Send Chat Images

static Future<void> sendChatImage(ChatUser chatUser , File file) async{
   // getting image file extension
  final ext = file.path.split('.').last;
  

  // storage file ref with path
  final ref = storage.ref().child('images/${getConversationID(chatUser.id)
  }/${DateTime.now().millisecondsSinceEpoch}.$ext');
  
  // uploading image - push file in db
  await 
  ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0){
    debugPrint('Data Transferred : ${p0.bytesTransferred / 1000} kb' );
  });
  
  // updating image in firestore database
  final imageUrl = await ref.getDownloadURL(); // url of download image
    await sendMessage(chatUser, imageUrl, Type.image);
}


// send push notifications


static Future<void> sendPushNotfication(ChatUser chatUser , String msg)async{
  try{
    final body = {
    "to" : chatUser.pushToken,
    "notification" :{
      "title" : chatUser.name,
      "body" : msg , 
      "android_channel_id": "chats",
       "data": {
      "some_data" : "User Id : ${me.id}",
  },

    }
  };
var url = Uri.https('example.com', 'whatsit/create');
var response = await http.post(Uri.parse(
  'https://fcm.googleapis.com/fcm/send'),
  headers: {HttpHeaders.contentTypeHeader : "application/json",
  HttpHeaders.authorizationHeader : "key = AAAArGjEsfk:APA91bG3FBbtmoKHmlq71kH9Q3nQJWe3M491aSyB1KP-x219wM-rtz_miZ-ymJ7lybV-3qAyTsbSecxhtJdtzwkB7ycmjpAL-M5HdROOe8jB_562CmXCoowCDESnHUWu1xuJIszK1XZg"
  },
   body:jsonEncode(body)  );
print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');
  }catch(e){
    log('Push Notification Error :- $e' );
  } 
}

      // DEELETE MESSAGE

  static Future<void> deleteMessage(Message message)async{
    await  Firestore.
  collection('chats/${getConversationID(message.toID)}/messages/').
  doc(message.sent).delete();

  if(message.type == Type.image){
  await storage.refFromURL(message.msg).delete();
  }
  }

}