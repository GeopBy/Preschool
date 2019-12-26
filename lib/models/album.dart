import 'package:cloud_firestore/cloud_firestore.dart';

class Album {
  final String name;
  final String date;
  final List<String> image;
  final String pos;
  final String id;

  Album({this.name, this.date, this.image, this.pos, this.id});

  factory Album.fromDocument(DocumentSnapshot doc) {
    return Album(
        name: doc['name'],
        date: doc['date'],
        image: List.from(doc['image']),
        pos: doc['pos'],
        id: doc['id']);
  }
}
