import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/models/timetable.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class TimeTables extends StatefulWidget {
  @override
  _TimeTablesState createState() => _TimeTablesState();
}

class _TimeTablesState extends State<TimeTables>
    with AutomaticKeepAliveClientMixin<TimeTables> {
  @override
  CalendarController _controller;

  FirebaseUser user;
  String _idclass;
  String hours, min, iam;
  bool _load = false;
  bool _view = false;
  bool _viewButton = false;
  String _dayChoose;
  List<TimeTable> _list = List<TimeTable>();
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
      if (ds.data['role'] == 'teacher') _viewButton = true;
    });
    if (!mounted) return;

    setState(() {
      _dayChoose = DateTime.now().day.toString() +
          DateTime.now().month.toString() +
          DateTime.now().year.toString();
      loadTimeTable(_dayChoose);
      _load = true;
      _view = true;
    });
  }

  Future<void> loadTimeTable(String day) async {
    _list.clear();
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('TimeTable')
        .document(day)
        .collection('Schedule')
        .orderBy('pos', descending: false)
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((f) {
        if (f.exists) _list.add(TimeTable.fromDocument(f));
      });
    });
    if (!mounted) return;
    setState(() {
      _view = true;
    });
  }

  Future<void> addTimeTable(
      String time, String name, String start, String end, String pos) async {
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('TimeTable')
        .document(time)
        .collection('Schedule')
        .add({'name': name, 'start': start, 'end': end, 'pos': pos});
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
        title: Text('Thời khóa biểu'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                _dayChoose = (time.day.toString() +
                    time.month.toString() +
                    time.year.toString());
                loadTimeTable(_dayChoose);
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
              for (int i = 0; i < _list.length; i++)
                //     Text(
                //         _list[i].start + ' - ' + _list[i].end + ' : ' + _list[i].name)
                Container(
                  margin:
                      const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  width: 400.0,
                  //   height: 130.0,
                  //decoration: BorderRadius.all(8),
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.blueAccent)),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.cyan,
                                        size: 30.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, top: 6.0),
                                        child: Text(
                                            _list[i].start +
                                                '  -  ' +
                                                _list[i].end +
                                                '  :   ' +
                                                _list[i].name,
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                ),
                                //  visible: _viewButton,
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
      floatingActionButton: Visibility(
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _showAddDialog,
        ),
        visible: _viewButton,
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  String name;
  String start;
  String end;
  String pos;
  _showAddDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  width: 300.0,
                  height: 500.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          onSaved: (input) => name = input,
                          decoration:
                              InputDecoration(labelText: 'Nhập tên môn học:'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('BẮT ĐẦU'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TimePickerSpinner(
                          is24HourMode: false,
                          normalTextStyle:
                              TextStyle(fontSize: 14, color: Colors.orange),
                          highlightedTextStyle:
                              TextStyle(fontSize: 14, color: Colors.blue),
                          spacing: 20,
                          itemHeight: 30,
                          isForce2Digits: true,
                          onTimeChange: (time) {
                            setState(() {
                              pos = time.millisecondsSinceEpoch.toString();
                              if (time.hour < 10) {
                                hours = '0' + time.hour.toString();
                              } else {
                                hours = time.hour.toString();
                              }
                              if (time.minute < 10)
                                min = '0' + time.minute.toString();
                              else
                                min = time.minute.toString();
                              start = hours + ' : ' + min;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('KẾT THÚC'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TimePickerSpinner(
                          is24HourMode: false,
                          normalTextStyle:
                              TextStyle(fontSize: 14, color: Colors.orange),
                          highlightedTextStyle:
                              TextStyle(fontSize: 14, color: Colors.blue),
                          spacing: 20,
                          itemHeight: 30,
                          isForce2Digits: true,
                          onTimeChange: (time) {
                            setState(() {
                              if (time.hour < 10) {
                                hours = '0' + time.hour.toString();
                              } else {
                                hours = time.hour.toString();
                              }
                              if (time.minute < 10)
                                min = '0' + time.minute.toString();
                              else
                                min = time.minute.toString();
                              end = hours + ' : ' + min;
                            });
                          },
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
                              addTimeTable(_dayChoose, name, start, end, pos);
                              Navigator.pop(context);
                              loadTimeTable(_dayChoose);
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }
}
