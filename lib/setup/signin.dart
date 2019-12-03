import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:preschool/setup/admin_page.dart';
import 'package:preschool/setup/home_demo.dart';
import 'package:preschool/setup/setup_profile.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:  false,
    //  backgroundColor:  Color.fromRGBO(38,50,56,1),
      
      appBar: AppBar(
        title: Text("Sign in"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: (input) {
                if (input.isEmpty) {
                  return 'Vui lòng nhập email ';
                }
              },
              onSaved: (input) => _email = input,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              validator: (input) {
                if (input.isEmpty) {
                  return 'Vui lòng nhập password ';
                }
              },
              onSaved: (input) => _password = input,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            RaisedButton(
              onPressed: signIn,
              child: Text('Sign In'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        FirebaseUser user = (await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: _email, password: _password))
            .user;
        Firestore.instance
            .collection('Users')
            .document(user.uid)
            .get()
            .then((DocumentSnapshot ds) {
          // use ds as a snapshot
          if (ds.data['role'] == 'admin') {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AdminPage()));
          } else if (ds.data['profileimage'] == null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SetupProfilePage(user: user)));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(user: user)));
          }
        });
      } catch (e) {
        print(e.message);
      }
    }
  }
}
