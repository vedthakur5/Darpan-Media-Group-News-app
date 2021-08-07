import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';

class RecentBloc extends ChangeNotifier{
  
  List<Article> _data = [];
  List<Article> get data => _data;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _snap = new List<DocumentSnapshot>();

  DocumentSnapshot _lastVisible;
  DocumentSnapshot get lastVisible => _lastVisible;

  List categoryList  = [];
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<List> _getCategoryList ()async{
    final DocumentReference ref = firestore.collection('recent_categories').doc('recent_list');
    DocumentSnapshot snap = await ref.get();
    categoryList = snap['category'] ?? [];
    return categoryList;
  }

  Future<Null> getData(mounted) async {
    QuerySnapshot rawData;
    _getCategoryList().then((categoryList)async {
      if(categoryList.isEmpty){
        if (_lastVisible == null){
          rawData = await firestore
              .collection('contents')
              .orderBy('timestamp', descending: true)
              .limit(4)
              .get();}
        else{
          rawData = await firestore
              .collection('contents')
              .orderBy('timestamp', descending: true)
              .startAfter([_lastVisible['timestamp']])
              .limit(4)
              .get();
      }
      }else{
        if (_lastVisible == null){
          rawData = await firestore
              .collection('contents')
              .where('category', whereIn: categoryList )
              .orderBy('timestamp', descending: true)
              .limit(4)
              .get();}
        else{
          rawData = await firestore
              .collection('contents')
              .where('category', whereIn: categoryList )
              .orderBy('timestamp', descending: true)
              .startAfter([_lastVisible['timestamp']])
              .limit(4)
              .get();
        }
      }


    }).then((_)async {


      if (rawData != null && rawData.docs.length > 0) {
        _lastVisible = rawData.docs[rawData.docs.length - 1];
        if (mounted) {
          _isLoading = false;
          _snap.addAll(rawData.docs);
          _data = _snap.map((e) => Article.fromFirestore(e)).toList();
          notifyListeners();
        }
      } else {
        _isLoading = false;
        print('no items available');
        notifyListeners();

      }
    });




    return null;
  }


  



  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }




  onRefresh(mounted) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted);
    notifyListeners();
  }

  


  // Future getData() async {
  //   QuerySnapshot rawData;
  //     rawData = await firestore
  //         .collection('places')
  //         .orderBy('timestamp', descending: true)
  //         .limit(10)
  //         .get();
      
  //     List<DocumentSnapshot> _snap = [];
  //     _snap.addAll(rawData.docs);
  //     _data = _snap.map((e) => Article.fromFirestore(e)).toList();
  //     notifyListeners();
    
    
  // }

  // onRefresh(mounted) {
  //   _data.clear();
  //   getData();
  //   notifyListeners();
  // }





}