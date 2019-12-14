import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:preschool/setup/admin_page.dart';
import 'package:preschool/setup/setup_profile.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  String _email, _password, _error;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog

        return AlertDialog(
          title: new Text('Thông báo'),
          content: new Text(_error),
          actions: <Widget>[
            new MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //  backgroundColor:  Color.fromRGBO(38,50,56,1),

      body: Form(
        key: _formKey,
        child: new SingleChildScrollView(
            child: Column(
          children: <Widget>[showLogo(), inputemail(), inputpass(), button()],
        )),
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
                context,
                MaterialPageRoute(
                    builder: (context) => AdminPage(), fullscreenDialog: true));
          } else if (ds.data['profileimage'] == null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SetupProfilePage(),
                    fullscreenDialog: true));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(),
                    fullscreenDialog: true));
          }
        });
      } catch (e) {
        print(e.message);
        if (e.message ==
            'The password is invalid or the user does not have a password.') {
          _error = 'Bạn đã nhập sai mật khẩu';
        } else {
          _error = 'Bạn đã nhập sai E-mail';
        }

        _showDialog();
      }
    }
  }

  Widget inputemail() {
    return new Theme(
        data: new ThemeData(
          primaryColor: Colors.cyan,
          primaryColorDark: Colors.cyan,
        ),
        child: new Padding(
          padding: EdgeInsets.all(8.0),
          child: TextFormField(
            validator: (input) {
              if (input.isEmpty) {
                return 'Vui lòng nhập email ';
              }
            },
            onSaved: (input) => _email = input,
            decoration: new InputDecoration(
                border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30.0),
                    ),
                    borderSide: new BorderSide(color: Colors.teal)),
                hintText: 'Nhập E-mail',
                labelText: 'E-mail',
                prefixIcon: const Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                suffixStyle: const TextStyle(color: Colors.green)),
          ),
        ));
  }

  Widget inputpass() {
    return new Theme(
        data: new ThemeData(
          primaryColor: Colors.cyan,
          primaryColorDark: Colors.cyan,
        ),
        child: new Padding(
          padding: EdgeInsets.all(8.0),
          child: TextFormField(
            obscureText: true,
            validator: (input) {
              if (input.isEmpty) {
                return 'Vui lòng nhập pass ';
              }
            },
            onSaved: (input) => _password = input,
            decoration: new InputDecoration(
                border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30.0),
                    ),
                    borderSide: new BorderSide(color: Colors.purple[300])),
                hintText: 'Nhập mật khẩu',
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(
                  Icons.vpn_key,
                  color: Colors.black,
                ),
                suffixStyle: const TextStyle(color: Colors.green)),
          ),
        ));
  }

  Widget button() {
    return Container(
      width: 250,
      height: 70,
      padding: EdgeInsets.only(top: 20),
      child: RaisedButton(
        color: Colors.deepPurple[300],
        child: Text(
          "Đăng nhập",
          style: TextStyle(color: Colors.white),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30),
        ),
        onPressed: signIn,
      ),
    );
  }
}

Widget showLogo() {
  return new Hero(
    tag: 'hero',
    child: Padding(
      padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 130.0,
        child: Image.asset('assets/LGO.jpg'),
      ),
    ),
  );
}
