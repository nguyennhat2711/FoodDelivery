import 'package:afandim/core/viewmodel/general_viewmodel.dart';
import 'package:afandim/helper/app_builder.dart';
import 'package:afandim/helper/global_translations.dart';
import 'package:afandim/helper/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_villains/villains/villains.dart';
import 'package:get/get.dart';

import 'helper/constance.dart';
import 'helper/global_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // SharedPreferences.setMockInitialValues({});

  // FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  /// TODO : DELETE THIS LINE
  /// here we will check if code is FirebaseCrashlytics worked
  // FirebaseCrashlytics.instance.crash();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read(generalProvider);

    print(lang.supportedLocales());
    print(lang.locale);
    print('lang.supportedLocales');
    return AppBuilder(builder: (context) {
      return GetMaterialApp(
        navigatorObservers: [VillainTransitionObserver()],
        debugShowCheckedModeBanner: false,
        builder: (BuildContext context, Widget child) {
          return Directionality(
            textDirection: lang.currentLanguage == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Builder(
              builder: (BuildContext context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: child,
                );
              },
            ),
          );
        },
        locale: lang.locale,
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: lang.supportedLocales(),
        theme: ThemeData(
          appBarTheme: AppBarTheme(color: primaryColor),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: "MyriadPro",
          primaryColorBrightness: Brightness.dark,
          primaryColor: primaryColor,
          primaryColorDark: primaryColor,
          primaryColorLight: primaryColor,
          accentColor: secondaryColor,
          iconTheme: IconThemeData(
            color: Color(0xFF89db67),
          ),
          dividerColor: Color(0xFFBDBDBD),
        ),
        routes: routes,
      );
    });
  }
}
