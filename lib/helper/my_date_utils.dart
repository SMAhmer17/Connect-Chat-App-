import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDateUtil {
  static String getFromatedTime({required BuildContext context , required String time}){
    
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context) ;
  }

// for getting formated time for send and read


  static String getMessageTime({
    required BuildContext context , required String time   ,bool showYear = false }){
      final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
      final DateTime now = DateTime.now();
      
      final formattedTime =  TimeOfDay.fromDateTime(sent).format(context) ;
      
      if(now.day == sent.day && now.month == sent.month  && sent.year == sent.year){
          return formattedTime;
      }
      return now.year == sent.year 
      ? '$formattedTime - ${sent.day} ${_getMonth(sent)}' 
      : '$formattedTime - ${sent.day} ${_getMonth(sent)} ${sent.year}'; 
      
  }





// get last message time used in chat user card

  static String getLastMessageTime({
    required BuildContext context , required String time   ,bool showYear = false }){
      final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
      final DateTime now = DateTime.now();
      if(now.day == sent.day && now.month == sent.month  && sent.year == sent.year){
          return TimeOfDay.fromDateTime(sent).format(context) ;
      }
      return showYear ? '${sent.day} ${_getMonth(sent) } ${sent.year}'   : '${sent.day} ${_getMonth(sent)}';
  }

// get last message time used in chat user card
  static String _getMonth(DateTime date){
    switch (date.month){
      case 1:
      return 'Jan';
      case 2:
      return 'Feb';
      case 3:
      return 'Mar';
      case 4:
      return 'Apr';
      case 5:
      return 'May';
      case 6: 
      return 'June';
      case 7:
      return 'July';
      case  8 :
      return 'Aug';
      case 9:
      return 'Sep';
      case 10:
      return 'Oct';
      case 11:
      return 'Nov';
      case 12:
      return 'Dec';
          }
        return 'NA';

  }

  // get last active time of user

static String getLastActiveTime({required BuildContext context ,
 required String lastActive}){


    // if throws error return -1
  final int i = int.tryParse(lastActive) ?? -1;

  // if time is not available then return the below statement
  if (i == -1) return 'Last seen not available';

  DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
  DateTime now = DateTime.now();

  String formatedTime = TimeOfDay.fromDateTime(time).format(context);
  if(time.day == now.day &&
   time.month == time.month  &&
   time.year == now.year){
    
      return 'Last seen at $formatedTime';
      }

   if((now.difference(time).inHours / 24).round() == 1){
    return 'Last seen yesterdat at $formatedTime';

   }

   String month = _getMonth(time);   
   return 'Last seen on ${time.day} $month on ${formatedTime}';
}



}

