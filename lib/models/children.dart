import 'package:cloud_firestore/cloud_firestore.dart';

class Children {
  final String name;
  final String fullname;
  final String birth;
  final String placeofbirth;
  final String country;
  final String address;
  final String mother;
  final String sex;
  final String motherjob;
  final String father;
  final String fatherjob;

  Children(
      {this.name,
      this.fullname,
      this.sex,
      this.birth,
      this.placeofbirth,
      this.country,
      this.address,
      this.father,
      this.fatherjob,
      this.mother,
      this.motherjob});

  factory Children.fromDocument(DocumentSnapshot doc) {
    return Children(
        name: doc['name'],
        fullname: doc['fullname'],
        sex: doc['sex'],
        birth: doc['birth'],
        placeofbirth: doc['placeofbirth'],
        country: doc['country'],
        address: doc['address'],
        father: doc['father'],
        fatherjob: doc['fatherjob'],
        mother: doc['motherjob'],
        motherjob: doc['motherjob']);
  }
}
