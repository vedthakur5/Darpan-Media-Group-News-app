import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String name;
  String thumbnailUrl;
  List<dynamic> feedUrl;
  String videoFeedUrl;
  String timestamp;
  bool isInternationalNews;

  Category({
    this.name,
    this.thumbnailUrl,
    this.feedUrl,
    this.videoFeedUrl,
    this.timestamp,
    this.isInternationalNews
  });


  factory Category.fromFirestore(DocumentSnapshot snapshot){
    var d = snapshot.data();
    return Category(
      name: d['name'],
      thumbnailUrl: d['thumbnail'],
      feedUrl: d['feed'],
      videoFeedUrl: d['video'],
      timestamp: d['timestamp'],
      isInternationalNews: d['isInternationalNews'],
    );
  }
}