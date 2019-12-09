import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:preschool/screens/home.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:uuid/uuid.dart';
import '../widgets/progress.dart';

class CreatePostPage extends StatefulWidget {
  @override
  const CreatePostPage({this.onSignedOut});
  final VoidCallback onSignedOut;

  _CreatePostPageState createState() => _CreatePostPageState(onSignedOut);
}

class _CreatePostPageState extends State<CreatePostPage>
    with AutomaticKeepAliveClientMixin<CreatePostPage> {
  final DateTime timestamp = DateTime.now();
  VoidCallback onSignedOut;
  _CreatePostPageState(this.onSignedOut);
  FirebaseUser user;
  File file;
  bool isUploading = false;
  bool success = false;

  String postId = Uuid().v4();
  TextEditingController locationControler = TextEditingController();
  TextEditingController captionControler = TextEditingController();
  String _idclass;
  String _profileimage;
  String _url;
  void initState() {
    _getInfo();
    super.initState();
    setState(() {});
  }

  Future<void> _getInfo() async {
    user = await FirebaseAuth.instance.currentUser();
    print('ccccccccccccccccccccccccccccccc' + user.toString());
    print(onSignedOut);
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      _idclass = ds.data['idClass'];
      _profileimage = ds.data['profileimage'];
    });
    final ref = FirebaseStorage.instance
        .ref()
        .child('ProfileImage')
        .child(_profileimage);
    _url = await ref.getDownloadURL();
    setState(() {});
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 960, maxHeight: 675);
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 960, maxHeight: 675);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text('Image from Gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              onPressed: () => selectImage(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Upload Image',
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
              color: Colors.deepOrange,
            ),
          )
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();

    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child("PostImages")
        .child("post_$postId.jpg")
        .putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('Posts')
        .document()
        .setData({
      "uid": user.uid,
      "postimage": mediaUrl,
      "description": description,
      "location": location,
      "times": timestamp,
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationControler.text,
      description: captionControler.text,
    );
    captionControler.clear();
    locationControler.clear();

    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
      success = true;
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: clearImage,
        ),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Post',
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
            onPressed: isUploading ? null : () => handleSubmit(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(_url),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionControler,
                decoration: InputDecoration(
                    hintText: 'Write a caption', border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: Container(
              width: 280,
              child: TextField(
                controller: locationControler,
                decoration: InputDecoration(
                    hintText: 'Where was this photo taken ?',
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                'Use Current Location',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.blue,
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formatedAdress = "${placemark.locality}, ${placemark.country}";
    locationControler.text = formatedAdress;
  }

  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
