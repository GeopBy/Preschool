import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String fullname;
  final String profileimage;
  final String address;

  User(
      {this.id,
      this.username,
      this.email,
      this.fullname,
      this.profileimage,
      this.address});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        username: doc['username'],
        email: doc['email'],
        fullname: doc['fullname'],
        profileimage: doc['profileimage'],
        address: doc['address']);
  }
}
