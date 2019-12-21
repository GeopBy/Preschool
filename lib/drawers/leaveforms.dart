import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/models/children.dart';
import 'package:preschool/models/leaveform.dart';
import 'package:preschool/models/timetable.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class LeaveForms extends StatefulWidget {
  @override
  _LeaveFormsState createState() => _LeaveFormsState();
}

class _LeaveFormsState extends State<LeaveForms>
    with AutomaticKeepAliveClientMixin<LeaveForms> {
  @override
  CalendarController _controller;
  String parent, children;
  FirebaseUser user;
  String _idclass;
  bool _load = false;
  bool _view = false;
  bool _viewButton = false;
  String _dayChoose;
  String pos;
  List<String> _class = List<String>();
  List<Children> _childrens = List<Children>();
  List<LeaveForm> _leaveforms = List<LeaveForm>();
  void initState() {
    getInfo();
    _controller = CalendarController();
    super.initState();
  }

  Future<void> getInfo() async {
    user = await FirebaseAuth.instance.currentUser();
    //tim id class
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      _idclass = ds.data['idClass'];
      _class = List.from(ds.data['myClass']);
      if (ds.data['role'] == 'teacher')
        _viewButton = true;
      else
        parent = ds.data['fullname'];
    });
    if (_viewButton == false) {
      await Firestore.instance
          .collection('Users')
          .document(user.uid)
          .collection('myChildren')
          .getDocuments()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.documents.forEach((f) {
          _childrens.add(Children.fromDocument(f));
        });
      });
      //tim children hien tai
      for (int i = 0; i < _class.length; i++) {
        if (_idclass == _class[i]) {
          children = _childrens[i].fullname;
        }
      }
    }
    setState(() {
      _dayChoose = DateTime.now().day.toString() +
          DateTime.now().month.toString() +
          DateTime.now().year.toString();
      loadLeaveForm(_dayChoose);
      _load = true;
      _view = true;
    });
  }

  Future<void> loadLeaveForm(String day) async {
    //neu la phu huynh
    _leaveforms.clear();
    if (_viewButton == false) {
      await Firestore.instance
          .collection('Class')
          .document(_idclass)
          .collection('LeaveForm')
          .orderBy('pos', descending: true)
          .getDocuments()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.documents.forEach((f) {
          if (f.exists) {
            if (f.data['uid'] == user.uid && f.data['day'] == day)
              _leaveforms.add(LeaveForm.fromDocument(f));
          }
        });
      });
    } else {
      //neu la giao vien
      await Firestore.instance
          .collection('Class')
          .document(_idclass)
          .collection('LeaveForm')
          .orderBy('pos', descending: true)
          .getDocuments()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.documents.forEach((f) {
          if (f.exists) {
            if (f.data['day'] == day)
              _leaveforms.add(LeaveForm.fromDocument(f));
          }
        });
      });
    }
    if (!mounted) return;
    setState(() {
      _view = true;
    });
  }

  Future<void> addLeaveForm(String day, String parent, String children,
      String reason, String pos, String numberofday, String uid) async {
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('LeaveForm')
        .add({
      'day': day,
      'parent': parent,
      'children': children,
      'pos': pos,
      'reason': reason,
      'numberofday': numberofday,
      'uid': uid
    });
  }

  get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runEvent();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget runEvent() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainScreen())),
        ),
        title: Text('Đơn nghỉ phép'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            //  crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TableCalendar(
                initialCalendarFormat: CalendarFormat.week,
                calendarStyle: CalendarStyle(
                    canEventMarkersOverflow: true,
                    todayColor: Colors.orange,
                    selectedColor: Theme.of(context).primaryColor,
                    todayStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white)),
                headerStyle: HeaderStyle(
                  centerHeaderTitle: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                  formatButtonShowsNext: false,
                ),
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: (time, events) {
                  pos = time.millisecondsSinceEpoch.toString();
                  _dayChoose = (time.day.toString() +
                      time.month.toString() +
                      time.year.toString());
                  loadLeaveForm(_dayChoose);
                },
                builders: CalendarBuilders(
                  selectedDayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.white),
                      )),
                  todayDayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                calendarController: _controller,
              ),
              if (_view == true)
                //if()
                for (int i = 0; i < _leaveforms.length; i++)
                  // Text(_leaveforms[i].children +
                  //     ' - ' +
                  //     _leaveforms[i].reason +
                  //     ' - ' +
                  //     _leaveforms[i].numberofday)
                  Container(
                    margin: const EdgeInsets.only(
                        top: 20.0, left: 20.0, right: 20.0),
                    width: 400.0,
                 //   height: 130.0,
                    //decoration: BorderRadius.all(8),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent)),
                    //  color: Colors.blue,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Visibility(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          Icons.people,
                                          color: Colors.cyan,
                                          size: 30.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, top: 6.0),
                                          child: Text(
                                              'Phụ huynh:   ' +
                                                  _leaveforms[i].parent,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  visible: _viewButton,
                                ),
                                Visibility(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        //    padding: const EdgeInsets.only(right:120.0),
                                        Icon(
                                          Icons.child_care,
                                          color: Colors.cyan,
                                          size: 30.0,
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, top: 6.0),
                                          child: Text(
                                              'Tên bé       :   ' +
                                                  _leaveforms[i].children,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  visible: _viewButton,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      //    padding: const EdgeInsets.only(right:120.0),
                                      Icon(
                                        Icons.pages,
                                        color: Colors.cyan,
                                        size: 30.0,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, top: 6.0),
                                        child: Text(
                                            'Lí do          :   ' +
                                                _leaveforms[i].reason,
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 18)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      //    padding: const EdgeInsets.only(right:120.0),
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.cyan,
                                        size: 30.0,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, top: 6.0, bottom: 5.0),
                                        child: Text(
                                            'Số ngày     :   ' +
                                                _leaveforms[i].numberofday,
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 18)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
              else
                Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _showAddDialog,
        ),
        visible: !_viewButton,
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  String reason;
  String numberofday;
  _showAddDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Form(
                key: _formKey,
                child: Container(
                  width: 300.0,
                  height: 500.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Vui lòng nhập dữ liệu ';
                            }
                          },
                          onSaved: (input) => reason = input,
                          decoration:
                              InputDecoration(labelText: 'Nhập lí do nghỉ:'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Vui lòng nhập dữ liệu ';
                            }
                          },
                          onSaved: (input) => numberofday = input,
                          decoration:
                              InputDecoration(labelText: 'Nhập số ngày nghỉ:'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("OK"),
                          onPressed: () {
                            //firebase
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              addLeaveForm(_dayChoose, parent, children, reason,
                                  pos, numberofday, user.uid);
                              Navigator.pop(context);
                              loadLeaveForm(_dayChoose);
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
