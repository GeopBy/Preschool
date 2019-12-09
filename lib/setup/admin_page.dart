import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preschool/setup/auth.dart';
import 'package:preschool/setup/auth_provider.dart';
import 'package:preschool/setup/manage_class.dart';
import 'package:preschool/setup/manage_user.dart';

class AdminPage extends StatefulWidget {
  @override
  const AdminPage({this.onSignedOut});
  final VoidCallback onSignedOut;
  _AdminPageState createState() => _AdminPageState(onSignedOut);
}

class _AdminPageState extends State<AdminPage> {
  @override
  _AdminPageState(this.onSignedOut);
  VoidCallback onSignedOut;
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
            onPressed: nagivateToLogin,
            child: Text('Đăng xuất'),
          )
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();
      onSignedOut();
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

  void nagivateToLogin() {
    _signOut(context);
  }

  void nagivateToclass() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ManageClassPage(), fullscreenDialog: true));
  }
}
