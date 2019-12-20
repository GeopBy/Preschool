import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preschool/setup/root.dart';

class ChangeClass extends StatefulWidget {
  @override
  _ChangeClassState createState() => _ChangeClassState();
}

class _ChangeClassState extends State<ChangeClass>
    with AutomaticKeepAliveClientMixin<ChangeClass> {
  @override
  String _class, _idclass;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _posclass;
  bool _load = false;

  FirebaseUser user;
  List<String> _listclass = List<String>();
  List<String> _listidclass = List<String>();
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
      _listidclass = List.from(ds.data['myClass']);
    });
    for (int i = 0; i < _listidclass.length; i++) {
      await Firestore.instance
          .collection('Class')
          .document(_listidclass[i])
          .get()
          .then((DocumentSnapshot ds) {
        _listclass.add(ds.data['className']);
      });
    }
    _class = _listclass[0];
    if (!mounted) return;

    setState(() {
      _posclass = 0;
      _load = true;
    });
  }

  get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runChangeClass();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget runChangeClass() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đổi Lớp"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: _class,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              isExpanded: true,
              style: TextStyle(color: Colors.red, fontSize: 18),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String data) {
                setState(() {
                  _class = data;
                  _posclass = _listclass.indexOf(data);
                });
              },
              items: _listclass.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            RaisedButton(
              onPressed: changeClass,
              child: Text('Đổi lớp'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> changeClass() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        if (_idclass == _listidclass[_posclass]) {
          Navigator.pop(context);
        } else {
          Firestore.instance.runTransaction((transaction) async {
            await transaction.update(
                Firestore.instance.collection('Users').document(user.uid), {
              "idClass": _listidclass[_posclass],
            }).whenComplete(() {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => RootPage()));
            });
          });
        }
      } catch (e) {
        print(e.message);
      }
    }
  }
}
