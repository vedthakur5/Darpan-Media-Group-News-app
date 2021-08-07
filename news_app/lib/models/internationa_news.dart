import 'package:cloud_firestore/cloud_firestore.dart';

class InternationalNewsModel {
  String name;
  String thumbnailUrl;
  String timestamp;

  InternationalNewsModel({
    this.name,
    this.thumbnailUrl,
    this.timestamp
  });


  factory InternationalNewsModel.fromFirestore(DocumentSnapshot snapshot){
    var d = snapshot.data();
    return InternationalNewsModel(
      name: d['name'],
      thumbnailUrl: d['thumbnail'],
      timestamp: d['timestamp'],
    );
  }
}