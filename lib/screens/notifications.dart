import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with AutomaticKeepAliveClientMixin<Notifications> {
  @override
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
    return _load == false ? buildWaitingScreen() : runNotifications();
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

  Widget runNotifications() {
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
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return new ListView.separated(
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
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(_url),
                          radius: 25,
                        ),
                        contentPadding: EdgeInsets.all(0),
                        title: Text(_name + ' đã thêm bài viết mới trong lớp'),
                        trailing: Text(
                          readTimestamp(
                              snapshot.data.documents[index].data['times']),
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 11,
                          ),
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                );
            }
          },
        ))
      ])),
    );

    // return new Scaffold(
    //   body: ListView.separated(
    //     padding: EdgeInsets.all(10),
    //     separatorBuilder: (BuildContext context, int index) {
    //       return Align(
    //         alignment: Alignment.centerRight,
    //         child: Container(
    //           height: 0.5,
    //           width: MediaQuery.of(context).size.width / 1.3,
    //           child: Divider(),
    //         ),
    //       );
    //     },

    //     itemCount: notifications.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       Map notif = notifications[index];
    //       return Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: ListTile(
    //           leading: CircleAvatar(
    //             backgroundImage: CachedNetworkImageProvider(_url),
    //             radius: 25,
    //           ),
    //           contentPadding: EdgeInsets.all(0),
    //           title: Text(_name + ' đã thêm bài viết mới trong lớp'),
    //           trailing: Text(
    //             notif['time'],
    //             style: TextStyle(
    //               fontWeight: FontWeight.w300,
    //               fontSize: 11,
    //             ),
    //           ),
    //           onTap: () {},
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}
