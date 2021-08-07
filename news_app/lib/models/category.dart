import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String name;
  String thumbnailUrl;
  List<dynamic> feedUrl;
  String videoFeedUrl;
  String timestamp;
  bool isInternationalNews;

  CategoryModel({
    this.name,
    this.thumbnailUrl,
    this.feedUrl,
    this.videoFeedUrl,
    this.timestamp,
    this.isInternationalNews
  });


  factory CategoryModel.fromFirestore(DocumentSnapshot snapshot){
    var d = snapshot.data();
    return CategoryModel(
      name: d['name'],
      thumbnailUrl: d['thumbnail'],
      feedUrl: d['feed'],
      videoFeedUrl: d['video'],
      timestamp: d['timestamp'],
      isInternationalNews: d['isInternationalNews'],
    );
  }
}