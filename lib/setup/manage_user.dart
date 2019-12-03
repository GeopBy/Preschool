import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManageUserPage extends StatefulWidget {
  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  @override
  String _email, _password, _role;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _listrole = List<String>();
  List<String> _listidclass = List<String>();
  List<String> _listclass = List<String>();
  List<bool> _inputs = List<bool>();
  void initState() {
    _getInfo();
    super.initState();
  }

  Future<void> _getInfo() async {
    await Firestore.instance
        .collection('Class')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => {
            _listclass.add(f.data['className']),
            _listidclass.add(f.documentID),
            _inputs.add(false)
          });
    });
    _role = 'Quyền';
    _listrole = ['Quyền', 'teacher', 'parent'];
    setState(() {});
  }

  void ItemChange(bool val, int index) {
    setState(() {
      _inputs[index] = val;
    });
    print(_inputs);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage User"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: (input) {
                if (input.isEmpty) {
                  return 'Vui lòng nhập email ';
                }
              },
              onSaved: (input) => _email = input,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              validator: (input) {
                if (input.isEmpty) {
                  return 'Vui lòng nhập mật khẩu ';
                }
              },
              onSaved: (input) => _password = input,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: _role,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              isExpanded: true,
              style: TextStyle(color: Colors.red, fontSize: 18),
              underline: Container(
                height: 1,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String data) {
                setState(() {
                  _role = data;
                });
              },
              items: _listrole.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            new Expanded(
              child: ListView.builder(
                  itemCount: _inputs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new Card(
                      child: new Container(
                        padding: new EdgeInsets.all(0.0),
                        child: new Column(
                          children: <Widget>[
                            new CheckboxListTile(
                                value: _inputs[index],
                                title: new Text(_listclass[index]),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (bool val) {
                                  ItemChange(val, index);
                                })
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            RaisedButton(
              onPressed: createUser,
              child: Text('Tạo User'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> createUser() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      try {
        List<String> _class = List<String>();
        for (int i = 0; i < _listidclass.length; i++) {
          if (_inputs[i] == true) {
            _class.add(_listidclass[i]);
          }
        }
        FirebaseUser user = (await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: _email, password: _password))
            .user;
        if (_role == 'teacher') {
          Firestore.instance.runTransaction((transaction) async {
            await transaction.update(
                Firestore.instance.collection('Class').document(_class[0]), {
              'teacher': user.uid,
            });
          });
        } else {
          for (int i = 0; i < _class.length; i++) {
            //lấy list parent
            List<String> _parents = List<String>();
            await Firestore.instance
                .collection('Class')
                .document(_class[i])
                .get()
                .then((DocumentSnapshot ds) {
              if (ds.data['Parents'] != null) {
                _parents = List.from(ds.data['Parents']);
              }
            });
            _parents.add(user.uid);
            //thêm parent vào class
            Firestore.instance.runTransaction((transaction) async {
              await transaction.update(
                  Firestore.instance.collection('Class').document(_class[i]),
                  {'Parents': _parents});
            });
          }
        }
        Firestore.instance
            .collection('Users')
            .document(user.uid)
            .setData({
              "id": user.uid,
              "email": _email,
              "role": _role,
              "myClass": _class,
              "idClass": _class[0]
            })
            .then((result) => {_formKey.currentState.reset()})
            .catchError((err) => print(err));
      } catch (e) {
        print(e.message);
      }
    }
  }
}
