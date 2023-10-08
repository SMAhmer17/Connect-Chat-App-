
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../APIs/API.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
   bool _isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

    
    // Handeled Google Buttton Click (Google Sign in)
    _handleGoogleBtnClick(){
      // For showing progress bar 
      Dialogs.showProgressbar(context);
      _signInWithGoogle().then((user) async {
        // For hiding progress bar 
        Navigator.pop(context);
       if(user != null ){
        log('\nUser : ${user.user} ');
        log('\nUserAdditionalInfo : ${user.additionalUserInfo} ');
       
        if((await Api.userExist())){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const HomeScreen()));
     
        }else[
          Api.createUser().then((value){
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const HomeScreen()));
    

          })
        ];
       
       }
      });
    }



      // Google sign in code    
  Future<UserCredential?> _signInWithGoogle() async {
    
  try{
    await InternetAddress.lookup('google.com');
    // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await Api.auth.signInWithCredential(credential);
  }catch(e){
    log('\n_signInWithGoogle: $e');
    Dialogs.showSnackbar(context, 'Something went wrong (Check Internet)');
   return null;

  }
  
}

// Sign Out
// _signinOut()async{ 
//   await FirebaseAuth.instance.signOut();
//   await GoogleSignIn().signOut();
// }

  @override
  Widget build(BuildContext context) {
    // mq = MediaQuery.of(context).size

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
       title: const Text("Let's Connect with loved Ones", style: TextStyle(fontSize: 18 , fontWeight: FontWeight.w500),),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1100 ),
            top: mq.height*.10, // 15 %
            width: mq.width*.5, // 50 %
            right: _isAnimate ? mq.width*.25 : -mq.width * 5,// 52 %
            
            child: Image.asset('images/icon.png')),

          // Email
        /*   Positioned(
            bottom: mq.height*.40, // 15 %
           width: mq.width*.75, // 50 %
            left: mq.width*.12,// 52 %
            height: mq.width*.12,
            
            child: TextFormField(
              decoration: InputDecoration(
                
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30)
                  ),
                
              ),
            )),
        */

          Positioned(width: mq.width*.75, // 50 %
            left: mq.width*.12,// 52 %
            height: mq.width*.12,
            bottom: mq.height*.29, // 15 %
            
            child: ElevatedButton(onPressed: (){}, child: Text('Sign in ' , style: TextStyle(color: Colors.white , fontWeight :FontWeight.w400)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 243, 148, 65),
                elevation : 1
            ),
            )),

         
          Positioned(width: mq.width*.75, // 50 %
            left: mq.width*.12,// 52 %
            height: mq.width*.12,
            bottom: mq.height*.22, // 15 %
            
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 243, 148, 65),
                elevation : 1
                ),
              onPressed: (){
                _handleGoogleBtnClick();
                //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const HomeScreen()));
              },
              icon:  Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset('images/google.png' ),
              ) , 
              label : RichText(text: const  TextSpan(
                style: TextStyle(color: Colors.white , fontWeight :FontWeight.w400),
                children: [
                  TextSpan(text: ' Sign in with '),
                  TextSpan(text: ' Google ' , style: TextStyle(fontWeight: FontWeight.w700))
                ]
              )),
              
              )),

                

               Positioned(width: mq.width*.75, // 50 %
            left: mq.width*.12,// 52 %
            height: mq.width*.12,
            bottom: mq.height*.15, // 15 %
            
            child: ElevatedButton(onPressed: (){}, child: Text('Create an Account' , style: TextStyle(color: Colors.white , fontWeight :FontWeight.w400)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 243, 148, 65),
                elevation : 1
            ),
            )),
       
        ],
      ),
    );
  }
}