import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profileScreen.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.black26.withOpacity(.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: mq.height * .35,
        width: mq.width * .6,
        child: Stack(
          children: [

                // User Profile Picture
              Positioned(
                left: mq.width * .11,
                top: mq.width * .1,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .20),
                    child: CachedNetworkImage(
                      width: mq.width * .5,
                     
                      
                      fit: BoxFit.cover,
                      imageUrl: user.image,
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
              ),
 
          
          
              // User name
              Positioned(
                left: mq.width * .04,
                top: mq.height * .02,
                width: mq.width * .55,
                
                child: Text(user.name , style: const TextStyle(
                  fontSize: 16 , fontWeight: FontWeight.w500 , color: Colors.white
                ),),
              ),


               Positioned(
                right: 2,
                top: 6,
                child: MaterialButton(onPressed: (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: user,)));

                } ,shape : const CircleBorder(), child: Icon(         
               Icons.info_outline , color: Colors.amber, size: 30 ,),),
                       )
          ],
        ),
      ),
    );
  }
}