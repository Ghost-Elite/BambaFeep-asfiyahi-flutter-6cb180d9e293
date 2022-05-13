import 'dart:async';
import 'package:asfiyahi/constants.dart';
import 'package:asfiyahi/model/api_response.dart';
import 'package:asfiyahi/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:asfiyahi/model/api.dart';
import 'package:asfiyahi/services/apiService.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';

import 'HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<SplashScreen> {
  final logger = Logger();
  List<Api> allData = [];
  ApiResponse apiResponse;
  VideoPlayerController playerController;
  VoidCallback listener;

  Future<void> getApi() async {
    logger.i("test");
    final dio = Dio();
    final client = RestClient(dio);
    client.getAppDetails().then((it) async {
      apiResponse = it;
      navigationPage();
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          internetProblem();
          /*if (res.statusCode == 500) {}*/
          logger.e("Got error : ${res.statusCode} -> ${res.statusMessage}");

          break;
        default:
      }
    });
  }


  Future<bool> internetProblem() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            title: new Text('Asfiyahi',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26,
                    fontFamily: "CeraPro",
                    fontWeight: FontWeight.bold,
                    color: colorPrimary)),
            content: new Text(
              "Problème d\'accès à Internet, veuillez vérifier votre connexion et réessayez !!!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "CeraPro",
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => SplashScreen()));
                    },
                    child: Container(
                      width: 120,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorPrimary, colorPrimaryDark],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                          borderRadius: BorderRadius.circular(35)),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      child: Text(
                        "Réessayer",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: "CeraPro",
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ) ??
        false;
  }

  @override
  void initState() {

    super.initState();
    listener = () {
      setState(() {
      });
    };
    //playerController.play();
    ///video splash display only 5 second you can change the duration according to your need
    startTime();
    initializeVideo();
  }
  void initializeVideo() {
    playerController =
    VideoPlayerController.asset('$videosUri/splash.mp4')
      ..addListener(listener)
      ..setVolume(1.0)
      ..initialize()
      ..play();
  }
  startTime() async {

    var _duration = new Duration(seconds: 6);
    return new Timer(_duration, getApi);
  }
  @override
  void deactivate() {
    if (playerController != null) {
      playerController.setVolume(0.0);
      playerController.removeListener(listener);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (playerController != null) playerController.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return new Stack(
        fit: StackFit.expand, children: <Widget>[
      new AspectRatio(
          aspectRatio: 10 / 16,
          child: Container(
            color: Colors.white,
            child: (playerController != null
                ? VideoPlayer(
              playerController,
            )
                : Container()),
          )),
    ]);
  }

  void navigationPage() {
    playerController.setVolume(0.0);
    playerController.removeListener(listener);
    Utils.navigationPage(context, HomeScreen(
      apiResponse: apiResponse,
    ), false);
  }
}
