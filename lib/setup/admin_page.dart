import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preschool/setup/manage_class.dart';
import 'package:preschool/setup/manage_user.dart';
import 'package:preschool/setup/root.dart';
import 'package:preschool/setup/signin.dart';

class AdminPage extends StatefulWidget {
  @override
  const AdminPage({this.onSignedOut});
  final VoidCallback onSignedOut;
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Admin"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: <Widget>[
                Container(
                  height: 150.0,
            child: RaisedButton(
              padding: const EdgeInsets.all(8.0),
                      textColor: Colors.white,
                      color: Colors.blue,
              onPressed: nagivateToAccount,
              child: Text('Quản lý người dùng'),
            ),
          ),
            Container(
              height: 150.0,
            child: RaisedButton(
              padding: const EdgeInsets.all(8.0),
                      textColor: Colors.black,
                      color: Colors.yellow,
                 onPressed: nagivateToclass,
            child: Text(' Quản lý lớp học    '),
            ),
          ),
             ],

          ),
        
       
          Container(
            width: 100.0,
            child: Padding(
              padding: const EdgeInsets.only(top:155.0),
              child: RaisedButton(
                 textColor: Colors.white,
                      color: Colors.red,
                onPressed: nagivateToSignOut,
                child: Text('Đăng xuất'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      await _firebaseAuth.signOut().whenComplete(() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SigninPage(), fullscreenDialog: true));
      });
    } catch (e) {
      print(e);
    }
  }

  void nagivateToAccount() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ManageUserPage(), fullscreenDialog: true));
  }

  void nagivateToSignOut() {
    _signOut(context);
  }

  void nagivateToclass() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ManageClassPage(), fullscreenDialog: true));
  }
}
