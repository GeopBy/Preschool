import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:preschool/setup/admin_page.dart';
import 'package:preschool/setup/home_demo.dart';
import 'package:preschool/setup/setup_children.dart';
import 'package:preschool/setup/setup_profile.dart';
import 'package:preschool/setup/signin.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage>
    with AutomaticKeepAliveClientMixin<RootPage> {
  FirebaseUser _user;
  bool _loadata = false;
  void initState() {
    getCurrentUser();
    super.initState();
  }

  Future<void> getCurrentUser() async {
    _user = await FirebaseAuth.instance.currentUser().whenComplete(() {
      if (!mounted) return;
      setState(() {
        _loadata = true;
      });
    });
  }

  get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _loadata == false ? _buildWaitingScreen() : runRoot();
  }

  Scaffold runRoot() {
    if (_user != null && _user.uid != null) {
      return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('Users')
              .document(_user.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Loading...');
              default:
                switch (snapshot.data['role']) {
                  case 'admin':
                    return AdminPage();
                  default:
                    switch (snapshot.data['profileimage']) {
                      case null:
                        return SetupProfilePage();
                      default:
                        return MainScreen();
                    }
                }
            }
          },
        ),
      );
    } else {
      return Scaffold(body: SigninPage());
    }
  }

  Scaffold _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
