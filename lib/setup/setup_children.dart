import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/screens/main_screen.dart';

class SetupChildrenPage extends StatefulWidget {
  @override
  const SetupChildrenPage({this.onSignedOut});
  final VoidCallback onSignedOut;
  _SetupChildrenPageState createState() => _SetupChildrenPageState();
}

class _SetupChildrenPageState extends State<SetupChildrenPage>
    with AutomaticKeepAliveClientMixin<SetupChildrenPage> {
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
  List<String> _nameclass = List<String>();
  String _class = '';
  FirebaseUser user;
  bool _load = false;
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

  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runChildren(context);
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  //lấy id lớp của user hiện tại
  Future<void> _getInfo() async {
    user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      _myclass = List.from(ds.data['myClass']);
    });
    for (int i = 0; i < _myclass.length; i++) {
      await Firestore.instance
          .collection('Class')
          .document(_myclass[i])
          .get()
          .then((DocumentSnapshot ds) {
        _nameclass.add(ds.data['className']);
      });
    }
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .collection('myChildren')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => {_mychildren.add(f.documentID)});
    });
    _class = _nameclass[_mychildren.length];
    setState(() {
      _load = true;
    });
  }

  Future setupUser() async {
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
      await Firestore.instance
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
      }).whenComplete(() {
        _add = _add + 1;
        print('nhap be thu' + _add.toString());
        print('so be la  ' + _myclass.length.toString());
        if (_add < _myclass.length) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SetupChildrenPage(onSignedOut: widget.onSignedOut)));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MainScreen(onSignedOut: widget.onSignedOut)));
        }
      }).catchError((e) => print(e));
    }
  }

  @override
  Widget runChildren(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Thiết lập thông tin cho bé lớp: ' + _class),
      ),
      body: Builder(
        builder: (context) => Container(
          child: new SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _fullnameController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.face,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Họ và tên trẻ'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.local_laundry_service,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Tên thường dùng'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _birthController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.cake,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Ngày sinh'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _placeofbirthController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.location_city,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Nơi sinh'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _sexController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.wc,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Giới tính'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.home,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Địa chỉ'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _countryController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.star,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Quốc tịch'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _fatherController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.perm_identity,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Họ và tên cha'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _fatherjobController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.shop,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Nghề nghiệp của cha'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _motherController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.person_pin,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Họ và tên mẹ'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _motherjobController,
                            decoration: InputDecoration(
                                enabledBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey[700])),
                                prefixIcon: Icon(
                                  Icons.shopping_basket,
                                  color: Colors.cyan,
                                ),
                                hintStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                                hintText: 'Nghề nghiệp của mẹ'),
                          ),
                        ),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 250,
                        height: 70,
                        padding: EdgeInsets.only(top: 20),
                        child: RaisedButton(
                          color: Colors.lightBlue[300],
                          child: Text(
                            "Lưu",
                            style: TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30),
                          ),
                          onPressed: () {
                            setupUser();
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
