import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:preschool/screens/create_post.dart';
import 'package:preschool/util/data.dart';
import 'package:preschool/widgets/appbar.dart';
import 'package:preschool/widgets/post_item.dart';
import 'package:timeago/timeago.dart' as timeago;

class Home extends StatefulWidget {
  @override
  const Home({this.onSignedOut});
  final VoidCallback onSignedOut;

  _HomeState createState() => _HomeState(onSignedOut);
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {
  VoidCallback onSignedOut;
  _HomeState(this.onSignedOut);
  FirebaseUser user;
  String _idclass;
  String _profileimage;
  String _teacher;
  String _name;
  var _url =
      "https://images.unsplash.com/photo-1502164980785-f8aa41d53611?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60";
  bool _load = false;
  void initState() {
    getCurrentUser();
    super.initState();
  }

  Future<void> getCurrentUser() async {
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
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .get()
        .then((DocumentSnapshot ds) {
      _teacher = ds.data['teacher'];
    });
    //tim ten va hinh anh
    await Firestore.instance
        .collection('Users')
        .document(_teacher)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.data['profileimage'] != null) {
        _profileimage = ds.data['profileimage'];
      }
      if (ds.data['username'] != null) _name = ds.data['username'];
    });
    if (_profileimage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('ProfileImage')
          .child(_profileimage);
      _url = await ref.getDownloadURL();
    }
    setState(() {
      _load = true;
    });
    print('hhhhhhhhhhhhhhhhhhhhhh' + user.toString());
  }

  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runHome();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  String readTimestamp(Timestamp timeStamp) {
    int timestamp = timeStamp.millisecondsSinceEpoch;
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String time = timeago.format(dateTime);
    return time;
  }

  Widget runHome() {
    return new Scaffold(
        body: new Center(
            child: new Column(children: <Widget>[
          new Expanded(
              child: new StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('Class')
                .document(_idclass)
                .collection("Posts")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  return new ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: InkWell(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      CachedNetworkImageProvider(_url),
                                ),
                                contentPadding: EdgeInsets.all(0),
                                title: Text(
                                  _name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  readTimestamp(document['times']),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Image.network(
                                document['postimage'],
                                height: 170,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                      );
                    }).toList(),
                  );
              }
            },
          ))
        ])),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreatePostPage()));
          },
        ));
  }
}
