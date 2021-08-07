import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:launch_review/launch_review.dart';
import 'package:line_icons/line_icons.dart';
import 'package:news_app/blocs/notification_bloc.dart';
import 'package:news_app/blocs/theme_bloc.dart';
import 'package:news_app/pages/bookmarks.dart';
import 'package:news_app/pages/edit_profile.dart';
import 'package:news_app/pages/welcome.dart';
import 'package:news_app/widgets/language.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/sign_in_bloc.dart';
import '../config/config.dart';
import '../utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  openAboutDialog() {
    final sb = context.read<SignInBloc>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AboutDialog(
            applicationName: Config().appName,
            applicationIcon: Image(
              image: AssetImage(Config().splashIcon),
              height: 30,
              width: 30,
            ),
            applicationVersion: sb.appVersion,
          );
        });
  }

  openLContactDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text('Contact Us'),
              contentPadding: EdgeInsets.all(22),
              children: [
                Text("For any help Or query contact us at:",
                  style: TextStyle( fontSize: 18),),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: "dailynews@darpan.online \n\n\n",
                      style: new TextStyle(color: Colors.blue, fontSize: 18),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          var url = "mailto:dailynews@darpan.online";
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }),
                ])),
                Text("If you have something you think which needs to be cover and reported, give us a tip at:",
                  style: TextStyle( fontSize: 18),),
                RichText(text:
                TextSpan(
                    text: "Dailynews.support@darpan.online \n\n\n",
                    style: new TextStyle(color: Colors.blue, fontSize: 18),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        var url = "mailto:Dailynews.support@darpan.online";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }),),
                Text("For advertising and promotion reach us at:",
                  style: TextStyle( fontSize: 18),),
                RichText(text:
                TextSpan(
                    text: "dailynews@darpan.online\n\n\n",
                    style: new TextStyle(color: Colors.blue, fontSize: 18),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        var url = "mailto:dailynews@darpan.online";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }),)
              ]);
        });
  }
  openPrivacyDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text('Privacy Policy'),
              contentPadding: EdgeInsets.all(22),
              children: [ SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                        '''Dailynews 
Privacy Policy
This Privacy Policy sets out the basis on which information collected from the users or provided by the users is processed by us, Foundation for Independent Journalism, a company incorporated under the laws of India and having its registered office at K-2, BK DUTT COLONY,IN and/or its subsidiary(ies) and/or affiliate(s) (collectively hereinafter referred to as the “Company”), which operates various websites, apps, newsletters and other services including but not limited to delivery of information and content via any mobile or internet connected device or otherwise (collectively the “Service(s)”).

This Privacy Policy forms part and parcel of the Terms of Use for the Services. Capitalized terms which have been used here but are undefined shall have the same meaning as attributed to them in the Terms of Use. The Company respects the privacy of the users of the Services and is committed to protect it in all respects.

1. INFORMATION RECEIVED, COLLECTED AND STORED BY THE COMPANY
2. We collect and process some or all of the following type of information in the course of you using our Services. The type of information we collect will depend on the circumstances and the Service you are using. Generally speaking, the information about the user as collected by the Company is: (a) data supplied by users and (b) data automatically tracked while navigation (c) data collected from any other source (collectively referred to as “Information”).
3. (a). Information Supplied by Users
4. (i) Registration Data
5. This Information includes, but is not limited to, basic contact information provided by you on our Website, which may include your name, mobile number, address, e-mail address, data of birth, demographical information, gender, interests, preferences, place of work, position, country. For example, the Company may collect personal Information when you register on the Website, to subscribe to our Services or for requesting further information. It can also include information that we have not requested but which you have volunteered, such as information provided during interactions via comments or other submissions you have made to our online Services, such as online forums, in response to a survey, while requesting certain Services or products, or to enter a sweepstakes, contest, or other promotion.
When you register using your other accounts like on Facebook, Twitter, Gmail etc. we shall retrieve Information from such account to continue to interact with you and to continue providing the Services.
The Company may use your Information to provide you with information, special offers, and promotions via various means including e-mail. You may instruct Company at any time not to use your personal Information covered by this Privacy Policy to provide you with special offers and promotions.

In case you choose to decline to submit personal Information on the Website, the Company may not be able to provide certain sites / content / apps / services / features to you. We will make reasonable efforts to notify you of the same at the time of opening your account. In any case, we will not be liable and or responsible for the denial of certain services to you for lack of you providing the necessary personal Information.

(ii) Subscription or Paid Service Data
You may choose to purchase any subscription or paid Service using a credit card, e-wallet or any other electronic payment system. When you chose any subscription or paid Service, we or our payment system provider may collect your purchase, address or billing information, including your credit card number and expiration date, etc. (“Payment Information”). However, when you order using an in-app purchase option, same are handled by such platform providers. Typically, the Payment information is provided directly by users, via the Website, into the PCI/DSS-compliant payment processing service to which the Company subscribes, and the Company does not, itself, process or store the Payment Information, except as stated herein.
The subscriptions or paid Services may be on auto renewal mode unless cancelled. If at any point you do not wish to auto-renew your subscription, you may cancel your subscription before the end of the subscription term.

This Payment Information is used to provide you your requested Services, to manage your account, to communicate with you, and enforce any terms of service or agreement related to the Website. We use any Payment Information we acquire from you only to fulfill your order.

(iii) Information about other Individuals
In some circumstances you might provide us with the Information about other individuals, you must ensure that you (1) have their permission to provide their Information to us; and (2) you have made them aware of the terms of this Privacy Policy. By submitting the Information about others, you represent and warrant that you are authorized to do so and that you have received authorization from the person about whom you are providing the Information and that person has explicitly consented to have all Information used, processed, disclosed, and transferred in accordance with this Privacy Policy.

(b) Information automatically tracked while navigation
When you use our Services, we automatically record Information about your usage of those Services, your interaction with our emails as well as information about the device you are using and your internet connection. We do this in the following ways:

(i) Use of Cookies and other Electronic Tools
The Company and the parties with whom we work (e.g., business partners, advertisers and advertising servers) may place, view, and/or use “cookies”, web server logs, web beacons, or mapping pixel/pixel tag or other electronic tools to collect statistical and other Information about your use of the Website and other websites. This Information may include information about the IP address of your computer, browser type, language, operating system, your mobile device, geo-location data, the state or country from which you accessed the Company’s Website, the web pages visited, the date and the time of a visit, the websites you visited immediately before and after visiting the Website, the number of links you click within the Website, the functions you use on the Website, the databases you view and the searches you request on the Website, the data you save on or download from the Website and the number of times you view an advertisement. For more information, please see our Cookies Policy, which forms part of this Privacy Policy and the Terms and Conditions of the Website.
The Company and the parties with whom we work may use the information collected for various reasons, either on behalf of Company or for the other parties’ own purposes, including research, analysis, to better serve visitors to the Website (such as by providing customized content, or presenting online advertising on the Website or other websites tailored to your interests as described further below), to compile aggregate and anonymous information about usage of the Website and other websites, other statistics, etc. However, if you have deleted and disabled cookies, these uses will not be possible to the extent they are based on cookie information. This is statistical data about our users browsing actions and patterns and does not identify any individual. However, to assist us with the uses described in this Privacy Policy, information collected about your use of the Website or other websites may be combined with personal or other Information about you from other online or offline sources to track usage of our Services.

(ii) Log File Information
We automatically collect limited information about your computer’s connection to the Internet, mobile number, etc., when you visit the Website / Service. We automatically receive and log information from your browser, including your computer’s name, your operating system, browser type and version, IP address, CPU speed, and connection speed. We may also collect log information from your device, including your location, IP address, your device’s name, device’s serial number or unique identification number (e.g. UDiD on your iOS device). If you access the Services from a mobile or other device, we may collect a unique device identifier assigned to that device, geo-location data, or other transactional information for that device.

(iii) Clear GIFs
Besides web beacons, we may also use clear GIFs in HTML-based emails sent to our users to track which emails are opened by recipients. We use this information to inter-alia to measure traffic within the Website / Service to improve the Website / Service quality, functionality and interactivity and let advertisers know the geographic locations from where our visitors come.

(c) Information collected from any other source
We may receive Information about you from other sources, add it to our account information and treat it in accordance with this Privacy Policy. If you provide Information to the platform provider or other partner, your account information and order information may be passed on to us. We may obtain updated contact information from third parties in order to correct our records and fulfill the Services or to communicate with you and you expressly consent to this.

(i) Information from other Sources: Demographic & Purchase Information
We may reference other sources of demographic and other information in order to provide you with more targeted communications and promotions. We use analytical tools to track the user behaviour on our Website. These tools have been enabled to support display advertising towards helping us gain understanding of our users’ demographics and interests. The reports are anonymous and cannot be associated with any individual personally identifiable Information that you may have shared with us.

(ii)Advertisements& Purchase Information
The Company or third-party advertisers or their advertising servers may also place or recognize unique cookies on your computer or use other electronic tools in order to help display advertisements that you see on the Website or on other websites. Information about your visits to, and activity on, the Website and other websites, an IP address, the number of times you have viewed an advertisement, and other such usage information is used, alone or in combination with other information, to display on your device screen advertisements that may be of particular interest to you. We may use web beacons, provided by third-party advertising companies, to help manage and optimize our online advertising and product performance. Web beacons enable us to recognize a browser’s cookie when a browser visits this Website, and to learn which banner ads bring users to this Website. The use and collection of your Information by these third-party service providers, and third-party advertisers and their advertising servers is not covered by this Privacy Policy.

2. INFORMATION USE BY THE COMPANY
3. We use Information held about you for our legitimate business interests for the following purposes:
(i) To provide you Services including associated functionalities whether by us or by our designated representatives and/or business partners to you or to parties designated by you and any and all matters ancillary thereto including to carry out obligations from any contracts entered into between us. We rely on performance of our contract with you so as the legal basis for such processing;

(ii) To verify and process payment when you subscribe to, purchase and/or obtain Services from any of our Website. We rely on performance of our contract with you so as the legal basis for such processing;

(iii) For verification and record of your personal particulars, to authenticate you so that we know it is you and not someone else which includes comparing it with Information from other sources and using the Information to communicate with you. We rely on performance of our contract with you so as the legal basis for such processing;

(iv) To conduct market research and statistical analysis of the users of the Website including the number of users, the frequency of use, profile of users and using such analysis for our business plans, the enhancement of our products and services, targeted advertisements and conveying such Information in broad terms (but not information in relation to specific individuals) to third parties who have or propose to have business dealings with us. We rely on legitimate business interests as the legal basis for such processing and the legitimate interest is the analyzing the use of the Services and improving the same;

(v) To send you Information, promotions and updates including marketing and advertising materials in relation to our Services and those of third party organizations selected by us. We will only do this where we reasonably believe that our Services may be of interest to you and you consent to being provided with such information. We rely on legitimate business interest as the legal basis to promote our Services to you as the legal basis for this processing;

(vi) To prevent fraud or other potentially illegal activities (including copyright infringement) and to block disruptive users and protect the safety of users of our Services. The legal basis for this processing is our legitimate business interests being the proper protection of our business against risks and

(viii) To enforce our terms of Service. The legal basis for this processing being the protection and assertion of our legal rights and the legal rights of others.

In any case, if you would prefer that we do not use your Information to market or promote our products and Services to you, please either (i) tick the relevant box on the form through which we collect your Information (for example, the registration form); (ii) unsubscribe from our electronic communications using the method indicated in the relevant communication; or (iii) contact us at the contact details set out below:

Krishna Shukla
Foundation for Independent Journalism
Email Krishna@darpan.online

3. Sensitive Personal Information
4. Unless specifically requested, we ask that you not send us, and you shall not disclose, on or through the Services or otherwise to us, any sensitive personal information (e.g., information related to racial or ethnic origin, political opinions, religion, ideological or other beliefs, health, biometrics or genetic characteristics, national identification numbers, social security numbers, criminal background, trade union membership, or administrative or criminal proceedings and sanctions).
4. DISCLOSURE OF PERSONAL INFORMATION AND OTHER INFORMATION
5. (a)Information Shared with Group Companies and Affiliates
6. The Company may share Information with its employees, agents, officers, group companies, the employees, agents and officers of such group companies and our affiliates (including affiliated websites under common ownership or control) for the purpose of processing Information on its behalf.
(b)Information shared with Third Parties and Sponsors
(i) The Company may share with other third parties Information about our Website users, such as your use of the Website or other websites, and the Services provided on the Website or other websites, but only on an anonymous and aggregate basis to help us develop content, services, and advertising that we hope you will find of interest. The Company may also share your Information with a sponsor or other third party (“Third-Party Provider”) to perform Site-related services, including database management, maintenance services, analytics, marketing, data processing, and email and text message distribution. These third parties have access to your Information only to perform these tasks only on our behalf.
(ii) The Company may share Information to support sponsors. If you participate in certain features of the Website (e.g., sharing news stories of interest), please note that any Information you or others voluntarily disclose through use of these features, becomes available to the public and/or other users whom you have designated. The Company is not responsible for the Information that you or others choose to disclose publicly on the Website, and neither the Company’s nor others’ use of such Information is subject to this Privacy Policy.

(c)Information shared via third party social buttons, widgets and other embedded content
Some of our online services carry embedded content controlled by third parties for services such as social sharing, recommended stories, commenting/reviewing, and displaying video or images. When you interact with these services they may collect information from and about you and your interaction with their content. This activity will be subject to the Privacy Policy of and your settings for your chosen network. Please be aware that they may track your activity, through the use of cookies or similar technology, without you needing to interact with them. If this concerns you, ensure you log out of their services before using ours.

Further, we use third-party advertising companies to serve ads when you visit or use the Website or Services. These companies may use Information (not including your name, address, email address or telephone number) about your visits or use to particular website, mobile application or services, in order to provide advertisements about goods and services of interest to you.

(d)Information shared with Other Parties
The Company may also disclose your personal and other Information to unaffiliated third parties if we believe in good faith that such disclosure is necessary: (i) to comply with the law or in response to a subpoena, court order, search warrants, judicial proceedings, other legal process, or other law enforcement measures, to establish or exercise our legal rights, or to defend against legal claims; (ii) to protect the interests, rights, safety, or property of the Company or others; (iii) to enforce any terms of service on the Website; (iv) to investigate, prevent, or take action regarding illegal activities, suspected fraud, situations involving potential, or as otherwise required by law; (v) to provide you and other users of the Website with the Services or products requested by you and/or the other users, and to perform other activities related to such Services and products, including billing and collection; (vi) to provide you with special offers or promotions from the Company that may be of interest to you; or (vii) to operate the Company’s systems properly.

(e)
The Company may present Information to allow social sharing functionality. If you log in with or connect a social media service account with Services, we may share your user name, picture, and likes, as well as your activities and comments with other Services users and with your friends associated with your social media service. We may also share the same Information with the social media service provider. By logging in with or connecting your Services account with a social media service, you are authorizing us to share Information we collect from and about you with the social media service provider, other users and your friends and you understand that the social media services use of the shared Information will be governed by the social media services privacy policy. If you do not want your personal Information shared in this way, please do not connect your social media service account with your Services account and do not participate in social sharing on Services.

(f)Sale or Transfer of all or part of Business of Company
If the Company sells all or part of its business or makes a sale or transfer of its assets or is otherwise involved in a merger or transfer of all or a material part of its business, the Company may transfer your Information to the party or part'''
                    ),
                  ],
                ),
              ),
              ]);
        });
  }
  openAboutUsDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text('About Us'),
              contentPadding: EdgeInsets.all(22),
              children: [
                Text('''
                DailyNews believes every minor news which comes up with truth deserves a platform to be published. In a world full of misconceptions, misguidance, Manipulation DailyNews acts as a Truth Filter for news platforms. The moto of DailyNews is to keep its readers updated with the latest happenings in national, global, political sectors. DailyNews keeps sharing various sports statistics,  analysing various local, national and international athletes. DailyNews keeps a close eye on trending topics on social media and entertainment.

The mission of DailyNews is to share a platform for truth and have unbiased media in the country.
                ''')
              ]);
        });
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sb = context.watch<SignInBloc>();
    return Scaffold(
        appBar: AppBar(
          title: Text('profile').tr(),
          centerTitle: false,
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(15, 20, 20, 50),
          children: [
            sb.guestUser == true ? GuestUserUI() : UserUI(),
            Text(
              "general settings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ).tr(),
            SizedBox(
              height: 15,
            ),
            ListTile(
              title: Text('bookmarks').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.bookmark, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () => nextScreen(context, BookmarkPage()),
            ),
            Divider(
              height: 3,
            ),
            ListTile(
              title: Text('dark mode').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(LineIcons.sun_o, size: 22, color: Colors.white),
              ),
              trailing: Switch(
                  activeColor: Theme.of(context).primaryColor,
                  value: context.watch<ThemeBloc>().darkTheme,
                  onChanged: (bool) {
                    context.read<ThemeBloc>().toggleTheme();
                  }),
            ),
            Divider(
              height: 3,
            ),
            ListTile(
              title: Text('get notifications').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(LineIcons.bell, size: 22, color: Colors.white),
              ),
              trailing: Switch(
                  activeColor: Theme.of(context).primaryColor,
                  value: context.watch<NotificationBloc>().subscribed,
                  onChanged: (bool) {
                    context.read<NotificationBloc>().fcmSubscribe(bool);
                  }),
            ),
            Divider(
              height: 3,
            ),
            ListTile(
              title: Text('contact us').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.mail, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () => openLContactDialog(),
            ),
            Divider(
              height: 3,
            ),
            ListTile(
              title: Text('language').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.globe, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () => nextScreenPopup(context, LanguagePopup()),
            ),
            Divider(
              height: 3,
            ),
            ListTile(
              title: Text('rate this app').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.star, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () async => LaunchReview.launch(
                  androidAppId: sb.packageName, iOSAppId: Config().iOSAppId),
            ),
            Divider(
              height: 3,
            ),
            ListTile(
              title: Text('licence').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.paperclip, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () => openAboutDialog(),
            ),
            Divider(
              height: 3,
            ),
            ListTile(
              title: Text('privacy policy').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.lock, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () =>openPrivacyDialog(),
            ),
            Divider(
              height: 3,
            ),
            ListTile(
              title: Text('about us').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.info, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () =>openAboutUsDialog(),
            ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class GuestUserUI extends StatelessWidget {
  const GuestUserUI({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('login').tr(),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(Feather.user, size: 20, color: Colors.white),
          ),
          trailing: Icon(
            Feather.chevron_right,
            size: 20,
          ),
          onTap: () => nextScreenPopup(
              context,
              WelcomePage(
                tag: 'popup',
              )),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class UserUI extends StatelessWidget {
  const UserUI({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    return Column(
      children: [
        Container(
          height: 200,
          child: Column(
            children: [
              CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: CachedNetworkImageProvider(sb.imageUrl)),
              SizedBox(
                height: 15,
              ),
              Text(
                sb.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        ListTile(
          title: Text(sb.email),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(Feather.mail, size: 20, color: Colors.white),
          ),
        ),
        Divider(
          height: 3,
        ),
        ListTile(
            title: Text('edit profile').tr(),
            leading: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(5)),
              child: Icon(Feather.edit_3, size: 20, color: Colors.white),
            ),
            trailing: Icon(
              Feather.chevron_right,
              size: 20,
            ),
            onTap: () => nextScreen(
                context, EditProfile(name: sb.name, imageUrl: sb.imageUrl))),
        Divider(
          height: 3,
        ),
        ListTile(
          title: Text('logout').tr(),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(Feather.log_out, size: 20, color: Colors.white),
          ),
          trailing: Icon(
            Feather.chevron_right,
            size: 20,
          ),
          onTap: () => openLogoutDialog(context),
        ),
        SizedBox(
          height: 15,
        )
      ],
    );
  }

  void openLogoutDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('logout title').tr(),
            actions: [
              FlatButton(
                child: Text('no').tr(),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text('yes').tr(),
                onPressed: () async {
                  Navigator.pop(context);
                  await context
                      .read<SignInBloc>()
                      .userSignout()
                      .then((value) =>
                          context.read<SignInBloc>().afterUserSignOut())
                      .then((value) {
                    if (context.read<ThemeBloc>().darkTheme == true) {
                      context.read<ThemeBloc>().toggleTheme();
                    }
                    nextScreenCloseOthers(context, WelcomePage());
                  });
                },
              )
            ],
          );
        });
  }
}
