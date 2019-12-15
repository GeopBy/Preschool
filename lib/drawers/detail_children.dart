import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:preschool/models/children.dart';

class DetailChildren extends StatefulWidget {
  final String _idchildren, _idclass;
  DetailChildren(this._idclass, this._idchildren);
  _DetailChildrenState createState() =>
      _DetailChildrenState(_idclass, _idchildren);
}

class _DetailChildrenState extends State<DetailChildren>
    with AutomaticKeepAliveClientMixin<DetailChildren> {
  @override
  _DetailChildrenState(this._idclass, this._idchildren);
  String _idchildren;
  String _idclass;
  Children _children;
  bool _load = false;
  void initState() {
    getInfo();
    super.initState();
  }

  Future<void> getInfo() async {
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('Childrens')
        .document(_idchildren)
        .get()
        .then((DocumentSnapshot ds) {
          _children=Children.fromDocument(ds);
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
          title: Text(_children.name+_children.fullname+_children.birth),
        ),
        body: new Center());
  }
}
