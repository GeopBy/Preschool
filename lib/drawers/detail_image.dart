import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class DetailImage extends StatefulWidget {
  @override
  _DetailImageState createState() => _DetailImageState();
}

class _DetailImageState extends State<DetailImage> {
  @override
  _DetailImageState();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final String _image = ModalRoute.of(context).settings.arguments;
    return new Scaffold(
        // appBar: AppBar(
        //   centerTitle: true,
        //   leading: new IconButton(
        //       icon: new Icon(Icons.arrow_back, color: Colors.blueAccent),
        //       onPressed: () => Navigator.push(
        //           context, MaterialPageRoute(builder: (context) => DetailAlbum()))),
        //   title: Text('Image'),
        // ),
        body: Container(
            child: PhotoView(
      imageProvider: NetworkImage(_image),
    )));
  }
}
