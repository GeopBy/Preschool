import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/screens/main_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with AutomaticKeepAliveClientMixin<Menu> {
  @override
  CalendarController _controller;

  FirebaseUser user;
  String _idclass;
  bool _load = false;
  bool _view = false;
  String _dayChoose;
  List<String> _menu = List<String>();
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
    });
    if (!mounted) return;

    setState(() {
      _dayChoose = DateTime.now().day.toString() +
          DateTime.now().month.toString() +
          DateTime.now().year.toString();
      loadMenu(_dayChoose);
      _load = true;
      _view = true;
    });
  }

  Future<void> loadMenu(String day) async {
    //tim id class
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('Menu')
        .document(day)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.exists) {
        if (ds.data['sang'] != null) _menu.add(ds.data['sang']);
        if (ds.data['trua'] != null) _menu.add(ds.data['trua']);
        if (ds.data['chieu'] != null) _menu.add(ds.data['chieu']);
      }
    });
    if (!mounted) return;

    setState(() {
      _view = true;
    });
  }

  Future<void> addMenu(
      String time, String sang, String trua, String chieu) async {
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('Menu')
        .document(time)
        .setData({'sang': sang, 'trua': trua, 'chieu': chieu});
  }

  get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runMenu();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget runMenu() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainScreen())),
        ),
        title: Text('Thực đơn'),
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
                _menu.clear();
                loadMenu(_dayChoose);
              },
              builders: CalendarBuilders(
                selectedDayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.blue),
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
              Text(_menu.toString())
            else
              Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  String _buoisang;
  String _buoitrua;
  String _buoixe;
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
                          onSaved: (input) => _buoisang = input,
                          decoration: InputDecoration(labelText: 'BUỔI SÁNG'),
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
                          onSaved: (input) => _buoitrua = input,
                          decoration: InputDecoration(labelText: 'BUỔI TRƯA'),
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
                          onSaved: (input) => _buoixe = input,
                          decoration: InputDecoration(labelText: 'BUỔI XẾ'),
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
                              addMenu(
                                  _dayChoose, _buoisang, _buoitrua, _buoixe);
                              Navigator.pop(context);
                              loadMenu(_dayChoose);
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
