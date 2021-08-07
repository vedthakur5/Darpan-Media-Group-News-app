import 'dart:convert';
import 'dart:html';

import 'package:news_admin/blocs/admin_bloc.dart';
import 'package:news_admin/models/category.dart';
import 'package:news_admin/utils/dialog.dart';
import 'package:news_admin/utils/styles.dart';
import 'package:news_admin/utils/toast.dart';
import 'package:xml/xml.dart' as xmlParse;
import 'package:webfeed/webfeed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import 'package:html/parser.dart' show parse;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Categories extends StatefulWidget {
  const Categories({Key key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController controller;
  DocumentSnapshot _lastVisible;
  bool _isLoading;
  List<DocumentSnapshot> _snap = new List<DocumentSnapshot>();
  List<Category> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String collectionName = 'categories';
  String _timestamp;
  String _date;
  var _articleData;
  bool _isInternationalNews = false;

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null)
      data = await firestore
          .collection(collectionName)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    else
      data = await firestore
          .collection(collectionName)
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible['timestamp']])
          .limit(10)
          .get();

    if (data != null && data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => Category.fromFirestore(e)).toList();
        });
      }
    } else {
      setState(() => _isLoading = false);
      openToast(context, 'No more contents available!');
    }
    return null;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  refreshData() {
    setState(() {
      _data.clear();
      _snap.clear();
      _lastVisible = null;
    });
    _getData();
  }

  handleDelete(timestamp1) {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              Text('Delete?',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              SizedBox(
                height: 10,
              ),
              Text('Want to delete this item from the database?',
                  style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: Colors.redAccent,
                    child: Text(
                      'Yes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      if (ab.userType == 'tester') {
                        Navigator.pop(context);
                        openDialog(context, 'You are a Tester',
                            'Only admin can delete contents');
                      } else {
                        await ab
                            .deleteContent(timestamp1, collectionName)
                            .then((value) => ab.getCategories())
                            .then(
                                (value) => ab.decreaseCount('categories_count'))
                            .then((value) =>
                                openToast1(context, 'Deleted Successfully'));
                        refreshData();
                        Navigator.pop(context);
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: Colors.deepPurpleAccent,
                    child: Text(
                      'No',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            Container(
              width: 300,
              height: 40,
              padding: EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]),
                  borderRadius: BorderRadius.circular(30)),
              child: FlatButton.icon(
                  onPressed: () {
                    openAddDialog();
                  },
                  icon: Icon(LineIcons.list),
                  label: Text('Add Category')),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 5, bottom: 10),
          height: 3,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.indigoAccent,
              borderRadius: BorderRadius.circular(15)),
        ),
        SizedBox(
          height: 30,
        ),
        Expanded(
          child: RefreshIndicator(
            child: ListView.separated(
              padding: EdgeInsets.only(top: 30, bottom: 20),
              controller: controller,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: _data.length + 1,
              separatorBuilder: (BuildContext context, int index) => SizedBox(
                height: 10,
              ),
              itemBuilder: (_, int index) {
                if (index < _data.length) {
                  return dataList(_data[index]);
                }
                return Center(
                  child: new Opacity(
                    opacity: _isLoading ? 1.0 : 0.0,
                    child: new SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: new CircularProgressIndicator()),
                  ),
                );
              },
            ),
            onRefresh: () async {
              refreshData();
            },
          ),
        ),
      ],
    );
  }

  Widget dataList(Category d) {
    return Container(
      height: 130,
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
              image: CachedNetworkImageProvider(d.thumbnailUrl),
              fit: BoxFit.cover)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            d.name,
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          Spacer(),
          InkWell(
              child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.delete, size: 16, color: Colors.grey[800])),
              onTap: () {
                handleDelete(d.timestamp);
              }),
        ],
      ),
    );
  }

  var formKey = GlobalKey<FormState>();
  var nameCtrl = TextEditingController();
  var thumbnailCtrl = TextEditingController();
  var feedCtrl = TextEditingController();
  var videoFeedCtrl = TextEditingController();

  // var isInternationalNewsCtrl = Checkbox();
  String timestamp;

  Future addCategory() async {
    final DocumentReference ref =
        firestore.collection(collectionName).doc(timestamp);
    await ref.set({
      'name': nameCtrl.text,
      'thumbnail': thumbnailCtrl.text,
      'feed': feedCtrl.text.split(',').map((e)=>e.trimLeft().trim()).toList(),
      'video': videoFeedCtrl.text,
      'timestamp': timestamp,
      'isInternationalNews': _isInternationalNews
    });
  }

  handleAddCategory() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);

    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (ab.userType == 'tester') {
        Navigator.pop(context);
        openDialog(context, 'You are a Tester', 'Only admin can add contents');
      } else {
        await getTimestamp()
            .then((value) => addCategory())
            .then((value) =>
                context.read<AdminBloc>().increaseCount('categories_count'))
            .then((value) => openToast1(context, 'Added Successfully'))
            .then((value) => ab.getCategories())
            .then((_) => loadFeed(
                nameCtrl.text, feedCtrl.text.split(',').map((e)=>e.trimLeft().trim()).toList(), videoFeedCtrl.text));
        refreshData();
        Navigator.pop(context);
      }
    }
  }

  clearTextfields() {
    nameCtrl.clear();
    thumbnailCtrl.clear();
    feedCtrl.clear();
    videoFeedCtrl.clear();
  }

  Future getTimestamp() async {
    DateTime now = DateTime.now();
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      timestamp = _timestamp;
    });
  }

  openAddDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(100),
            children: <Widget>[
              Text(
                'Add Category to Database',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: 50,
              ),
              Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: inputDecoration(
                            'Enter Category Name', 'Category Name', nameCtrl),
                        controller: nameCtrl,
                        validator: (value) {
                          if (value.isEmpty) return 'Name is empty';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: inputDecoration('Enter Thumbnail Url',
                            'Thumbnail Url', thumbnailCtrl),
                        controller: thumbnailCtrl,
                        validator: (value) {
                          if (value.isEmpty) return 'Thumbnail url is empty';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        maxLines: 10,
                        decoration: inputDecoration(
                            'Enter Rss feed Url', 'RSS Url', feedCtrl),
                        controller: feedCtrl,
                        validator: (value) {
                          if (value.isEmpty) return ' url is empty';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: inputDecoration('Enter Rss video feed Url',
                            'RSS Video Url', videoFeedCtrl),
                        controller: videoFeedCtrl,
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return CheckboxListTile(
                          title: Text("Is this an International news?"),
                          controlAffinity: ListTileControlAffinity.platform,
                          value: _isInternationalNews,
                          onChanged: (bool value) {
                            setState(() {
                              _isInternationalNews = value;
                            });
                          },
                        );
                      }),
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                          child: Row(
                        children: <Widget>[
                          FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            color: Colors.deepPurpleAccent,
                            child: Text(
                              'Add Category',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: () async {
                              await handleAddCategory();
                              clearTextfields();
                            },
                          ),
                          SizedBox(width: 10),
                          FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            color: Colors.redAccent,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ))
                    ],
                  ))
            ],
          );
        });
  }

  Future loadFeed(catName, feedLinks, videoFeedLink) async {
    final client = http.Client();
    for (var link in feedLinks) {
      final response =
          await client.get("https://cors.darpan.online/$link");
      final document = xmlParse.XmlDocument.parse(response.body);


      for (var element in document.findAllElements('item')) {
        // print("ok");
        await saveToDatabaseFromAPI(element, catName).catchError((e)=>print(e));
      }
      for (var element in document.findAllElements('entry')) {
        await saveToDatabaseFromAPI(element, catName)
            .catchError((e) => {print(e)});
      }
    }

    if (videoFeedLink != "") {
      final response = await client
          .get("https://cors.darpan.online/$videoFeedLink");
      var feed = RssFeed.parse(response.body);
      for (var i = 0; i < feed.items.length; i++) {
        await saveVideoToDatabaseFromAPI(feed.items[i], catName).catchError((e)=>print(e));
      }
    }
  }

  Future getDate() async {
    DateTime now = DateTime.now();
    String _d = DateFormat('dd MMMM yy').format(now);
    String _t = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      _timestamp = _t;
      _date = _d;
    });
  }

  Future saveToDatabaseFromAPI(el, cat) async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    var title, link, descParse;
    //does not work
    // print("title");
    if (el.getElement('title') != null) {
      title = el.getElement('title').innerText;
    } else {
      title = el.getElement('title').text;
    }
    // print("link");
    if (el.getElement('link') != null) {
      link = el.getElement('link').innerText;
    } else {
      link = el.getElement('link').text;
    }
    // print("desc");
    if (el.getElement('description') != null) {
      descParse = el.getElement('description').text;
    } else if (el.getElement('content') != null) {
      descParse = el.getElement('content').text;
    } else if (el.getElement('content:encoded') != null) {
      descParse = el.getElement('content:encoded').text;
    }

    // print("ass");
    var desc = parse(descParse).body.text.trim();
    var mediaGroup = el.getElement('media:group');
    var mediaContent = el.getElement('media:content');
    var img = parse(descParse).getElementsByTagName("img");
    var src = "";
    // print("img");
    // print(mediaGroup.firstChild.attributes[1].value);
    if (mediaContent != null) {
      src = mediaContent.getAttribute('url');
    } else if (mediaGroup != null) {
      src = mediaGroup.firstChild.getAttribute('url');
    } else if (el.getElement("media:thumbnail") != null) {
      src = el.getElement("media:thumbnail").getAttribute('url');
    }
    else if(el.getElement("coverImages") != null){
      src = el.getElement("coverImages").text;
    }
    else if (el.getElement('enclosure') != null) {
      src = el.getElement('enclosure').getAttribute('url');
    } else if (el.getElement('content:encoded') != null &&
        parse(el.getElement('content:encoded').innerText)
            .getElementsByTagName('img') !=
            null) {
      var content = parse(el.getElement('content:encoded').text);
      if (content
          .getElementsByTagName('img')
          .first
          .attributes["data-orig-src"] !=
          null) {
        src = content
            .getElementsByTagName('img')
            .first
            .attributes['data-orig-src'];
      } else {
        src = content.getElementsByTagName('img').first.attributes['src'];
      }
    } else if (el.getElement('bigimage') != null) {
      src = el.getElement('bigimage').text;
    } else if (el.getElement('fullimage') != null) {
      src = el.getElement('fullimage').text;
    } else if (el.getElement('image') != null) {
      if(el.getElement('image').getElement("link")!=null){
        src = el.getElement('image').getElement("link").text;
      }else{
        src = el.getElement('image').text;
      }
    } else if (img.length > 0) {
      src = img[0].attributes["src"].toString();
    }

    // print(src);
    if (desc == "") {
      desc = title;
    }
    // print(desc);
    if (src != "") {
      var contentRef = await firestore
          .collection('contents')
          .where('title', isEqualTo: title)
          .get();

      if (contentRef.docs.length <= 0) {
        await getDate();
        final DocumentReference ref =
        firestore.collection('contents').doc(_timestamp);

        _articleData = {
          'category': cat,
          'content type': 'Image',
          'title': title,
          'description': desc,
          'image url': src,
          'youtube url': null,
          'loves': 0,
          'source': link,
          'date': _date,
          'timestamp': _timestamp
        };

        await ref.set(_articleData);
        await context.read<AdminBloc>().increaseCount('contents_count');
        await sleep1();
      }
    }
  }

  Future saveVideoToDatabaseFromAPI(el, cat) async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    var desc = parse(el.description);
    var img = desc.getElementsByTagName("img")[0];
    var src = img.attributes["src"].toString();

    var contentRef = await firestore
        .collection('contents')
        .where('title', isEqualTo: el.title)
        .get();
    // print(el['title']);
    if (contentRef.docs.length <= 0) {
      await getDate();
      final DocumentReference ref =
      firestore.collection('contents').doc(_timestamp);

      _articleData = {
        'category': cat,
        'content type': 'Video',
        'title': el.title,
        'description': desc.body.text,
        'image url': src,
        'youtube url': el.link,
        'loves': 0,
        'source': el.link,
        'date': _date,
        'timestamp': _timestamp
      };
      await ref.set(_articleData).then(
              (_) => context.read<AdminBloc>().increaseCount('contents_count'));
      await sleep1();
    }
  }


  Future sleep1() {
    return new Future.delayed(const Duration(seconds: 1), () => "1");
  }
}
