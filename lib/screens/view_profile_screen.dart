// import 'dart:convert';
// import 'dart:developer';

// ignore_for_file: avoid_web_libraries_in_flutter

// import 'package:chat_app/Widgets/chat_user_card.dart';

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_utils.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../APIs/API.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

// Sign Out
_signOut() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
        ),

       
        // body
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(children: [
              //For adding Some space
              SizedBox(
                width: mq.width,
                height: mq.height * .03,
              ),
              
              // User Profile Picture
              ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(
                      child: Icon(Icons.person_2_rounded),
                    ),
                  ),
                ),
              
               //For adding Some space

              SizedBox(
                height: mq.height * .03,
              ),

               //For adding Some space

           

              Text(
                widget.user.email,
                style: const TextStyle(
                    color: Color.fromARGB(210, 33, 31, 31), fontSize: 18 , fontWeight: FontWeight.w500),
              ),
              //For adding Some space
              SizedBox(
                height: mq.height * .02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('About : '  ,style:  TextStyle(fontSize: 18 , fontWeight: FontWeight.w500),), 
                    Flexible(
                      child: Text(
                      widget.user.about,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 14),
                                  ),
                    ),
                  ],
                ),
                SizedBox(height: mq.height * .4,),
                Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   Text('Joined On : '  ,style:  TextStyle(fontSize: 18 , fontWeight: FontWeight.w500 , color: Colors.black),), 
                   Text(
                   MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt ,showYear: true),
                   style: const TextStyle(
                       color: Colors.black87, fontSize: 15),
              ),
                 ],
                ),

            
            ]),
          ),
        ),
      ),
    );
  }

}