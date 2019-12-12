import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:preschool/setup/setup_children.dart';
import 'package:uuid/uuid.dart';

import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';

class SetupProfilePage extends StatefulWidget {
  @override
  const SetupProfilePage({this.onSignedOut});
  final VoidCallback onSignedOut;
  _SetupProfilePageState createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  FirebaseUser user;
  String _username, _fullname, _phonenumber, _address, _profileimage, _role;
  final _addressController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phonenumberController = TextEditingController();
  List<String> _myclass = List<String>();
  File file;
  String profileId = Uuid().v4();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _usernameController.dispose();
    _fullnameController.dispose();
    _phonenumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  getCurrentUser() async {
    user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      _role = ds.data['role'];
    });
  }

  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future getImage() async {
      File file = await ImagePicker.pickImage(
          source: ImageSource.gallery, maxWidth: 960, maxHeight: 675);
      setState(() {
        this.file = file;
      });
    }

    Future setupUser(BuildContext context) async {
      final tempDir = await getTemporaryDirectory();

      final path = tempDir.path;
      Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
      final compressedImageFile = File('$path/img_$profileId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
      setState(() {
        file = compressedImageFile;
      });

      StorageUploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('ProfileImage')
          .child("profile_$profileId.jpg")
          .putFile(file);
      StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
      String downloadUrl = await storageSnap.ref.getDownloadURL();

      _username = _usernameController.text;
      _fullname = _fullnameController.text;
      _phonenumber = _phonenumberController.text;
      _address = _addressController.text;
      _profileimage = downloadUrl;
      Firestore.instance.runTransaction((transaction) async {
        await transaction
            .update(Firestore.instance.collection('Users').document(user.uid), {
          "username": _username,
          "fullname": _fullname,
          "phonenumber": _phonenumber,
          "address": _address,
          "profileimage": _profileimage
        });
      });
      if (_role == 'teacher') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainScreen(onSignedOut: widget.onSignedOut)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SetupChildrenPage(onSignedOut: widget.onSignedOut)));
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Thiết lập đăng nhập lần đầu'),
      ),
      body: Builder(
        builder: (context) => Container(
          child: new SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.cyan[300],
                        child: ClipOval(
                          child: new SizedBox(
                            width: 195,
                            height: 195,
                            child: (file != null)
                                ? Image.file(
                                    file,
                                    fit: BoxFit.fill,
                                  )
                                : Image.network(
                                    "https://images.unsplash.com/photo-1502164980785-f8aa41d53611?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0.0),
                      child: IconButton(
                        icon: Icon(
                          FontAwesomeIcons.camera,
                          //  color: Colors.cyanAccent,
                          size: 30.0,
                        ),
                        onPressed: () {
                          getImage();
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0.0),
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(
                              'Tên hiển thị',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 1.0),
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Flexible(
                          child: new TextField(
                            controller: _usernameController,
                            decoration: new InputDecoration(
                              hintText: "Nhập tên hiển thị",
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.cyan[700])),
                            ),
                          ),
                        ),
                      ],
                    )),
                Padding(
                    padding:
                        EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(
                              'Họ và tên',
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 1.0),
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Flexible(
                          child: new TextField(
                            controller: _fullnameController,
                            decoration: new InputDecoration(
                              hintText: "Nhập họ và tên",
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.cyan[700])),
                            ),
                          ),
                        ),
                      ],
                    )),
                Padding(
                    padding:
                        EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(
                              'Số điện thoại',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 1.0),
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Flexible(
                          child: new TextField(
                              controller: _phonenumberController,
                              decoration: new InputDecoration(
                                hintText: "Nhập số điện thoại",
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.cyan[700])),
                              )),
                        ),
                      ],
                    )),
                Padding(
                    padding:
                        EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(
                              'Địa chỉ',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 1.0),
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Flexible(
                          child: new TextField(
                            controller: _addressController,
                            decoration: new InputDecoration(
                              hintText: "Nhập địa chỉ",
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.cyan[700])),
                            ),
                          ),
                        ),
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.only(left: 70.0, right: 25.0, top: 2.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 250,
                        height: 70,
                        padding: EdgeInsets.only(top: 20),
                        child: RaisedButton(
                          color: Colors.cyan[300],
                          child: Text(
                            "Lưu",
                            style: TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30),
                          ),
                          onPressed: () {
                            setupUser(context);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
