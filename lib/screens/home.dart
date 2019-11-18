import 'package:after_layout/after_layout.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../common/constants.dart';
import '../models/app.dart';
import '../models/category.dart';
import '../models/notification.dart';
import '../widgets/horizontal/index.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin<HomeScreen> {
 FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
   firebaseCloudMessagingListeners();
  }

 _saveMessage(message) {
   FStoreNotification a = FStoreNotification.fromJsonFirebase(message);
   a.saveToLocal(message['notification'] != null
       ? message['notification']['tag']
       : message['data']['google.message_id']);
 }

 void firebaseCloudMessagingListeners() {
   if (Platform.isIOS) iOSPermission();

   _firebaseMessaging.configure(
     onMessage: (Map<String, dynamic> message) => _saveMessage(message),
     onResume: (Map<String, dynamic> message) => _saveMessage(message),
     onLaunch: (Map<String, dynamic> message) => _saveMessage(message),
   );
 }

 void iOSPermission() {
   _firebaseMessaging.requestNotificationPermissions(
       IosNotificationSettings(sound: true, badge: true, alert: true));
   _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {});
 }

  @override
  void afterFirstLayout(BuildContext context) {
    Provider.of<CategoryModel>(context).getCategories();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print('build home screen');

    return Consumer<AppModel>(
      builder: (context, value, child) {
        if (value.appConfig == null) {
          return kLoadingWidget(context);
        }
        return HorizontalList(configs: value.appConfig);
      },
    );
  }
}
