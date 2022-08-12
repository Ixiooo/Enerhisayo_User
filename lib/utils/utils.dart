import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Utils{

  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  
  static showSnackBar(String? text){
  
    if(text == null) return;

    final snackBar = SnackBar(content: Text(text));

    messengerKey.currentState!
                ..removeCurrentSnackBar()
                ..showSnackBar(snackBar);

  }

  static showToast(String message)
  {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        backgroundColor: Colors.grey[700],
        fontSize: 16.0
    );
  }

  static showErrorDialog(BuildContext context, String message, String title)
  {
      Widget okButton = TextButton(  
        child: Text("OK"),  
        onPressed: () {  
          Navigator.of(context).pop();  
        },  
      );  
      
      AlertDialog alert = AlertDialog(  
        title: Text(title),  
        content: Text(message),  
        actions: [  
          okButton,  
        ],  
      );  
      
      showDialog(  
        context: context,  
        builder: (BuildContext context) {  
          return alert;  
        },  
      );  
  }

}