import 'dart:io';

import 'package:afandim/helper/dialog_utils.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging;
  final Function(String) getToken;
  final BuildContext context;
  FirebaseNotifications({this.context, this.getToken});

  void setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging.instance;
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token) {
      getToken(token);
    });
    FirebaseMessaging.instance.subscribeToTopic("global");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {}

      print('on message $notification');
      AudioCache audioCache = AudioCache();
      try {
        await audioCache.play("sounds/goes_without_saying.mp3",
            isNotification: true);
        showCustomSuccessDialog(
          context,
          title: message.data["notification"]["title"],
          subtitle: message.data["notification"]["body"],
          isDismissible: false,
          positive: lang.api("OK"),
        );
      } on Exception catch (c) {
        print("exception: $c");
      }
    });
  }

  void iOSPermission() {
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);

    /// Todo
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {});
  }
}
