import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:news_admin/blocs/admin_bloc.dart';
import 'package:news_admin/config/config.dart';
import 'package:news_admin/pages/admin.dart';
import 'package:news_admin/pages/articles.dart';
import 'package:news_admin/pages/data_info.dart';
import 'package:news_admin/pages/featured.dart';
import 'package:news_admin/pages/notifications.dart';
import 'package:news_admin/pages/settings.dart' as setting;

import 'package:webfeed/webfeed.dart';
import 'package:xml/xml.dart' as xmlParse;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:news_admin/pages/sign_in.dart';
import 'package:news_admin/pages/categories.dart';
import 'package:news_admin/pages/upload_content.dart';
import 'package:news_admin/pages/users.dart';
import 'package:news_admin/utils/next_screen.dart';
import 'package:news_admin/widgets/cover_widget.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vertical_tabs/vertical_tabs.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  final List<String> titles = [
    'Dashboard',
    'Articles',
    'Featured Articles',
    'Upload Article',
    'Categories',
    'Notifications',
    'Users',
    'Admin',
    'Settings'
  ];

  // Timer timer;
  String _timestamp;
  String _date;
  var _articleData;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final List icons = [
    LineIcons.pie_chart,
    LineIcons.map_marker,
    LineIcons.bomb,
    LineIcons.arrow_circle_up,
    LineIcons.map_pin,
    LineIcons.bell,
    LineIcons.users,
    LineIcons.user_secret,
    LineIcons.chain
  ];

  Future handleLogOut() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp
        .clear()
        .then((value) => nextScreenCloseOthers(context, SignInPage()));
  }

  @override
  void initState() {
    super.initState();
    if (this.mounted) {
      context.read<AdminBloc>().getCategories();
      context.read<AdminBloc>().getAdsData();
    }
    // timer = Timer.periodic(Duration(seconds: 1200), (Timer t) => handleSubmitAPI());
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
    print("title");
    if (el.getElement('title') != null) {
      title = el.getElement('title').innerText;
    } else {
      title = el.getElement('title').text;
    }
    print("link");
    if (el.getElement('link') != null) {
      link = el.getElement('link').innerText;
    } else {
      link = el.getElement('link').text;
    }
    print("desc");
    if (el.getElement('description') != null) {
      descParse = el.getElement('description').text;
    } else if (el.getElement('content') != null) {
      descParse = el.getElement('content').text;
    } else if (el.getElement('content:encoded') != null) {
      descParse = el.getElement('content:encoded').text;
    }

    print("ass");
    var desc = parse(descParse).body.text.trim();
    var mediaGroup = el.getElement('media:group');
    var mediaContent = el.getElement('media:content');
    var img = parse(descParse).getElementsByTagName("img");
    var src = "";
    print("img");
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

    print(src);
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

  Future getDate() async {
    DateTime now = DateTime.now();
    String _d = DateFormat('dd MMMM yy').format(now);
    String _t = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      _timestamp = _t;
      _date = _d;
    });
  }

  @override
  void dispose() {
    // timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    return Scaffold(
      appBar: _appBar(ab),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: VerticalTabs(
                  tabBackgroundColor: Colors.white,
                  backgroundColor: Colors.grey[200],
                  tabsElevation: 10,
                  tabsShadowColor: Colors.grey[500],
                  tabsWidth: 200,
                  indicatorColor: Colors.deepPurpleAccent,
                  selectedTabBackgroundColor:
                      Colors.deepPurpleAccent.withOpacity(0.1),
                  indicatorWidth: 5,
                  disabledChangePageFromContentView: true,
                  initialIndex: _pageIndex,
                  changePageDuration: Duration(microseconds: 1),
                  tabs: <Tab>[
                    tab(titles[0], icons[0]),
                    tab(titles[1], icons[1]),
                    tab(titles[2], icons[2]),
                    tab(titles[3], icons[3]),
                    tab(titles[4], icons[4]),
                    tab(titles[5], icons[5]),
                    tab(titles[6], icons[6]),
                    tab(titles[7], icons[7]),
                    tab(titles[8], icons[8]),
                  ],
                  contents: <Widget>[
                    DataInfoPage(),
                    CoverWidget(widget: Articles()),
                    CoverWidget(widget: FeaturedArticles()),
                    CoverWidget(widget: UploadContent()),
                    CoverWidget(widget: Categories()),
                    CoverWidget(widget: Notifications()),
                    CoverWidget(widget: UsersPage()),
                    CoverWidget(widget: AdminPage()),
                    CoverWidget(widget: setting.Settings())
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tab(title, icon) {
    return Tab(
        child: Container(
      padding: EdgeInsets.only(
        left: 10,
      ),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            size: 20,
            color: Colors.grey[800],
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[900],
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    ));
  }

  Widget _appBar(ab) {
    return PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          height: 60,
          padding: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[300], blurRadius: 10, offset: Offset(0, 5))
          ]),
          child: Row(
            children: <Widget>[
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.deepPurpleAccent,
                          fontFamily: 'Muli'),
                      text: Config().appName,
                      children: <TextSpan>[
                    TextSpan(
                        text: ' - Admin Panel',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                            fontFamily: 'Muli'))
                  ])),
              Spacer(),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey[400],
                          blurRadius: 10,
                          offset: Offset(2, 2))
                    ]),
                child: FlatButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  icon: Icon(
                    LineIcons.sign_out,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                  onPressed: () => handleLogOut(),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurpleAccent),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FlatButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  icon: Icon(
                    LineIcons.user,
                    color: Colors.grey[800],
                    size: 20,
                  ),
                  label: Text(
                    'Signed as ${ab.userType}',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.deepPurpleAccent,
                        fontSize: 16),
                  ),
                  onPressed: () => null,
                ),
              ),
              SizedBox(
                width: 20,
              )
            ],
          ),
        ));
  }
}
