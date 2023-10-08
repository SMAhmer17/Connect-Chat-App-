
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Widgets/dialogs/profile_dialog.dart';
import 'package:chat_app/helper/my_date_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import '../APIs/API.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/messages.dart';
import '../screens/chat_screen.dart';


class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});
  
final ChatUser user;


  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  // last message info(if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
   
    return  Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .02 , vertical: 4),
      color: Color.fromARGB(255, 255, 202, 149),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child:  InkWell
    (// for navigating to chat screen
      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(user: widget.user,)));},
      child:StreamBuilder(
        
        stream: Api.getLastMessages(widget.user),
        builder: (context , snapshot){
             final data = snapshot.data?.docs;
              final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              
             // data first doc exist ?
             if(list.isNotEmpty){
              _message = list[0];
             }
           
          return 
        ListTile(
      
      // leading: CircleAvatar(child: Icon(Icons.person_2_rounded) ,),
        // For showing Network Image
        leading: InkWell(

          // to show user picture from message screen in aert box
          onTap: (){
            showDialog(context: context, builder: (_)=> ProfileDialog(user: widget.user));
          },
          child: ClipRRect(
          borderRadius: BorderRadius.circular(mq.height * .6),
          child: CachedNetworkImage(
            width: mq.width * .1,
            height: mq.height * .2,
           imageUrl: widget.user.image,
           progressIndicatorBuilder: (context, url, downloadProgress) => 
                   CircularProgressIndicator(value: downloadProgress.progress),
           errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person_2_rounded) ,),
            ),
              ),
        ),

      // User Namee
      title: Text(widget.user.name),
      
      // Last Message - time
      subtitle: Text(_message != null ? // Nested if statement  
      _message!.type == Type.image ? 'Image' 
      
      :
      _message!.msg  : widget.user.about , maxLines: 1,),
     
      trailing: _message == null ? null // show nothing when no message is sent
       : 
        _message!.read.isEmpty && _message!.fromID != Api.user.uid
         ?  Container( // show green . for unread msg
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 247, 99, 0),
          borderRadius: BorderRadius.circular(10),
        ),
      ) 
      : // show sent time
       Text(
        MyDateUtil.getLastMessageTime(context: context, time: _message!.sent )
        , style: TextStyle(color: Colors.black54),
      )
    );

      },)


),);
  }
  
  
}