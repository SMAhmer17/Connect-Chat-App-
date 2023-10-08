import 'package:flutter/material.dart';
class Dialogs{
  // Using these class object as a global by using static keyword
  static void showSnackbar(BuildContext context , String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg , textAlign: TextAlign.center,) , backgroundColor: Color.fromARGB(255, 210, 106, 8).withOpacity(.8), behavior: SnackBarBehavior.floating,));
  }

  static void showProgressbar(BuildContext context , ){
   showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator( color: Colors.amber,) , ));
   }

}