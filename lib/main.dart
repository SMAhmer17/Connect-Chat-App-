import 'dart:developer';


import 'package:chat_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'firebase_options.dart';

// Gloal object for accessing device screen size
late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // To hide back Navigation bar and Notification Bar
  /*
  Also add single line that is
   <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
   in
   android>app>src>res>values>style.xml and value-night>styles.xml
   */
   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // tO SET Orientation portrait returns future fn
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp , DeviceOrientation.portraitDown]).then((value) {
     initializeFirebase();
  runApp(const MyApp());
  } 
  );
 
 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lets Connect',
      theme: ThemeData(
          
          // App bar
      appBarTheme:const AppBarTheme(
        centerTitle:  true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600
        ),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Color.fromARGB(255, 216, 118, 32),
        elevation: 1,
      ), 
      floatingActionButtonTheme:const  FloatingActionButtonThemeData(
        backgroundColor: Color.fromARGB(255, 216, 118, 32) ),


       useMaterial3: true,
      ),
      home: SplashScreen() ,
      
    );
  }
}

initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
);
var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,

);
log('Notification result : $result');
}

