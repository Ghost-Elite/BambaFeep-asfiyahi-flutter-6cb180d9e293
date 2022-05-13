import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_api_v3/youtube_api_v3.dart';

import '../constants.dart';
import 'youtubePlayer.dart';

class PlayListVideoScreen extends StatefulWidget {
  PlayListVideoScreen({Key key, this.title, this.apiKey}) : super(key: key);

  final String title, apiKey;

  @override
  _PlayListVideoState createState() => _PlayListVideoState();
}


class _PlayListVideoState extends State<PlayListVideoScreen> {
  List<PlayListItem> videos = [];
  PlayListItemListResponse currentPage;
  bool isLoading = true;
  final logger = new Logger();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    getVideos();
  }

  setVideos(videos) {
    setState(() {
      this.videos = videos;
      isLoading = false;
    });
  }

  Future<void> getVideos() async {
    YoutubeAPIv3 api = new YoutubeAPIv3(widget.apiKey);

    PlayListItemListResponse playlist = await api.playListItems(
        playlistId: widget.title, maxResults: 50, part: Parts.snippet);
    if (playlist.items!=null) {
      var videos = playlist.items.map((video) {
        return video;
      }).toList();
      logger.i(videos.length);
      currentPage = playlist;
      this.videos.clear();
      for (int i = 0; i < videos.length; i++) {
        if (videos[i].snippet.title != "Deleted video") {
          this.videos.add(videos[i]);
        }
      }
      logger.i(this.videos.length);
      setVideos(this.videos);
    }else{
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> nextPage() async {
    PlayListItemListResponse playlist = await currentPage.nextPage();
    var videos = playlist.items.map((video) {
      return video;
    }).toList();
    currentPage = playlist;
    this.videos.addAll(videos);
    setVideos(this.videos);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 80,
                height: 80,
                margin: EdgeInsets.only(right: 50),
                child: Image.asset('assets/images/logo.png')),
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
      ),
      body: new Container(
          child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: getVideos,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: isLoading
                              ? Center(
                                  child: makeShimmerVideos(),
                                  //child: CircularProgressIndicator(),
                                )
                              : makeItemVideos(),
                        ),
                        /*Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: Image.asset(
                                  "$imageUri/ic_voir_plus.png",
                                  height: 40,
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                              onTap: (){

                              },
                            )
                          ],
                        ),*/
                      ],
                    ),
                  ),
                ],
              ))),
    );
  }

  Widget makeItemVideos() {
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
                    print(
                        "https://www.youtube.com/watch?v=${videos[position].snippet.resourceId.videoId}");
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => YoutubeVideoPlayer(

                            pVideo: videos[position],
                               /* url:
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
                                    .yMMMMEEEEdjm,*/
                                related: "",
                                videos: videos,
                              )),
                      (Route<dynamic> route) => true,
                    );
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
                                          textAlign: TextAlign.center,
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
    return GridView.builder(
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
                  borderRadius: BorderRadius.circular(20),
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
}

// ignore: must_be_immutable
class AllPlayListScreen extends StatefulWidget {
  List<YT_APIPlaylist> ytResult = [];
  final String apikey;

  AllPlayListScreen({this.ytResult, this.apikey});

  @override
  _AllPlayListState createState() => _AllPlayListState();
}

class _AllPlayListState extends State<AllPlayListScreen> {
  //String apiKey="AIzaSyAS-pv77K2uUCChBG5I_prIxJxhyt-sDAg";
  bool isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<YT_APIPlaylist> ytResultPlaylist = [];

  Future<void> callAPI() async {
    /*print('UI callled');
    String query = "Dakaractu TV HD";
    await Jiffy.locale("fr");
    ytResult = await ytApi.search(query);*/
    ytResultPlaylist = widget.ytResult;
    setState(() {
      print('UI Updated');
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    callAPI();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 80,
                height: 80,
                margin: EdgeInsets.only(right: 50),
                child: Image.asset('assets/images/logo.png')),
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
      ),
      body: new Container(
          child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: callAPI,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          child: isLoading
                              ? Center(
                                  child: makeShimmerEmissions(),
                                  //child: CircularProgressIndicator(),
                                )
                              : makeItemEmissions(),
                        ),
                        /*Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                width: 120,
                                height: 50,
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xff2CA3E1),
                                        Color(0xff5D20C1)
                                      ],
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(35)),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  "Voir Plus +",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "CeraPro",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PlayListVideoScreen()),
                                    ModalRoute.withName('/'));
                              },
                            )
                          ],
                        ),*/
                      ],
                    ),
                  ),
                ],
              ))),
    );
  }

  Widget makeItemEmissions() {
    return ListView.builder(
      shrinkWrap: true,
      /*gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),*/
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, position) {
        return FadeAnimation(
          0.5,
          GestureDetector(
            onTap: () {
              print(ytResultPlaylist[position]
                  .url);
              print(ytResultPlaylist[position]
                  .url
                  .replaceAll("https://www.youtube.com/playlist?list=", ""));
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => PlayListVideoScreen(
                            title: ytResultPlaylist[position].id,
                            apiKey: widget.apikey,
                          )),
                  (Route<dynamic> route) => true);
            },
            child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[400],
                      blurRadius: 10,
                      offset: Offset(0, 10.0),
                    ),
                  ],
                ),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FadeAnimation(
                          0.5,
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 130,
                            //alignment: Alignment.center,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                ClipRRect(
                                  //borderRadius: BorderRadius.circular(20),
                                  child:
                                  Image.network(
                                    ytResultPlaylist[position]
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
                                ),
                                Flexible(
                                  child: FadeAnimation(
                                      0.6,
                                      Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          ytResultPlaylist[position].title.trim(),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PlayListVideoScreen(
                                                  title: ytResultPlaylist[
                                                          position]
                                                      .url
                                                      .replaceAll(
                                                          "https://www.youtube.com/playlist?list=",
                                                          ""),
                                                  apiKey: widget.apikey,
                                                )),
                                        (Route<dynamic> route) => true);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.playlist_play,
                                      size: 40,
                                      color: colorPrimary,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                )),
          ),
        );
      },
      itemCount: ytResultPlaylist.length,
    );
  }

  Widget makeShimmerEmissions() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, position) {
        return FadeAnimation(
          0.5,
          Shimmer.fromColors(
              baseColor: Colors.grey[400],
              highlightColor: Colors.white,
              child: Container(
                height: 240.0,
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
      itemCount: 10,
    );
  }
}
