import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManageClassPage extends StatefulWidget {
  @override
  _ManageClassPageState createState() => _ManageClassPageState();
}

class _ManageClassPageState extends State<ManageClassPage> {
  @override
  String _classname, _room, _teacher, _year, _idteacher;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _posteacher,_posyear;
  List <String> _listteacher= List<String>();
  List <String> _listyear= List<String>();
  List <String> _listidteacher= List<String>();
  void initState(){
    _year='Niên khóa';
    _listyear.add(_year);
    for(int i=2019;i<2026;i++){
      _listyear.add(i.toString()+"-"+(i+1).toString());
    }
    _teacher= 'Giáo viên';
    _listteacher.add(_teacher);
    _listidteacher=['id'];   
    Firestore.instance.collection('Users').getDocuments()
    .then((QuerySnapshot snapshot){
      snapshot.documents.forEach((f) => {
        if(f.data['role']=='teacher'){
          _listteacher.add(f.data['email']),
          _listidteacher.add(f.documentID)
        }
      });      
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Class"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: (input){
                if(input.isEmpty){
                  return 'Vui lòng nhập tên lớp ';
                }
              },
              onSaved: (input) => _classname = input,
              decoration: InputDecoration(
                labelText: 'Tên lớp'
              ),
            ),
            TextFormField(
              validator:(input){
                if(input.isEmpty){
                  return 'Vui lòng nhập phòng học';
                }
              },
              onSaved: (input) => _room = input,
              decoration: InputDecoration(
                labelText: 'Phòng học'
              ),
            ),
            // DropdownButton<String>(
            //   value: _teacher,
            //   icon: Icon(Icons.arrow_drop_down),
            //   iconSize: 24,
            //   elevation: 16,
            //   isExpanded: true,
            //   style: TextStyle(color: Colors.red, fontSize: 18),
            //   underline: Container(
            //     height: 2,
            //     color: Colors.deepPurpleAccent,
            //   ),
            //   onChanged: (String data) {
            //     setState(() {
            //       _teacher = data;
            //       _posteacher=_listteacher.indexOf(data);
            //     });
            //   },
            //   items: _listteacher.map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            // ),
            // Text('Selected Item = '+'$_posteacher'+'$_listidteacher', 
            //   style: TextStyle
            //   (fontSize: 22, 
            //   color: Colors.black)),
            DropdownButton<String>(
              value: _year,
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
                  _year = data;
                  _posyear=_listyear.indexOf(data);
                });
              },
              items: _listyear.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            RaisedButton(
              onPressed: createClass,
              child: Text('Tạo lớp'),
            )
          ],
        ),
      ),
    );
  }
  Future<void> createClass() async{
    final formState = _formKey.currentState;
    if(formState.validate()){
      formState.save();
      try{
        Firestore.instance
        .collection('Class')
        .document()
        .setData({
          "className":_classname,
          // "teacher":_listidteacher[_posteacher],
          "room": _room,
          "year": _listyear[_posyear]
        }).then((result)=>{
          _formKey.currentState.reset()
        })
        .catchError((err)=>print(err));
      }catch(e){
        print(e.message);
      }
    }
  }
}