import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/models/children.dart';
import 'package:preschool/models/user.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with AutomaticKeepAliveClientMixin<Profile> {
  @override
  bool _load = false;
  User _currentuser;
  Children _children;
  FirebaseUser user;
  void initState() {
    getUser();
    super.initState();
  }

  Future<void> getUser() async {
    user = await FirebaseAuth.instance.currentUser();
    //tim id class
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      _currentuser = User.fromDocument(ds);
    });
    setState(() {
      _load = true;
    });
  }

  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runProfile();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget runProfile() {
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Thông tin cá nhân"),
      ),
      body: new SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 40),
                    CircleAvatar(
                      backgroundImage: NetworkImage(_currentuser.profileimage),
                      radius: 80,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 50),
                    Text(
                      _currentuser.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.blueGrey[700])),
                              prefixIcon: Icon(
                                Icons.face,
                                color: Colors.cyan,
                              ),
                              hintStyle: TextStyle(
                                  fontSize: 17.0, color: Colors.black),
                              hintText: _currentuser.fullname),
                          enabled: false,
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.blueGrey[700])),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.cyan,
                              ),
                              hintStyle: TextStyle(
                                  fontSize: 17.0, color: Colors.black),
                              hintText: _currentuser.email),
                          enabled: false,
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.blueGrey[700])),
                              prefixIcon: Icon(
                                Icons.location_city,
                                color: Colors.cyan,
                              ),
                              hintStyle: TextStyle(
                                  fontSize: 17.0, color: Colors.black),
                              hintText: _currentuser.address),
                          enabled: false,
                        ),
                      ),
                    ]),
              ),
            ],
          ),
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: <Widget>[
          //     SizedBox(height: 40),
          //     CircleAvatar(
          //       backgroundImage: NetworkImage(_currentuser.profileimage),
          //       radius: 80,
          //     ),
          //     SizedBox(height: 10),
          //     Text(
          //       _currentuser.username,
          //       style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 22,
          //       ),
          //     ),
          //     SizedBox(height: 3),
          //     Text(
          //       _currentuser.fullname,
          //       style: TextStyle(),
          //     ),
          //     SizedBox(height: 20),
          //   ],
          // ),
        ),
      ),
    );
  }
}
