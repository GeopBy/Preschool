import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/models/user.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with AutomaticKeepAliveClientMixin<Profile> {
  @override
  static Random random = Random();
  String _idclass, _room, _year, _name;
  List<String> _image = List<String>();
  int _posts, _parents, _album = 0;
  bool _load = false;
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
      _idclass = ds.data['idClass'];
    });
    //tim teacher
    DocumentReference documentReference =
        Firestore.instance.collection('Class').document(_idclass);

    await documentReference.get().then((DocumentSnapshot ds) {
      _room = ds.data['room'];
      _year = ds.data['year'];
      _name = ds.data['className'];
    });
    await documentReference
        .collection('Posts')
        .getDocuments()
        .then((QuerySnapshot qs) {
      _posts = qs.documents.length;
      qs.documents.forEach((f) => {
            _image.add(f.data['postimage']),
          });
    });
    await documentReference
        .collection('Parents')
        .getDocuments()
        .then((QuerySnapshot qs) {
      _parents = qs.documents.length;
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
      body: new SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // CircleAvatar(
              //   backgroundImage: AssetImage(
              //     "assets/cm${random.nextInt(10)}.jpeg",
              //   ),
              //   radius: 70,
              // ),
              Text(
                _name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Phòng: ' + _room,
                style: TextStyle(),
              ),
              SizedBox(height: 3),
              Text(
                'Niên khóa: ' + _year,
                style: TextStyle(),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          _posts.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Bảng tin",
                          style: TextStyle(),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          _parents.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Phụ huynh",
                          style: TextStyle(),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          _album.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Albums",
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                padding: EdgeInsets.all(5),
                itemCount: _image.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 200 / 200,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Image.network(
                      _image[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
