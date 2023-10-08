// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Widgets/message_card.dart';
import 'package:chat_app/helper/my_date_utils.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/models/chat_user.dart';
import 'package:image_picker/image_picker.dart';

import '../APIs/API.dart';
import '../main.dart';
import '../models/messages.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({
    super.key,
    required this.user,
  }) ;
  
  @override
  
  State<ChatScreen> createState() => _ChatScreenState();
  
  
}

class _ChatScreenState extends State<ChatScreen> {

// For storing all messages
  List<Message> _list = [];

// text controller - for handeling text messages
final _textController = TextEditingController();


// for storing value of showing or hiding emoji
bool _showEmoji  = false , _isuploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus() ,
      child: SafeArea(
        child: WillPopScope(
                  // if emoi are shown and back button press then hide emojis
        // go to main screen and if again back button click close app
        onWillPop: () {
          if(_showEmoji){
            setState(() {
              _showEmoji = !_showEmoji;
            });
            // future.value(false) - current screen not remove
            return Future.value(false);
          }else{
            // future.value(true) - current screen remove
            return Future.value(true);
          }
        },
          child: Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 220, 200),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                flexibleSpace: _appBar(),
                actions: [IconButton(onPressed: (){}, icon: Icon(Icons.call) , color: Colors.white,) , IconButton(onPressed: (){}, icon: Icon(Icons.more_vert_sharp) , color: Colors.white,) ],
              ),
            
              body: Column(children: [
                
                // stream
            
                Expanded(
                  child: StreamBuilder(
                          stream: Api.getAllMessages(widget
                          .user),
                          builder: (context , snapshot){
                  
                          
                  switch(snapshot.connectionState){
                    // if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const SizedBox();
                  
                    // if some or all datais loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                   
                    final data = snapshot.data?.docs;
                    
                    debugPrint('data :  ${jsonEncode(data![0].data())}' );
                    // // log('Data : $data()');
                    // for (var i in data!){
                    //   log('Data : ${jsonEncode(i.data())}');
                    //   list.add(i.data()['name']);
                    // }
                          
                    // works like for loop
                    
                    _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                  
                  
                  
                  if(_list.isNotEmpty){
                         return ListView.builder(
                  padding: EdgeInsets.only(top: mq.height * .01),
                  reverse: true,
                  // itemCount: 10,
                  itemCount:  _list.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context , index){
                   return MessageCard(message: _list[index],);
                          });
                  }else{
                    return const Center(child: Text('Say Hi! 👋' ,
                     style: TextStyle(fontSize: 28 , fontWeight: FontWeight.w500) ,));
                  }
                   }},),
                ),
                
                // if picture is uploading
                if (_isuploading)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical : 8.0 , horizontal: 20),
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  )),
                // chat inputs
                  _chatInput(),
            if(_showEmoji)
             SizedBox(
            height: mq.height * .35,
            child: EmojiPicker(
              textEditingController: _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
              config: Config(
                bgColor: const Color.fromARGB(255, 255, 220, 200),
              columns: 7,
              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
           ),
            ),
            ),
           ],),
            ),
        ),
      ),
    )

    ;


  }

  // App bar for chat screen
      Widget _appBar(){
      return  InkWell(
       onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(user: widget.user,)));

       },
       
        child: StreamBuilder(stream : Api.getUserInfo(widget.user) 
        , builder: ((context, snapshot) {
             final data = snapshot.data?.docs;
              final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
           return  Row(children: [
            IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back) , color: Colors.white,),
            ClipRRect(
          borderRadius: BorderRadius.circular(mq.height * .3),
          child: CachedNetworkImage(
            width: mq.height * .05,
            height: mq.height * .05,
           imageUrl: list.isNotEmpty ? list[0].image  : widget.user.image , 
           progressIndicatorBuilder: (context, url, downloadProgress) => 
                   CircularProgressIndicator(value: downloadProgress.progress),
           errorWidget: (context, url, error) => const CircleAvatar(child: Icon(Icons.person_2_rounded) ,),
            ),
        ),
        SizedBox(width: 10,),
      
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(list.isNotEmpty ? list[0].name : widget.user.name , style:const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500
            ),),
      
            // Last Seen
             Text(list.isNotEmpty ? 
              list[0].isOnline 
                ? 'Online' 
                : MyDateUtil.getLastActiveTime(context: context , lastActive : list[0].lastActive, )
              : MyDateUtil.getLastActiveTime(context: context ,lastActive : widget.user.lastActive, ) ,
               style:const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400
            ),)

          ],
        ),
        
        
          
            
          ],);
    

        }) ));
        

    }

      Widget _chatInput(){
        
        return Padding(
          padding: EdgeInsets.symmetric(vertical : mq.height * .025 , horizontal: mq.width * .022),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  color : Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                      // Emoji Button
                      IconButton(onPressed: (){
                        FocusScope.of(context).unfocus();
                        setState(() {
                        _showEmoji = !_showEmoji;
                        });

                      }, icon: const Icon(Icons.emoji_emotions) , color:Colors.orange,),
                
                      // Text Field
                       Expanded (
                        child: TextField (
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          onTap: (){setState(() {
                            if(_showEmoji)
                        _showEmoji = !_showEmoji;
                        });},
                          maxLines: null,
                          decoration:const InputDecoration(
                            hintText: 'Type something...' , 
                            hintStyle: TextStyle(color: Colors.orange),
                            border:  InputBorder.none,
                          ),
                          
                        ),
                      ),
                
                      // Gallery Button
                      IconButton(onPressed: () async {

                        final ImagePicker picker = ImagePicker();
                        // picking multipleimage
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        
                        // uploading and sending images one by one
                        for(var i in images){
                             log('Image Path : ${i.path}');
                          setState(() => _isuploading = true);
                             // To update profile picture in db
                         await  Api.sendChatImage(widget.user , File(i.path));
                         setState(() => _isuploading = false);
                        }
                        }
                        
                    , icon: Icon(Icons.image) , color: Colors.orangeAccent,),
                      // Camera Button
                      IconButton(onPressed: () async {
                        
                        final ImagePicker picker = ImagePicker();
                        // pick an image
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera , imageQuality: 70);
                        if (image != null) {
                          log('Image Path : ${image.path}');
                          setState(() => _isuploading = true);
                        
                          // To update profile picture in db
                         await  Api.sendChatImage(widget.user , File(image.path));
                          setState(() => _isuploading = false);
                        }
         }, 
                      icon: Icon(Icons.camera_alt) , color: Colors.orange,),
                       
                  ]),
                ),
              ),
              MaterialButton(onPressed: (){
                if (_textController.text.isNotEmpty){
                  Api.sendMessage(widget.user, _textController.text , Type.text);
                  _textController.text = '';
                }
              } ,
              minWidth: 0,
                padding: EdgeInsets.only(top :8 , bottom : 8 , right : 8 , left : 12),
                color: Color.fromARGB(255, 237, 148, 15), 
                shape: CircleBorder() ,
               child: Icon(Icons.send , color: Colors.white,) ,
              )
            ],
          ),
        );
      }
}
