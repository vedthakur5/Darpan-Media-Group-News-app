
class Config{
  final String appName = 'Darpan'; //app name
  final String testerPassword = 'tester12345';  //testing password - don't use this password in the database (you can change this testing password too)

  //firebase server token for push notication
  final String serverToken = 'AAAAODTJr5s:APA91bEkAZp1-J21pdVkqQ3eEbMmpnAb1TkfG8GS_tR8-jpzq6nOHxVPpYM-0lnSYUce_4YWK61BO2ybf74ou8IRSs1vuwarB643QD8u7HB5aCZ74fcohg8MZTBl-N9_kf1gKiB9vOl8';
  final String icon = 'assets/images/icon.png'; // app icon

  
  
  
  //don't edit or remove this
  final List contentTypes = [
    'image',
    'video'
  ];
}