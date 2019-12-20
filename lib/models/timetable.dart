import 'package:cloud_firestore/cloud_firestore.dart';

class TimeTable {
  final String name;
  final String start;
  final String end;
  final String pos;

  TimeTable({this.name, this.start, this.end, this.pos});

  factory TimeTable.fromDocument(DocumentSnapshot doc) {
    return TimeTable(
        name: doc['name'],
        start: doc['start'],
        end: doc['end'],
        pos: doc['pos']);
  }
}
