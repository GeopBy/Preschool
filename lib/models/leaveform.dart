import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveForm {
  final String children;
  final String parent;
  final String reason;
  final String numberofday;
  final String pos;
  final String uid;
  final String day;

  LeaveForm(
      {this.children,
      this.parent,
      this.reason,
      this.numberofday,
      this.pos,
      this.uid,
      this.day});

  factory LeaveForm.fromDocument(DocumentSnapshot doc) {
    return LeaveForm(
        children: doc['children'],
        parent: doc['parent'],
        reason: doc['reason'],
        numberofday: doc['numberofday'],
        pos: doc['pos'],
        uid: doc['uid'],
        day: doc['day']);
  }
}
