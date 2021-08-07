import 'package:flutter/material.dart';

class Config{

  
  final String appName = 'DailyNews';
  final splashIcon = 'assets/splash.png';
  final splashImage = 'assets/splash_screen.png';
  final String supportEmail = 'sohamsonawane111@gmail.com';
  final String privacyPolicyUrl = 'https://docs.google.com';
  final String ourWebsiteUrl = 'https://codecanyon.net/user/mrblab24/portfolio';
  final String iOSAppId = '0000000000';

  final String doneAsset = 'assets/done.json';
  final Color appColor = Colors.redAccent; //you can change your whole app color



  //Intro images
  final String introImage1 = 'assets/news1.png';
  final String introImage2 = 'assets/news6.png';
  final String introImage3 = 'assets/news7.png';

  
  //Language Setup

  final List<String> languages = [
    'English',
    'Spanish',
    'Arabic',
    'Marathi',
    'Hindi'
  ];






  //initial categories - 4 only (Hard Coded : which are added already on your admin panel)

  final List initialCategories = [
    'Entertainment',
    'Sports',
    'Politics',
    'Business'
  ];

  
  // Ads Setup

   //-- admob ads -- (you can use this ids for testing purposes)
  final String admobAppId = 'ca-app-pub-3081210400345123~8844137461';

  final String admobInterstitialAdIdAndroid = 'ca-app-pub-3081210400345123/4904892454';
  final String admobInterstitialAdIdiOS = 'ca-app-pub-3081210400345123/9390932377';

  final String admobBannerAdIdAndroid = 'ca-app-pub-3081210400345123/5800538705';
  final String admobBannerAdIdiOS = 'ca-app-pub-3081210400345123/4330177381';

  
  
  
  
  //fb ads (you can't use this ids)
  final String fbInterstitalAdIDAndroid = '54451484650202************';
  final String fbInterstitalAdIDiOS = '544514846502023_7023************';

  final String fbBannerAdIdAndroid = '544514846502023_7************';
  final String fbBannerAdIdiOS = '544514846502023_7023************';
}