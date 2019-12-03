import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preschool/setup/manage_class.dart';
import 'package:preschool/setup/manage_user.dart';

class AdminPage extends StatefulWidget {
  @override
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
          )
        ],
      ),
    );
  }
  void nagivateToAccount(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ManageUserPage(),fullscreenDialog: true));
  }
  void nagivateToclass(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ManageClassPage(),fullscreenDialog: true));
  }
}