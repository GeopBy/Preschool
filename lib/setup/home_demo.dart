import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeDemoPage extends StatelessWidget {
  const HomeDemoPage({Key key, this.user}):super(key:key);
  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.uid),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance.collection('Users').document(user.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Text('Loading...');
          default:
            return checkRole(snapshot.data);
          }
        },
      ),
    );
  } 
  Center checkRole(DocumentSnapshot snapshot){
    if(snapshot.data['role']=='admin'){
      return Center(child: Text(snapshot.data['email']));
    }
    else{
      return Center(child: Text(snapshot.data['role']));
    }
  }
}