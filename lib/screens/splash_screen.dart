
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/home_screen.dart';

import '../../main.dart';
import '../APIs/API.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
   
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
        // Navigate the Home Screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginScreen()));
      // To display back Navigation bar and Notification Bar
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // Notification Styling
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white ,
        )
      );
      
        if(Api.auth.currentUser != null){
           log('\nUser : ${Api.auth.currentUser} ');
        log('\nUserAdditionalInfo : ${Api.auth} ');
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const HomeScreen()));
        }else{
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginScreen()));
       
        }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 194, 72),
      body: Stack(
        children: [
          // App logo
         Positioned(
            top: mq.height*.25, // 15 %
            width: mq.width*.5, // 50 %
            right: mq.width*.25 ,// 52 %
            
            child: Image.asset('images/icon.png')),

              
            Positioned(width: mq.width*.75, // 50 %
            left: mq.width*.12,// 52 %
            height: mq.width*.12,
            bottom: mq.height*.15, // 15 %
            
            child: Text("Let's Connect With Loved Ones", style: TextStyle(fontSize: 20 ) , textAlign: TextAlign.center,), ),
       

        ],
      ),
    );
  }
}