import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;

  Post(
      {this.description,
     });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
        description: doc['description'],
       );
  }
}
