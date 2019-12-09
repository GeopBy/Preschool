import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:preschool/setup/admin_page.dart';
import 'package:preschool/setup/auth.dart';
import 'package:preschool/setup/auth_provider.dart';
import 'package:preschool/setup/home_demo.dart';
import 'package:preschool/setup/setup_children.dart';
import 'package:preschool/setup/setup_profile.dart';
import 'package:preschool/setup/signin.dart';
import 'package:preschool/widgets/appbar.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootPageState();
}

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notDetermined;
  String id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final BaseAuth auth = AuthProvider.of(context).auth;
    auth.currentUser().then((String userId) {
      setState(() {
        id=userId;
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void initState() {
    super.initState();
    
  }

  Future<void> currentUser() async {
    await FirebaseAuth.instance.currentUser().then((FirebaseUser _user) {
      id = _user.uid;
    });
  }

  void _signedIn() {
    setState(() {
      currentUser();
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        return SigninPage(
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        return _role();
    }
    return null;
  }

  Widget _role() {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance.collection('Users').document(id).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading...');
            default:
              switch (snapshot.data['role']) {
                case 'admin':
                  return AdminPage(onSignedOut: _signedOut);
                default:
                  switch (snapshot.data['profileimage']) {
                    case null:
                      return SetupProfilePage(onSignedOut: _signedOut);
                    default:
                    return MainScreen(onSignedOut: _signedOut);
                  }
                  
              }
          }
        },
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
