import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preschool/setup/manage_class.dart';
import 'package:preschool/setup/manage_user.dart';
import 'package:preschool/setup/root.dart';

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
        title: Text("Admin"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RaisedButton(
            onPressed: nagivateToAccount,
            child: Text('Quản lý người dùng'),
          ),
          RaisedButton(
            onPressed: nagivateToclass,
            child: Text('Quản lý lớp'),
          ),
          RaisedButton(
            onPressed: nagivateToSignOut,
            child: Text('Đăng xuất'),
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
                builder: (context) => RootPage(), fullscreenDialog: true));
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
