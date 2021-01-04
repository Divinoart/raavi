import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:raavi/Home.dart';




class UserManagement {
  String _docId;
  storeNewUser(user, context) async{
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('/users').doc(firebaseUser.uid).set({
      'email': user.email,
      'displayname': user.displayName,
      'photoUrl': user.photoUrl,
      'uid': user.uid,
    }).then((value) {
//      print(value.documentID);
//      _docId = value.documentID;
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
//      Navigator.of(context).pushReplacementNamed('/homepage');
    }).catchError((e) {
      print(e.message);
    });

  }


}
