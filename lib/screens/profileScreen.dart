// import 'dart:convert';
// import 'dart:developer';

// ignore_for_file: avoid_web_libraries_in_flutter

// import 'package:chat_app/Widgets/chat_user_card.dart';

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../APIs/API.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<profileScreen> createState() => _profileScreenState();
}

// Sign Out
_signOut() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
}

class _profileScreenState extends State<profileScreen> {
  final _formKey = GlobalKey<FormState>();
  // image pick to upload
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),

        // Floating Action Button
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20.0, right: 10.0),
          child: FloatingActionButton.extended(
            onPressed: () async {
              // for showing progress dialog
              Dialogs.showProgressbar(context);

              await Api.updateActiveStatus(false);

              await Api.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // for hiding progress dialog
                  Navigator.pop(context);

                  // for moving to home screen
                  Navigator.pop(context);

                  Api.auth = FirebaseAuth.instance;

                  // replacing gome screen with login screen
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                });
              });
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
        // body
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(children: [
                //For adding Some space
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),
                
                // User Profile Picture
                Stack(children: [
                  _image != null
                      ? // if

                      //Local image
                      ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: Image.file(
                            File(_image!),
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.cover,
                          ),
                        )
                      : //else
                      //image from server
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
           
                  // edit image button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: MaterialButton(
                      onPressed: () {
                        _showBottomSheet();
                      },
                      color: Colors.white,
                      shape: CircleBorder(),
                      child: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 243, 118, 15),
                      ),
                    ),
                  ),
                 ],),
                
                 //For adding Some space

                SizedBox(
                  height: mq.height * .03,
                ),

                 //For adding Some space

             

                Text(
                  widget.user.email,
                  style: const TextStyle(
                      color: Color.fromARGB(210, 33, 31, 31), fontSize: 19),
                ),
                //For adding Some space
                SizedBox(
                  height: mq.height * .06,
                  ),
             
                TextFormField(
                  initialValue: widget.user.name,
                  onSaved: (val) => Api.me.name = val ?? " ",
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : 'Required Field',
                  decoration: InputDecoration(
                      hintText: 'eg: Ali Khan',
                      label: const Text('Name'),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.amber,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      )),
                ),
   
                //For adding Some space
                SizedBox(
                  height: mq.height * .02,
                ),

                TextFormField(
                  initialValue: widget.user.about,
                  onSaved: (val) => Api.me.about = val ?? " ",
                  // to check form is fill
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : 'Required Field',
                  decoration: InputDecoration(
                      hintText: 'eg: Pakistan Zindabad',
                      label: const Text('About'),
                      prefixIcon:
                          const Icon(Icons.info_outline, color: Colors.amber),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      )),
                ),
                //For adding Some space
                SizedBox(
                  height: mq.height * .04,
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 242, 124, 13),
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * .4, mq.height * .055)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                     // log('inside vlidator');
                      _formKey.currentState!.save();
                      Api.updateUserInfo().then((value) {
                        Dialogs.showSnackbar(
                            context, 'Profile updated successfully');
                      });
                    }
                  },
                   icon: const Icon(
                     Icons.edit,
                     color: Colors.white,
                   ),
                   label: const Text(
                     'UPDATE',
                     style: TextStyle(color: Colors.white, fontSize: 16),
                   ),
                 )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // Bottom sheet Function

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .09),
            children: [
              // pick profile picture label
              const Text(
                'Pick Profile Picture ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // image picker save images as cached
                  // Pick image from gallery
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // pick an image
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery ,
                             imageQuality: 50);
                        if (image != null) {
                          log('Image Path : ${image.path} -- MimeType : ${image.mimeType}');
                           
                        // set image on circular avatar
                          setState(() {
                            _image = image.path;
                          });
                          
                          // To update profile picture in db
                          Api.updateProfilePicture(File(_image!));
                          
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 147, 133, 255),
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      child: Image.asset(
                        'images/gallery.png',
                        scale: 1,
                      )),

                  // capture image from camera
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // pick an image
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          log('Image Path : ${image.path}');
                          // set image on circular avatar
                          setState(() {
                            _image = image.path;
                          });
                          // To update profile picture in db
                          Api.updateProfilePicture(File(_image!));

                           // for hiding bottom sheet
                          Navigator.pop(context);
                        
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 147, 133, 255),
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      child: Image.asset('images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
