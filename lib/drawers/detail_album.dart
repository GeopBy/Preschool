import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preschool/drawers/albums.dart';
import 'package:preschool/drawers/choose_image.dart';
import 'package:preschool/drawers/detail_image.dart';
import 'package:preschool/models/album.dart';

class DetailAlbum extends StatefulWidget {
  @override
  Album _album;
  DetailAlbum(this._album);
  _DetailAlbumState createState() => _DetailAlbumState(this._album);
}

class _DetailAlbumState extends State<DetailAlbum>
    with AutomaticKeepAliveClientMixin<DetailAlbum> {
  Album _album;
  _DetailAlbumState(this._album);
  bool _viewButton = false;
  bool _load = false;

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  Future<void> getInfo() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    //tim id class
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.data['role'] == 'teacher') {
        _viewButton = true;
      }
    });
    setState(() {
      _load = true;
    });
  }

  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runDetailAlbum();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget runDetailAlbum() {
    print('album la:' + _album.image.toString());
    return new Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.blueAccent),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Albums()))),
          title: Text(_album.name),
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 200 / 200,
                  ),
                  itemCount: _album.image.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailImage(),
                                settings: RouteSettings(
                                  arguments: _album.image[index],
                                ))),
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Image.network(
                            _album.image[index],
                            fit: BoxFit.cover,
                          ),
                        ));
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
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChooseImage(_album),
                  ));
            },
          ),
          visible: _viewButton,
        ));
  }
}
