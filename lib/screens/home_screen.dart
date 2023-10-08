
// import 'dart:convert';
// import 'dart:developer';

// import 'package:chat_app/Widgets/chat_user_card.dart';
import 'dart:developer';

import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/profileScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../APIs/API.dart';
import '../Widgets/chat_user_card.dart';
import '../main.dart';
import '../models/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
// Sign Out
_signOut()async{
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
}
class _HomeScreenState extends State<HomeScreen> {
  
  List<ChatUser> _list = [];
  // FINAL initalizes one
  final List<ChatUser> _searchList = [];
  // To check search
  bool _isSearching = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Api.getSelfInfo();
    
    SystemChannels.lifecycle.setMessageHandler((message) {
      
      log('Messgae :   $message ');
          // TO update Last Seen

          //resume = active  ,  // pause = inactive

      if(Api.createUser != null){    
      if(message.toString().contains('pause')) Api.updateActiveStatus(false);
  
      
      if(message.toString().contains('resume')) Api.updateActiveStatus(true);
    }

      return Future.value(message);
    });


  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on and back button is click then close search
        // go to main screen and if again back button click close app
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
          
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.home),
            title: _isSearching ?  TextField(
              decoration:const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Name, Email ...', focusColor: Colors.white),
                onChanged: (value){
                  //search logic
                  _searchList.clear();
          
                  for(var i in _list){
                    if(i.name.toLowerCase().contains(value.toLowerCase()) || 
                    i.email.toLowerCase().contains(value.toLowerCase())){
                      _searchList.add(i);
                      };
                      setState(() {
                        _searchList;
                      });
                  }
                } ,
                
                autofocus: true,
                style: const TextStyle(fontSize: 17 , color: Colors.white , letterSpacing: .5),
            ) :const Text('Connect'),
            actions: [
              // Search Button
              IconButton(onPressed: (){
                setState(() {
                  _isSearching = !_isSearching;
                });
              }, icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid : Icons.search )),
              // More Button
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> profileScreen(user:Api.me,)));
              }, icon: Icon(Icons.more_vert)),
              // IconButton(onPressed: (){_signOut();
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              // }, icon: Icon(Icons.logout_outlined)),
            ],
          ),
          
          // Floating Action Button
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom : 20.0 , right: 10.0),
            child: FloatingActionButton(onPressed: (){_signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));} , child:  Icon(Icons.logout_rounded , color: Colors.white,),
            
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            
            ),
          ),
          
        body: StreamBuilder(
          stream: Api.getAllUser(),
          builder: (context , snapshot){
            
          
            switch(snapshot.connectionState){
              // if data is loading
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator( 
                  color: Colors.amber,) , );
            
              // if some or all datais loaded then show it
              case ConnectionState.active:
              case ConnectionState.done:
             
              final data = snapshot.data?.docs;
              // // log('Data : $data()');
              // for (var i in data!){
              //   log('Data : ${jsonEncode(i.data())}');
              //   list.add(i.data()['name']);
              // }
          
              // works like for loop
              _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            
            if(_list.isNotEmpty){
                   return ListView.builder(
            padding: EdgeInsets.only(top: mq.height * .01),
            // itemCount: 10,
            itemCount: _isSearching ? _searchList.length : _list.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context , index){
            
            return ChatUserCard(user: _isSearching ? _searchList[index] : _list[index]);
            // return Text('Name : ${list[index]}');
          });
            }else{
              return const Center(child: Text('No Connections Found!' ,
               style: TextStyle(fontSize: 20 , fontWeight: FontWeight.w500) ,));
            }
             }
          
            
          },
        ),
         
        ),
      ),
    );
  }


}