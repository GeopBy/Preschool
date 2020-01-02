import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:preschool/drawers/detail_album.dart';
import 'package:preschool/models/album.dart';
import 'package:uuid/uuid.dart';

class ChooseImage extends StatefulWidget {
  @override
  final Album _album;
  ChooseImage(this._album);
  _ChooseImageState createState() => _ChooseImageState(this._album);
}

class _ChooseImageState extends State<ChooseImage> {
  @override
  final Album _album;
  _ChooseImageState(this._album);
  String _idclass;
  List<Asset> images = List<Asset>();

  String _error;
  bool _view = false;
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
      _idclass = ds.data['idClass'];
    });
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _view = true;
      print(images.toString());
      if (error == null) _error = 'No Error Dectected';
    });
  }

  Future<void> addImage(Album _album) async {
    List<String> uploadUrls = [];
    setState(() {
      _load = true;
    });
    await Future.wait(
        images.map((Asset asset) async {
          ByteData byteData = await asset.getByteData(quality: 25);
          List<int> imageData = byteData.buffer.asUint8List();
          String imageId = _album.name + '_' + Uuid().v4();
          StorageReference reference = FirebaseStorage.instance
              .ref()
              .child('Albums' + '/' + _album.name + '/' + imageId);
          StorageUploadTask uploadTask = reference.putData(imageData);
          StorageTaskSnapshot storageTaskSnapshot;

          // Release the image data

          StorageTaskSnapshot snapshot = await uploadTask.onComplete;
          if (snapshot.error == null) {
            storageTaskSnapshot = snapshot;
            final String downloadUrl =
                await storageTaskSnapshot.ref.getDownloadURL();
            uploadUrls.add(downloadUrl);

            print('Upload success');
          } else {
            print('Error from image repo ${snapshot.error.toString()}');
            throw ('This file is not an image');
          }
        }),
        eagerError: true,
        cleanUp: (_) {
          print('eager cleaned up');
        });
    if (_album.image[_album.image.length - 1] == "0") _album.image.removeLast();

    for (int i = 0; i < uploadUrls.length; i++) {
      print(_album.id);
      _album.image.insert(i, uploadUrls[i]);
      print('choose image' + _album.image[i]);
    }
    Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('Albums')
        .document(_album.id)
        .updateData({'image': _album.image}).whenComplete(() {
      print('add image ' + _album.image.length.toString());
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailAlbum(_album),
              settings: RouteSettings(
                arguments: _album,
              )));
    });
  }

  Widget build(BuildContext context) {
    // Album _album = ModalRoute.of(context).settings.arguments;

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.blueAccent),
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailAlbum(_album),
                    ),
                  )),
          title: Text(_album.name),
        ),
        body: Column(
          children: <Widget>[
            Center(
                child: Visibility(
                    child: AlertDialog(
                        content: SingleChildScrollView(
                      child: Text('Wait for minutes...'),
                    )),
                    visible: _load)),
            Center(
              child: !_view
                  ? RaisedButton(
                      child: Text('Pick Image'),
                      onPressed: loadAssets,
                    )
                  : SizedBox(),
            ),
            Center(
              child: _view
                  ? RaisedButton(
                      child: Text('Add Image'),
                      onPressed: () {
                        addImage(_album);
                      },
                    )
                  : SizedBox(),
            ),
            Expanded(
              child: buildGridView(),
            )
          ],
        ),
      ),
    );
  }
}
