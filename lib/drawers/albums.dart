import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/drawers/choose_image.dart';
import 'package:preschool/drawers/detail_album.dart';
import 'package:preschool/models/album.dart';
import 'package:preschool/screens/main_screen.dart';

class Albums extends StatefulWidget {
  @override
  _AlbumsState createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums>
    with AutomaticKeepAliveClientMixin<Albums> {
  String _idclass;
  List<Album> _album = List<Album>();
  bool _load = false;
  bool _viewButton = false;

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
      if (ds.data['role'] == 'teacher') _viewButton = true;
    });
    DocumentReference documentReference =
        Firestore.instance.collection('Class').document(_idclass);
    await documentReference
        .collection('Albums')
        .orderBy('pos', descending: true)
        .getDocuments()
        .then((QuerySnapshot qs) {
      qs.documents.forEach((f) {
        _album.add(Album.fromDocument(f));
      });
    });
    setState(() {
      _load = true;
    });
  }

  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runAlbum();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget runAlbum() {
    return new Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.blueAccent),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => MainScreen())),
          ),
          title: Text('Album Ảnh'),
        ),
        body: new SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  primary: false,
                  padding: EdgeInsets.all(5),
                  itemCount: _album.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 200 / 200,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 3.0)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: new BorderRadius.circular(10.0),
                                child: Image.network(
                                  _album[index].image[0],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 0.0, right: 0.0, top: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _album[index].name,
                                      style: TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 0.0, right: 0.0, top: 0.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      _album[index].date.substring(0, 10),
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailAlbum(_album[index]),
                              // settings: RouteSettings(
                              //   arguments: _album[index],
                              // ),
                            )));
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Visibility(
          child: FloatingActionButton(
            child: Icon(
              Icons.add,
            ),
            onPressed: _showAddDialog,
          ),
          visible: _viewButton,
        ));
  }

  Future<void> addAlbum(String name) async {
    DocumentReference ref = await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('Albums')
        .add({
      'name': name,
      'date': DateTime.now().toString(),
      'pos': DateTime.now().millisecondsSinceEpoch.toString(),
      'image': ['0']
    });
    String _id = ref.documentID;
    Firestore.instance.runTransaction((transaction) async {
      await transaction.update(
          Firestore.instance
              .collection('Class')
              .document(_idclass)
              .collection('Albums')
              .document(_id),
          {
            "id": _id,
          }).whenComplete(() {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Albums(),
            ));
      });
    });
    // Navigator.pop(context);
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => Albums(),
    //     ));
    // Album album = new Album();
    // await Firestore.instance
    //     .collection('Class')
    //     .document(_idclass)
    //     .collection('Albums')
    //     .document(_id)
    //     .get()
    //     .then((DocumentSnapshot ds) {
    //   album = Album.fromDocument(ds);
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => DetailAlbum(album),
    //           // settings: RouteSettings(
    //           //   arguments: album,
    //           // )
    //           ));
    // });
  }

  final _formKey = GlobalKey<FormState>();
  String name;
  _showAddDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  width: 300.0,
                  height: 200.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Vui lòng nhập dữ liệu ';
                            }
                          },
                          onSaved: (input) => name = input,
                          decoration:
                              InputDecoration(labelText: 'Nhập tên album ảnh:'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("OK"),
                          onPressed: () {
                            //firebase
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              addAlbum(name);
                              // getUser();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }
}
