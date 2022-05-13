import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:asfiyahi/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_api_v3/youtube_api_v3.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../constants.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  final YT_API video;
  final PlayListItem pVideo;
  final String related;
  final List<YT_API> ytResult;
  final List<PlayListItem> videos;

  YoutubeVideoPlayer(
      {this.related, this.ytResult, this.videos, this.video, this.pVideo});

  @override
  _YoutubePlayerState createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubeVideoPlayer> {
  YoutubePlayerController _controller;
  final logger = Logger();
  List<YT_API> ytResult = [];
  bool isLoading;
  List<PlayListItem> videos = [];
  String url, title, img, date;

  Future<void> callAPI() async {
    if (widget.video != null) {
      title = widget.video.title;
      url = widget.video.url;
      img = widget.video.thumbnail["medium"]["url"];
      date = widget.video.publishedAt;
    } else {
      title = widget.pVideo.snippet.title;
      url =
          "https://www.youtube.com/watch?v=${widget.pVideo.snippet.resourceId.videoId}";
      img = widget.pVideo.snippet.thumbnails.medium.url;
      date = widget.pVideo.snippet.publishedAt;
    }
    ytResult = widget.ytResult;
    videos = widget.videos;
    setState(() {
      print('UI Updated');
      //if (ytResult.length > 0) ytResult.removeAt(0);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
        initialVideoId:
            YoutubePlayer.convertUrlToId(widget.video.url.replaceAll(" ", "")),
        flags: YoutubePlayerFlags(
          controlsVisibleAtStart: false,
          autoPlay: true,
          hideThumbnail: true,
          mute: false,
        ));
    //widget.related != "" ? getVideos() : print("Oups");
    callAPI();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
        onExitFullScreen: () {
          // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        },
        onEnterFullScreen: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ]);
        },
        player: YoutubePlayer(
          controller: _controller,
          width: double.infinity,
        ),
        builder: (context, player) {
          return Scaffold(
              appBar: appBar(),
              body: Column(
                children: <Widget>[
                  /*Container(
                    height: 250,
                    width: double.infinity,
                    child: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      progressColors:
                          ProgressBarColors(bufferedColor: colorPrimary),
                      progressIndicatorColor: colorPrimary,
                      bottomActions: <Widget>[
                        IconButton(
                          padding: EdgeInsets.all(30.0),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _controller.toggleFullScreenMode();
                          },
                        ),
                      ],
                    ),
                  ),*/
                  player,
                  Container(
                    height: 70,
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: colorPrimary)),
                    child: Row(
                      children: <Widget>[
                        Image.network(
                          img,
                          height: 60,
                          width: 80,
                          fit: BoxFit.cover,
                          loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Image.asset(
                              "assets/images/logo.png",
                              fit: BoxFit.contain,
                              height: 120,
                              width: 120,
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                            return Image.asset(
                              "assets/images/logo.png",
                              fit: BoxFit.contain,
                              height: 120,
                              width: 120,
                            );
                          },
                        ),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: Container(
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: "CeraPro",
                                          fontWeight: FontWeight.bold,
                                          color: colorPrimary),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 7),
                                    child: Text(
                                      Jiffy(date, "yyyy-MM-ddTHH:mm:ssZ")
                                          .yMMMMEEEEdjm,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: "CeraPro",
                                          fontWeight: FontWeight.normal,
                                          color: colorPrimary.withOpacity(0.7)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  /*widget.related != ""
                  ? Expanded(
                      child: Container(
                      child: isLoading
                          ? Center(
                              child: makeShimmerVideos(),
                              //child: CircularProgressIndicator(),
                            )
                          : makeItemVideos(),
                    ))
                  : */
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      Strings.similarVideos,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: "CeraPro",
                          fontWeight: FontWeight.bold,
                          color: colorPrimary),
                    ),
                  ),
                  ytResult != null
                      ? Expanded(child: Container(child: makeItemYVideos()))
                      : videos != null
                          ? Expanded(child: Container(child: makeItemPVideos()))
                          : Container(),
                ],
              ));
        });
  }

  Widget makeItemYVideos() {
    return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              //childAspectRatio: 4 / 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10),
          physics: ClampingScrollPhysics(),
          itemBuilder: (context, position) {
            return FadeAnimation(
                0.5,
                Hero(
                  tag: ytResult[position].title,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        title = ytResult[position].title;
                        url = ytResult[position].url;
                        img = ytResult[position].thumbnail["medium"]["url"];
                        date = ytResult[position].publishedAt;
                        _controller.load(YoutubePlayer.convertUrlToId(
                            url.replaceAll(" ", "")));
                      });
                      /* Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => YoutubeVideoPlayer(
                                    url: ytResult[position].url,
                                    title: ytResult[position].title,
                                    img: ytResult[position].thumbnail['medium']
                                        ['url'],
                                    date: Jiffy(ytResult[position].publishedAt,
                                            "yyyy-MM-ddTHH:mm:ssZ")
                                        .yMMMMEEEEdjm,
                                    related: "",
                                    ytResult: ytResult,
                                  )),
                          (Route<dynamic> route) => true);*/
                    },
                    child: Container(
                        margin: EdgeInsets.only(left: 5, right: 5),
                        child: FadeAnimation(
                          0.5,
                          Column(
                            children: [
                              Stack(
                                children: [
                                  Image.network(
                              ytResult[position]
                                  .thumbnail['medium']['url'],
                                    height: 110,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                    loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Image.asset(
                                        "assets/images/logo.png",
                                        fit: BoxFit.contain,
                                        height: 120,
                                        width: 120,
                                      );
                                    },
                                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                      return Image.asset(
                                        "assets/images/logo.png",
                                        fit: BoxFit.contain,
                                        height: 120,
                                        width: 120,
                                      );
                                    },
                                  ),
                                  Container(
                                    height: 25,
                                    width: 30,
                                    color: colorPrimary,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                child: Flexible(
                                  child: Container(
                                    child: FadeAnimation(
                                        0.6,
                                        Container(
                                          alignment: Alignment.center,
                                          //height: 70,
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            ytResult[position].title,
                                            maxLines: 3,
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                ));
          },
          itemCount: 10,
        ));
  }

  Widget makeItemPVideos() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            //childAspectRatio: 4 / 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10),
        itemBuilder: (context, position) {
          return FadeAnimation(
              0.5,
              Hero(
                tag: new Text(videos[position].snippet.title),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      title = videos[position].snippet.title;
                      url = videos[position].snippet.resourceId.videoId;
                      img = videos[position].snippet.thumbnails.medium.url;
                      date = videos[position].snippet.publishedAt;
                    });
                    _controller.load(url);
                    print(
                        "https://www.youtube.com/watch?v=${videos[position].snippet.resourceId.videoId}");
                    /* Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => YoutubeVideoPlayer(
                                url:
                                    "https://www.youtube.com/watch?v=${videos[position].snippet.resourceId.videoId}",
                                title: videos[position].snippet.title,
                                img: videos[position]
                                    .snippet
                                    .thumbnails
                                    .medium
                                    .url,
                                date: Jiffy(
                                        videos[position].snippet.publishedAt,
                                        "yyyy-MM-ddTHH:mm:ssZ")
                                    .yMMMMEEEEdjm,
                                related: "",
                                videos: videos,
                              )),
                      (Route<dynamic> route) => true,
                    );*/
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: FadeAnimation(
                        0.5,
                        Column(
                          children: [
                            Stack(
                              children: [
                                Image.network(
                                  videos[position]
                                      .snippet
                                      .thumbnails
                                      .medium
                                      .url,
                                  height: 110,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                  loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Image.asset(
                                      "assets/images/logo.png",
                                      fit: BoxFit.contain,
                                      height: 120,
                                      width: 120,
                                    );
                                  },
                                  errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                    return Image.asset(
                                      "assets/images/logo.png",
                                      fit: BoxFit.contain,
                                      height: 120,
                                      width: 120,
                                    );
                                  },
                                ),
                                Container(
                                  height: 25,
                                  width: 30,
                                  color: colorPrimary,
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                            Container(
                              child: Flexible(
                                child: Container(
                                  child: FadeAnimation(
                                      0.6,
                                      Container(
                                        alignment: Alignment.center,
                                        //height: 70,
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          videos[position].snippet.title,
                                          maxLines: 3,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ));
        },
        itemCount: videos.length,
      ),
    );
  }

  Widget makeShimmerVideos() {
    return ListView.builder(
      itemBuilder: (context, position) {
        return FadeAnimation(
          0.5,
          Shimmer.fromColors(
              baseColor: Colors.grey[400],
              highlightColor: Colors.white,
              child: Container(
                height: 120.0,
                width: 200,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  //borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[400],
                      blurRadius: 10,
                      offset: Offset(0, 10.0),
                    ),
                  ],
                ),
              )),
        );
      },
      itemCount: 5,
    );
  }

  appBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            margin: EdgeInsets.only(right: 50),
            child: Image.asset("assets/images/logo.png"),
          )
        ],
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(color: colorPrimary
            /*borderRadius:
                  BorderRadius.circular(10.0)*/
            ),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
    );
  }
}
