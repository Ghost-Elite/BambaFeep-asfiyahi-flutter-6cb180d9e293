import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants.dart';

class ActuScreen extends StatefulWidget {
  final String desc, title, photo, link;

  ActuScreen({this.desc, this.title, this.photo, this.link});

  @override
  _ActuScreenState createState() => _ActuScreenState();
}

class _ActuScreenState extends State<ActuScreen>
    with AutomaticKeepAliveClientMixin<ActuScreen> {
  @override
  bool get wantKeepAlive => true;
  WebViewController _controller;
  YoutubePlayerController youtubePlayerController;
  String viewport =
      '<head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>';
  bool isYoutube = false;
  String videoId = "";
  final logger = Logger();
  String filename;

  @override
  void initState() {
    super.initState();

    List<String> tab = widget.desc.split('Partager sur');
    String val;
    logger.i(tab.length);
    if(tab.length>1){
      val=tab[1];
    }
    logger.i(val);
    if (val != null)
      filename =
          widget.desc.replaceAll(val, "").replaceAll('Partager sur', "");
    else
      filename = widget.desc;
    if (filename.contains("<iframe")) {
      if (filename
          .split("<iframe")[1]
          .contains("src=\"https://www.youtube.com/")) {
        videoId = filename
            .split("<iframe")[1]
            .split("src=")[1]
            .split(" ")[0]
            .replaceAll("https://www.youtube.com/embed/", "");
        //print(videoId);
        isYoutube = true;
        youtubePlayerController = YoutubePlayerController(
            initialVideoId: videoId.replaceAll("\"", ""),
            flags: YoutubePlayerFlags(
              controlsVisibleAtStart: true,
              autoPlay: false,
              mute: false,
            ));
        // print(videoId.replaceAll("\"", ""));
      }
    }
  }

  Future<void> loadHtmlFromAssets(String filename, controller) async {
    //String fileText = await rootBundle.loadString(filename);
    String fileText = filename;
    if (filename.contains("<img")) {
      fileText = filename.replaceAll(
          "<img" + filename.split("<img")[1].split("/>")[0] + "/>", "");
    }
    if (filename.contains("<iframe")) {
      if (filename
          .split("<iframe")[1]
          .contains("src=\"https://www.youtube.com/")) {
        fileText = filename.replaceAll(
            "<iframe" +
                filename.split("<iframe")[1].split("</iframe>")[0] +
                "</iframe>",
            "");
      }
    }
    controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  openShare(String linkUrl) async {
    String link;
    if (Platform.isIOS) {
      link = widget.title + "| via RTS News\n" + linkUrl;
    } else {
      link = widget.title + "| via RTS News\n" + linkUrl;
    }
    WcFlutterShare.share(
        sharePopupTitle: 'Partagez via', text: link, mimeType: 'text/plain');
  }

  @override
  void dispose() {
    super.dispose();

    if (youtubePlayerController != null) youtubePlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 60,
                  margin: EdgeInsets.fromLTRB(5, 10, 60, 5),
                  padding: EdgeInsets.all(7),
                  child: Image.asset('assets/images/logo.png'),
                  )
            ],
          ),
          centerTitle: true,
          flexibleSpace: Container(
            width: double.infinity,
          ),
          elevation: 0.0,
          backgroundColor: colorPrimary,
        ),
        body: FutureBuilder<bool>(
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        logger.i("Snapshot = ${snapshot.hasData}");
        return Container(
          // ignore: unrelated_type_equality_checks
          margin: snapshot.hasData
              ? EdgeInsets.only(bottom: 90)
              : EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: isYoutube?280:280),
                child: WebView(
                  initialUrl: "",
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureRecognizers: <
                      Factory<OneSequenceGestureRecognizer>>{
                    Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer(),
                    ),
                  },
                  onWebViewCreated:
                      (WebViewController webViewController) async {
                    _controller = webViewController;
                    if (Platform.isIOS)
                      await loadHtmlFromAssets(
                          viewport + filename, _controller);
                    else
                      await loadHtmlFromAssets(filename, _controller);
                  },
                ),
              ),
              Container(
                width: double.infinity,
                height: isYoutube
                    ?200:200,
                color: Colors.white,
                //padding: EdgeInsets.all(10),
                child: ClipRRect(
                  //borderRadius: BorderRadius.circular(15.0),
                    child: isYoutube
                        ? YoutubePlayer(
                      controller: youtubePlayerController,
                      showVideoProgressIndicator: true,
                      progressColors: ProgressBarColors(
                          bufferedColor: colorPrimary),
                      progressIndicatorColor: colorPrimary,
                    )
                        : Image.network(
                      widget.photo.replaceAll("imagette", "default"),
                      fit: BoxFit.fill,
                      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Image.asset(
                          "assets/images/logo.png",
                          fit: BoxFit.contain,
                          height: 100,
                          width: 100,
                        );
                      },
                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                        return Image.asset(
                          "assets/images/logo.png",
                          fit: BoxFit.contain,
                          height: 100,
                          width: 100,
                        );
                      },
                    ),),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: isYoutube?200:200, bottom: 10),
                //alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary),
                ),
              ),
            ],
          ),
        );
      },
    ));
  }
}
