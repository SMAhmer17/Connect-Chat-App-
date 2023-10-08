// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/helper/my_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../APIs/API.dart';
import '../main.dart';
import '../models/messages.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    
    bool isMe = Api.user.uid == widget.message.fromID;
    
    return InkWell(
      child : isMe ? _amberMessage() : _blueMessage() ,

      onLongPress: (){
          _showBottomSheet(isMe);
      },
    );
  }

  // sender or another sender msg
  Widget _blueMessage(){

      // update last read message if sender and receiver are different
      if(widget.message.read.isEmpty){
        Api.updateMessageReadStatus(widget.message);
        debugPrint('READ MSG UPDATED');
      }
return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

         // Time
        Padding(
          padding: EdgeInsets.only(left : mq.width  *.04),
          child:  Text(MyDateUtil.getFromatedTime(context: context, time: widget.message.sent),
          style:const TextStyle(
            fontSize: 12, color: Colors.black87
          ),),
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04 , 
            vertical: mq.height * .01 ),
            decoration : BoxDecoration(color : Colors.amber,
             border : Border.all(color:const  Color.fromARGB(255, 231, 125, 26)),
            borderRadius:const BorderRadius.only(
              topLeft:  Radius.circular(25),
              topRight:  Radius.circular(25),
              bottomLeft: Radius.circular(25),
             
            )
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .02 :   mq.width * .04),
              child:widget.message.type == Type.text ? 
              // show text
              Text(widget.message.msg,
              style:const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87
              ),) : 
              // show image
                ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
           imageUrl: widget.message.msg,
           placeholder: (context, url) =>const  Padding(
             padding: const EdgeInsets.all(8.0),
             child: const CircularProgressIndicator(strokeWidth: 2,),
           ),
           errorWidget: (context, url, error) => const Icon(Icons.image , size: 70,),
            ),
        ),
            ) ,
          ),
        ),
       
      ],
    );
  }

    // our or user msg
    Widget _amberMessage(){

     return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      
     

        // Message Content
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04 , 
            vertical: mq.height * .01 ),
            decoration : BoxDecoration(color : Color.fromARGB(255, 209, 217, 255),
             border : Border.all(color:Color.fromARGB(255, 94, 122, 195)),
            borderRadius:const BorderRadius.only(
              topLeft:  Radius.circular(25),
              topRight:  Radius.circular(25),
              bottomRight:  Radius.circular(25),
             
            )
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .02 :   mq.width * .04),
              child: 
              widget.message.type == Type.text ? 
              // show text
              Text(widget.message.msg,
              style:const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87
              ),) 
              : 
              // show image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
           imageUrl: widget.message.msg,
           placeholder: ((context, url) =>  CircularProgressIndicator()),
           errorWidget: (context, url, error) => const Icon(Icons.image , size: 70,),
            ),
        ),
            ) ,
          ),
        ),

         Row(
       
          children: [
        
                // sent Time
            Text(
              MyDateUtil.getFromatedTime(
                context: context, time: widget.message.sent
            ),
            style:const TextStyle(
              fontSize: 12, color: Colors.black87
            ),),

                SizedBox(width: mq.width * .03,),
                 // For double tick
        if(widget.message.read.isNotEmpty)
        Icon(Icons.done_all_rounded , color: Colors.blue , size: 20,),
        // For adding some space

          SizedBox(width: mq.width * .02,),
        
          ],
        ),
        
      ],
    );
  }

// Bottom sheet Function

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              // pick profile picture label
              Container(
                  height : 4 ,
                  margin: EdgeInsets.symmetric(vertical: mq.height * .015 , horizontal: mq.width * .4),
                decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8)
              ),),

                  // copy text
          widget.message.type == Type.text ? _OptionItem(icon: const Icon(Icons.copy_all_rounded , color: Color.fromARGB(255, 17, 148, 255), size: 26,) ,
           name: 'Copy Text', onTap: (){
            log('heelo');
            // For hidding  bottom sheet
             Clipboard.setData(ClipboardData(text: widget.message.msg))
            .then((value){
              log('heelo');
               Navigator.pop(context);

              Dialogs.showSnackbar(context, 'Text Coppied');
            });
           }) 
          : _OptionItem(icon: const Icon(Icons.download_rounded , color: Color.fromARGB(255, 17, 148, 255), size: 26,) ,
           name: 'Save Image',
           onTap: ()async{
            
           }),
          
          if(isMe)
          Divider(
                color: Colors.black,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

                // Edit
          if(widget.message.type == Type.text && isMe)     
          _OptionItem(icon: const Icon(Icons.edit , color: Color.fromARGB(255, 17, 148, 255), size: 26,) , name: 'Edit Message', onTap: (){}) ,
              // Delete
          if(isMe)
          widget.message.type == Type.text ?
          _OptionItem(icon: const Icon(Icons.delete , color: Colors.red, size: 26,) , name: 'Delete Message',
           onTap: ()async{
            log('heelo');
            await Api.deleteMessage(widget.message).
            then((value) {
              Navigator.pop(context);
              Dialogs.showSnackbar(context, 'Message Deleted');
           });}) :
          _OptionItem(icon: const Icon(Icons.delete , color: Colors.red, size: 26,) , name: 'Delete Image',
          onTap: ()async{
            log('heelo');
            await Api.deleteMessage(widget.message).then((value) {
              Navigator.pop(context);

              Dialogs.showSnackbar(context, 'Message Deleted');
           });}),
          
          Divider(
                color: Colors.black,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
                  // Sent At
          _OptionItem(icon: const Icon(Icons.visibility , color: Colors.blue, size: 26,) , name: 'Sent At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}', onTap: (){}),
          
                  // Read At
          _OptionItem(icon: const Icon(Icons.visibility , color: Colors.green, size: 26,) , name:
           widget.message.read.isEmpty ?  'Read At: Not seen yet '  
           : 'Read At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)} ', onTap: (){}),
              
              
            ],
          );
        });

        
  }
}
class _OptionItem extends StatelessWidget {
  const _OptionItem({super.key, required this.icon, required this.name, required this.onTap});
  
  final Icon icon;
  final String name;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: Padding(
        padding: EdgeInsets.only(top : mq.height * 0.015 , left: mq.width * 0.05 , bottom: mq.height * 0.025 , ),
        child: Row(
          children: [
            icon, Flexible(child: Text('        $name' , style: const TextStyle(fontSize: 15,letterSpacing: .5 , color: Colors.black ),))
          ],
        ),
      ),
    );
  }
}