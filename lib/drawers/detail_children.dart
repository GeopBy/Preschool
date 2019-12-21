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
          title: Text(_children.name),
        ),
      body:  new Container(
      color: Colors.white,
      child: new ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              new Container(
                color: Color(0xffFFFFFF),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: 100,
                                  child: new Text(
                                    'Họ và tên bé:',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    'Ngày sinh:',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                             Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 8.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: 100,
                                  child: new Text(
                                    _children.fullname,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    _children.birth,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                            
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: 100,
                                  child: new Text(
                                    'Giới tính:',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    'Quốc tịch:',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                             Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 8.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: 100,
                                  child: new Text(
                                    _children.sex,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    _children.country,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                           Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: 100,
                                  child: new Text(
                                    'Họ và tên bố',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    'Nghề nghiệp',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                             Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 8.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: 100,
                                  child: new Text(
                                    _children.father,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    _children.fatherjob,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                          Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: 100,
                                  child: new Text(
                                    'Họ và tên mẹ',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    'Nghề nghiệp',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                             Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 8.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  width: 100,
                                  child: new Text(
                                    _children.mother,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    _children.motherjob,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                      
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
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
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                               new Flexible(
                                child: new Text(
                                 
                                 _children.address,style: TextStyle(
                                  //  decoration: TextDecoration.underline,
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),

                                ),
                              ),
                            ],
                          )),
                       Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    'Nơi sinh',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                               new Flexible(
                                child: new Text(
                                 
                                 _children.placeofbirth,style: TextStyle(
                                  //  decoration: TextDecoration.underline,
                                        fontSize: 16.0,
                                        color: Colors.lightGreen[700]),

                                ),
                              ),
                            ],
                          )),
                      
                  //    !_status ? _getActionButtons() : new Container(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),


    ));}
        
         
      
         
}
