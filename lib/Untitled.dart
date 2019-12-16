// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';

// class Menu extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _MenuState();
//   }

// class _MenuState extends State<Menu> {
//   CalendarController _controller;
 

//   @override
//   void initState() {
//     super.initState();
//     _controller = CalendarController();
    
//   } 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Thực đơn'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             TableCalendar(
            
//               initialCalendarFormat: CalendarFormat.week,
//               calendarStyle: CalendarStyle(
//                   canEventMarkersOverflow: true,
//                   todayColor: Colors.orange,
//                   selectedColor: Theme.of(context).primaryColor,
//                   todayStyle: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18.0,
//                       color: Colors.white)),
//               headerStyle: HeaderStyle(
//                 centerHeaderTitle: true,
//                 formatButtonDecoration: BoxDecoration(
//                   color: Colors.orange,
//                   borderRadius: BorderRadius.circular(20.0),
//                 ),
//                 formatButtonTextStyle: TextStyle(color: Colors.white),
//                 formatButtonShowsNext: false,
//               ),
//               startingDayOfWeek: StartingDayOfWeek.monday,

//               builders: CalendarBuilders(
//                 selectedDayBuilder: (context, date, events) => Container(
//                     margin: const EdgeInsets.all(4.0),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                         color: Theme.of(context).primaryColor,
//                         borderRadius: BorderRadius.circular(10.0)),
//                     child: Text(
//                       date.day.toString(),
//                       style: TextStyle(color: Colors.blue),
//                     )),
//                 todayDayBuilder: (context, date, events) => Container(
//                     margin: const EdgeInsets.all(4.0),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                         color: Colors.orange,
//                         borderRadius: BorderRadius.circular(10.0)),
//                     child: Text(
//                       date.day.toString(),
//                       style: TextStyle(color: Colors.white),
//                     )),
//               ),
//               calendarController: _controller,
//             ),
            
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: _showAddDialog,
//       ),
//     );
//   }

//   final _formKey = GlobalKey<FormState>();
//   String _buoisang;
//   String _buoitrua;
//   String _buoixe;
//   _showAddDialog() {
//     showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//               content: Form(
//                 key: _formKey,
//                 child: Container(
//                   width: 300.0,
//                   height: 500.0,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.max,
//                     children: <Widget>[
//                       Padding(
//                         padding: EdgeInsets.only(top: 8.0),
//                         child: TextFormField(
//                           validator: (input) {
//                             if (input.isEmpty) {
//                               return 'Vui lòng nhập dữ liệu ';
//                             }
//                           },
//                           onSaved: (input) => _buoisang = input,
//                           decoration: InputDecoration(labelText: 'BUỔI SÁNG'),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(top: 8.0),
//                         child: TextFormField(
//                           validator: (input) {
//                             if (input.isEmpty) {
//                               return 'Vui lòng nhập dữ liệu ';
//                             }
//                           },
//                           onSaved: (input) => _buoitrua = input,
//                           decoration: InputDecoration(labelText: 'BUỔI TRƯA'),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(top: 8.0),
//                         child: TextFormField(
//                           validator: (input) {
//                             if (input.isEmpty) {
//                               return 'Vui lòng nhập dữ liệu ';
//                             }
//                           },
//                           onSaved: (input) => _buoixe = input,
//                           decoration: InputDecoration(labelText: 'BUỔI XẾ'),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: RaisedButton(
//                           child: Text("OK"),
//                           onPressed: () {//firebase
//                             if (_formKey.currentState.validate()) {
//                               _formKey.currentState.save();
//                             }
//                           },
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ));
//   }
// }
