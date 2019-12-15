import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/drawers/detail_children.dart';

class Childrens extends StatefulWidget {
  @override
  _ChildrensState createState() => _ChildrensState();
}

class _ChildrensState extends State<Childrens>
    with AutomaticKeepAliveClientMixin<Childrens> {
  @override
  FirebaseUser user;
  String _idclass;
  String _idchildren;
  bool _load = false;
  String childrenId;
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
    setState(() {
      _load = true;
    });
  }

  get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runChildrens();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget runChildrens() {
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Danh sách trẻ"),
      ),
      body: new Center(
          child: new Column(children: <Widget>[
        new Expanded(
            child: new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('Class')
              .document(_idclass)
              .collection("Childrens")
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
                        width: MediaQuery.of(context).size.width / 1.0,
                        child: Divider(),
                      ),
                    );
                  },
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text(snapshot.data.documents[index].data['name']),
                        subtitle: Text(snapshot.data.documents[index].data['fullname']),
                        trailing: Text(
                          snapshot.data.documents[index].data['birth'],
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                          ),
                        ),
                        onTap: () {
                          _idchildren= snapshot.data.documents[index].documentID;
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context) => DetailChildren(_idclass, _idchildren)));
                        },
                      ),
                    );
                  },
                );
            }
          },
        ))
      ])),
    );
  }
}
