import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:preschool/setup/home_demo.dart';

class SetupChildrenPage extends StatefulWidget {
  @override
  final FirebaseUser user;
  SetupChildrenPage({Key key, this.user}) : super(key: key);
  _SetupChildrenPageState createState() => _SetupChildrenPageState(user);
}

class _SetupChildrenPageState extends State<SetupChildrenPage> {
  FirebaseUser user;
  _SetupChildrenPageState(this.user);
  String _fullname,
      _name,
      _birth,
      _placeofbirth,
      _sex,
      _country,
      _address,
      _father,
      _fatherjob,
      _mother,
      _motherjob;
  final _fullnameController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _placeofbirthController = TextEditingController();
  final _sexController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _fatherController = TextEditingController();
  final _fatherjobController = TextEditingController();
  final _motherController = TextEditingController();
  final _motherjobController = TextEditingController();

  List<String> _myclass = List<String>();
  List<String> _mychildren = List<String>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _fullnameController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _placeofbirthController.dispose();
    _sexController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _fatherController.dispose();
    _fatherjobController.dispose();
    _motherController.dispose();
    _motherjobController.dispose();
    super.dispose();
  }

  void initState() {
    _getInfo();
    super.initState();
  }

  //lấy id lớp của user hiện tại
  Future<void> _getInfo() async {
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      _myclass = List.from(ds.data['myClass']);
    });
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .collection('myChildren')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => {_mychildren.add(f.documentID)});
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Future setupUser(BuildContext context) async {
      _fullname = _fullnameController.text;
      _name = _nameController.text;
      _birth = _birthController.text;
      _placeofbirth = _placeofbirthController.text;
      _sex = _sexController.text;
      _country = _countryController.text;
      _address = _addressController.text;
      _father = _fatherController.text;
      _fatherjob = _fatherjobController.text;
      _mother = _motherController.text;
      _motherjob = _motherjobController.text;
      // thêm trẻ vào lớp
      if (_mychildren.length < _myclass.length) {
        int _add = _mychildren.length;
        DocumentReference _ref = await Firestore.instance
            .collection('Class')
            .document(_myclass[_add])
            .collection('Childrens')
            .add({
          'fullname': _fullname,
          'name': _name,
          'birth': _birth,
          'placeofbirth': _placeofbirth,
          'sex': _sex,
          'country': _country,
          'address': _address,
          'father': _father,
          'fatherjob': _fatherjob,
          'mother': _mother,
          'motherjob': _motherjob,
        });
        //thêm trẻ vào parent
        String _id = _ref.documentID;
        Firestore.instance
            .collection('Users')
            .document(user.uid)
            .collection('myChildren')
            .document(_id)
            .setData({
          'fullname': _fullname,
          'name': _name,
          'birth': _birth,
          'placeofbirth': _placeofbirth,
          'sex': _sex,
          'country': _country,
          'address': _address,
          'father': _father,
          'fatherjob': _fatherjob,
          'mother': _mother,
          'motherjob': _motherjob,
        });
        _add = _add + 1;
        if (_add < _myclass.length) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SetupChildrenPage(user: user)));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(user: user)));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text('Thiết lập thông tin cho bé'),
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
                      Expanded(
                        child: TextField(
                          controller: _fullnameController,
                          decoration:
                              InputDecoration(hintText: 'Họ và tên trẻ'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration:
                              InputDecoration(hintText: 'Tên thường dùng'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _birthController,
                          decoration: InputDecoration(hintText: 'Ngày sinh'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _placeofbirthController,
                          decoration: InputDecoration(hintText: 'Nơi sinh'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _sexController,
                          decoration: InputDecoration(hintText: 'Giới tính'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _addressController,
                          decoration: InputDecoration(hintText: 'Địa chỉ'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _countryController,
                          decoration: InputDecoration(hintText: 'Quốc tịch'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _fatherController,
                          decoration:
                              InputDecoration(hintText: 'Họ và tên cha'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _fatherjobController,
                          decoration:
                              InputDecoration(hintText: 'Nghề nghiệp của cha'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _motherController,
                          decoration: InputDecoration(hintText: 'Họ và tên mẹ'),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _motherjobController,
                          decoration:
                              InputDecoration(hintText: 'Nghề nghiệp của mẹ'),
                        ),
                      ),
                    ]),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Color(0xff476cfb),
                      onPressed: () {
                        setupUser(context);
                      },
                      elevation: 4.0,
                      splashColor: Colors.blueGrey,
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
