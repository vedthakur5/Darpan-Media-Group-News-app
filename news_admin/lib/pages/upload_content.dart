import 'dart:convert';
import 'dart:html';

// import 'package:xml2json/xml2json.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:webfeed/webfeed.dart';
import 'package:news_admin/blocs/admin_bloc.dart';
import 'package:news_admin/utils/dialog.dart';
import 'package:news_admin/utils/styles.dart';
import 'package:news_admin/widgets/article_preview.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../blocs/admin_bloc.dart';

import 'package:xml/xml.dart' as xmlParse;
import 'dart:developer' as developer;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import '../blocs/notification_bloc.dart';
import '../config/config.dart';
import '../utils/dialog.dart';

class UploadContent extends StatefulWidget {
  UploadContent({Key key}) : super(key: key);

  @override
  _UploadContentState createState() => _UploadContentState();
}

class _UploadContentState extends State<UploadContent> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Timer timer;
  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  var imageUrlCtrl = TextEditingController();
  var sourceCtrl = TextEditingController();
  var descriptionCtrl = TextEditingController();
  var imageCtrl = TextEditingController();
  var youtubeVideoUrlCtrl = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  bool notifyUsers = true;
  bool uploadStarted = false;
  String _timestamp;
  String _date;
  var _articleData;

  var categorySelection;
  var contentTypeSelection;

  void handleSubmit() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    if (categorySelection == null) {
      openDialog(context, 'Select a category first', '');
    } else if (contentTypeSelection == null) {
      openDialog(context, 'Select content type', '');
    } else {
      if (formKey.currentState.validate()) {
        formKey.currentState.save();
        if (ab.userType == 'tester') {
          openDialog(context, 'You are a Tester',
              'Only Admin can upload, delete & modify contents');
        } else {
          setState(() => uploadStarted = true);
          await getDate().then((_) async {
            await saveToDatabase()
                .then((value) =>
                    context.read<AdminBloc>().increaseCount('contents_count'))
                .then((value) => handleSendNotification());
            setState(() => uploadStarted = false);
            openDialog(context, 'Uploaded Successfully', '');
            clearTextFeilds();
          });
        }
      }
    }
  }

  void handleSubmitAPI() async {
    // var contentRef = await firestore
    //     .collection('contents')
    //     .get();
    // print(contentRef.docs.length)

    await firestore.collection('categories').get().then((cat) async => {
          for (var category in cat.docs)
            {
              // print("ok2")
              for (var feed in category['feed'])
                {
                  if (feed == "s")
                    {}
                  else
                    {await loadFeed(category, feed).catchError((e) => print(e))}
                }
            }
        });
  }

  Future loadFeed(cat, feedUrl) async {
    final client = http.Client();
    final response =
        await client.get("https://cors.darpan.online/$feedUrl");

    final document = xmlParse.XmlDocument.parse(response.body);
    for (var element in document.findAllElements('item')) {
      await saveToDatabaseFromAPI(element, cat['name'])
          .catchError((e) => {print(e)});
    }
    for (var element in document.findAllElements('entry')) {
      await saveToDatabaseFromAPI(element, cat['name'])
          .catchError((e) => {print(e)});
    }

    if (cat['video'] != "") {
      final response = await client
          .get("https://cors.darpan.online/${cat['video']}");
      var feed = RssFeed.parse(response.body);
      for (var i = 0; i < feed.items.length; i++) {
        await saveVideoToDatabaseFromAPI(feed.items[i], cat['name'])
            .catchError((e) => {print(e)});
      }
    }

    client.close();
  }

  // unused function
  fetchAndSaveToDB(QueryDocumentSnapshot category) async {
    String url =
        "https://newsapi.org/v2/top-headlines?q=${category['name']}&apiKey=b27566a162b94d0faafd7e2b6503d4fd";
    var response = await http.get(url);
    var json = jsonDecode(response.body);
    if (json['status'] == "ok") {
      for (var el in json['articles']) {
        // print("saving");
        if (el['urlToImage'] != null) {
          await saveToDatabaseFromAPI(el, category['name'])
              .catchError((e) => {print(e), print("cauth ")});
        }
      }
    }
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
    }
    else if (el.getElement('image') != null) {
      if(el.getElement('image').getElement("url")!=null){
        src = el.getElement('image').getElement("url").text;
      }else if(el.getElement('image').getElement("link")!=null){
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
          'image url': src.trimLeft().trim(),
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

  Future handleSendNotification() async {
    if (notifyUsers == true) {
      await context
          .read<NotificationBloc>()
          .addToNotificationList(context, _timestamp)
          .then((value) =>
              context.read<NotificationBloc>().sendNotification(titleCtrl.text, imageCtrl.text))
          .then((value) =>
              context.read<AdminBloc>().increaseCount('notifications_count'));
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

  Future saveToDatabase() async {
    final DocumentReference ref =
        firestore.collection('contents').doc(_timestamp);
    _articleData = {
      'category': categorySelection,
      'content type': contentTypeSelection,
      'title': titleCtrl.text,
      'description': descriptionCtrl.text,
      'image url': imageUrlCtrl.text,
      'youtube url':
          contentTypeSelection == 'image' ? null : youtubeVideoUrlCtrl.text,
      'loves': 0,
      'source': sourceCtrl.text == '' ? null : sourceCtrl.text,
      'date': _date,
      'timestamp': _timestamp
    };
    await ref.set(_articleData);
  }

  clearTextFeilds() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    imageUrlCtrl.clear();
    youtubeVideoUrlCtrl.clear();
    sourceCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  handlePreview() async {
    if (categorySelection == null) {
      openDialog(context, 'Select a category first', '');
    } else if (contentTypeSelection == null) {
      openDialog(context, 'Select content type', '');
    } else {
      if (formKey.currentState.validate()) {
        formKey.currentState.save();
        await getDate().then((_) async {
          await showArticlePreview(
              context,
              titleCtrl.text,
              descriptionCtrl.text,
              imageUrlCtrl.text,
              0,
              sourceCtrl.text,
              'Now',
              categorySelection,
              contentTypeSelection,
              youtubeVideoUrlCtrl.text ?? '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      body: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: h * 0.10,
              ),
              Text(
                'Article Details',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(child: categoriesDropdown()),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(child: contentTypeDropdown()),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: inputDecoration('Enter Title', 'Title', titleCtrl),
                controller: titleCtrl,
                validator: (value) {
                  if (value.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: inputDecoration(
                    'Enter Thumnail Url', 'Thumnail', imageUrlCtrl),
                controller: imageUrlCtrl,
                validator: (value) {
                  if (value.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              contentTypeSelection == null || contentTypeSelection == 'image'
                  ? Container()
                  : Column(
                      children: [
                        TextFormField(
                          decoration: inputDecoration('Enter Youtube Url',
                              'Youtube video Url', youtubeVideoUrlCtrl),
                          controller: youtubeVideoUrlCtrl,
                          validator: (value) {
                            if (value.isEmpty) return 'Value is empty';
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
              TextFormField(
                decoration: inputDecoration('Enter Source Url (Optional)',
                    'Source Url(Optional)', sourceCtrl),
                controller: sourceCtrl,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Enter Description (Html or Normal Text)',
                    border: OutlineInputBorder(),
                    labelText: 'Description',
                    contentPadding:
                        EdgeInsets.only(right: 0, left: 10, top: 15, bottom: 5),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey[300],
                        child: IconButton(
                            icon: Icon(Icons.close, size: 15),
                            onPressed: () {
                              descriptionCtrl.clear();
                            }),
                      ),
                    )),
                textAlignVertical: TextAlignVertical.top,
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: descriptionCtrl,
                validator: (value) {
                  if (value.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              SizedBox(
                height: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Checkbox(
                    activeColor: Colors.blueAccent,
                    onChanged: (bool value) {
                      setState(() {
                        notifyUsers = value;
                        print('notify users : $notifyUsers');
                      });
                    },
                    value: notifyUsers,
                  ),
                  Text('Notify All Users'),
                  Spacer(),
                  FlatButton.icon(
                      icon: Icon(
                        Icons.remove_red_eye,
                        size: 25,
                        color: Colors.blueAccent,
                      ),
                      label: Text(
                        'Preview',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.black),
                      ),
                      onPressed: () {
                        handlePreview();
                      })
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  color: Colors.deepPurpleAccent,
                  height: 45,
                  child: uploadStarted == true
                      ? Center(
                          child: Container(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator()),
                        )
                      : FlatButton(
                          child: Text(
                            'Upload Article',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: () async {
                            handleSubmit();
                          })),
              SizedBox(
                height: 10,
              ),
              Container(
                  color: Colors.deepPurpleAccent,
                  height: 45,
                  child: uploadStarted == true
                      ? Center(
                          child: Container(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator()),
                        )
                      : FlatButton(
                          child: Text(
                            'Upload Articles From API',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: () async {
                            handleSubmitAPI();
                          })),
              SizedBox(
                height: 200,
              ),
            ],
          )),
    );
  }

  Widget categoriesDropdown() {
    final AdminBloc ab = Provider.of(context, listen: false);
    return Container(
        height: 50,
        padding: EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]),
            borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(border: InputBorder.none),
            onChanged: (value) {
              setState(() {
                categorySelection = value;
              });
            },
            onSaved: (value) {
              setState(() {
                categorySelection = value;
              });
            },
            value: categorySelection,
            hint: Text('Select Category'),
            items: ab.categories.map((f) {
              return DropdownMenuItem(
                child: Text(f),
                value: f,
              );
            }).toList()));
  }

  Widget contentTypeDropdown() {
    return Container(
        height: 50,
        padding: EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]),
            borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(border: InputBorder.none),
            onChanged: (value) {
              setState(() {
                contentTypeSelection = value;
              });
            },
            onSaved: (value) {
              setState(() {
                contentTypeSelection = value;
              });
            },
            value: contentTypeSelection,
            hint: Text('Select Content Type'),
            items: Config().contentTypes.map((f) {
              return DropdownMenuItem(
                child: Text(f),
                value: f,
              );
            }).toList()));
  }
}
