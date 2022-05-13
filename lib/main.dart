
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'constants.dart';
import 'screens/Splashscreen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    title: appName,
    theme: new ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: "CeraPro",
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      }),
    ),
    home: new SplashScreen(),
  ));

}
