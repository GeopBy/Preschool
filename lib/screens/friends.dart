import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preschool/models/user.dart';
import 'package:preschool/screens/create_post.dart';
import 'package:preschool/util/data.dart';
import 'package:timeago/timeago.dart' as timeago;

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends>
    with AutomaticKeepAliveClientMixin<Friends> {
  @override
  FirebaseUser user;
  String _idclass;
  String _profileimage;
  String _teacher;
  List<String> _parents = List<String>();
  List<User> _users = List<User>();
  List<String> _urls = List<String>();
  var _url =
      "https://images.unsplash.com/photo-1502164980785-f8aa41d53611?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60";
  bool _load = false;
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
    //tim teacher va danh sach phu huynh
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .get()
        .then((DocumentSnapshot ds) {
      _teacher = ds.data['teacher'];
      if (ds.data['Parents'] != null) {
        _parents = List.from(ds.data['Parents']);
      }
    });
    //lay thong tin teacher
    await Firestore.instance
        .collection('Users')
        .document(_teacher)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.data['profileimage'] != null) {
        _users.add(User.fromDocument(ds));
      }
    });
    for (int i = 0; i < _parents.length; i++) {
      await Firestore.instance
          .collection('Users')
          .document(_parents[i])
          .get()
          .then((DocumentSnapshot ds) {
        if (ds.data['profileimage'] != null) {
          _users.add(User.fromDocument(ds));
        }
      });
    }
    setState(() {
      _load = true;
    });
  }

  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runFriends();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget runFriends() {
    return new Scaffold(
        body: new ListView.separated(
      padding: EdgeInsets.all(10),
      separatorBuilder: (BuildContext context, int index) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 0.5,
            width: MediaQuery.of(context).size.width / 1.3,
            child: Divider(),
          ),
        );
      },
      itemCount: _users.length,
      itemBuilder: (BuildContext context, int index) {
        String username;
        if (index == 0) username = 'Giáo viên '+_users[index].username;
        else username = _users[index].username;
        String fullname = _users[index].fullname;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                _users[index].profileimage,
              ),
              radius: 25,
            ),
            contentPadding: EdgeInsets.all(0),
            title: Text(username),
            subtitle: Text(fullname),
            trailing: false
                ? FlatButton(
                    child: Text(
                      "Unfollow",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.grey,
                    onPressed: () {},
                  )
                : FlatButton(
                    child: Text(
                      "Follow",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Theme.of(context).accentColor,
                    onPressed: () {},
                  ),
            onTap: () {},
          ),
        );
      },
    ));
  }
}
