import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class Event extends StatefulWidget {
  @override
  _EventState createState() => _EventState();
}

class _EventState extends State<Event>
    with AutomaticKeepAliveClientMixin<Event> {
  @override
  CalendarController _controller;

  FirebaseUser user;
  static String _name, _place, _start, _end;
  String _idclass;
  String hours, min, iam;
  bool _load = false;
  bool _view = false;
  bool _viewButton = false;
  String _dayChoose;
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
      loadEvent(_dayChoose);
      _load = true;
      _view = true;
    });
  }

  Future<void> loadEvent(String day) async {
    //tim id class
    _name = '';
    _place = '';
    _start = '';
    _end = '';
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('Event')
        .document(day)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.exists) {
        if (ds.data['name'] != null) _name = (ds.data['name']);
        if (ds.data['place'] != null) _place = (ds.data['place']);
        if (ds.data['start'] != null) _start = (ds.data['start']);
        if (ds.data['end'] != null) _end = (ds.data['end']);
      }
    });
    if (!mounted) return;

    setState(() {
      _view = true;
    });
  }

  Future<void> addEvent(
      String time, String name, String place, String start, String end) async {
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('Event')
        .document(time)
        .setData({'name': name, 'place': place, 'start': start, 'end': end});
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
        title: Text('Sự kiện'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                loadEvent(_dayChoose);
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
              Container(
                margin: const EdgeInsets.only(top: 20, left: 20.0, right: 20.0),
                width: 400.0,
                height: 400.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 400.0,
                      height: 50.0,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Image.asset(
                              'assets/iconevent.png',
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                child: Text(
                                  'Tên sự kiện: ',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, left: 30.0),
                                child: Text(_name,
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 400.0,
                      height: 50.0,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              top: 10.0,
                            ),
                            child: Image.asset(
                              'assets/iconhome.png',
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                child: Text(
                                  'Địa điểm tổ chức: ',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, left: 30.0),
                                child: Text(_place,
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 400.0,
                      height: 50.0,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              top: 10.0,
                            ),
                            child: Image.asset(
                              'assets/iconstart.png',
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                child: Text(
                                  'Thời gian bắt đầu: ',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, left: 30.0),
                                child: Text(_start,
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 400.0,
                      height: 50.0,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              top: 10.0,
                            ),
                            child: Image.asset(
                              'assets/iconend.png',
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                child: Text(
                                  'Thời gian kết thúc: ',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, left: 30.0),
                                child: Text(_end,
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          )
                        ],
                      ),
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
  String place;
  String start;
  String end;
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
                          onSaved: (input) => _name = input,
                          decoration:
                              InputDecoration(labelText: 'Nhập tên sự kiện:'),
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
                          onSaved: (input) => _place = input,
                          decoration: InputDecoration(labelText: 'Địa điểm'),
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
                              TextStyle(fontSize: 14, color: Colors.deepOrange),
                          highlightedTextStyle:
                              TextStyle(fontSize: 14, color: Colors.yellow),
                          spacing: 20,
                          itemHeight: 30,
                          isForce2Digits: true,
                          onTimeChange: (time) {
                            setState(() {
                              hours = time.hour.toString();
                              min = time.minute.toString();
                              start = hours+' : '+min;
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
                              hours = time.hour.toString();
                              min = time.minute.toString();
                              end = hours+' : '+min;
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
                              addEvent(
                                  _dayChoose, name, place, start,end);
                              Navigator.pop(context);
                              loadEvent(_dayChoose);
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
