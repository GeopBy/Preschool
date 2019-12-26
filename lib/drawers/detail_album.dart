import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preschool/drawers/albums.dart';
import 'package:preschool/drawers/choose_image.dart';
import 'package:preschool/drawers/detail_image.dart';
import 'package:preschool/models/album.dart';

class DetailAlbum extends StatefulWidget {
  @override
  _DetailAlbumState createState() => _DetailAlbumState();
}

class _DetailAlbumState extends State<DetailAlbum> {
  @override
  void initState() {
    super.initState();
    setState(() {
    });
  }

  Widget build(BuildContext context) {
    final Album _album = ModalRoute.of(context).settings.arguments;
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
                  itemCount: _album.image.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 200 / 200,
                  ),
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
                      builder: (context) => ChooseImage(),
                      settings: RouteSettings(
                        arguments: _album,
                      )));
            },
          ),
          visible: true,
        ));
  }
}
