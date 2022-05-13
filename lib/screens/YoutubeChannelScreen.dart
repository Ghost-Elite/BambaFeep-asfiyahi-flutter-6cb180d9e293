import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_api/youtube_api.dart';

import '../constants.dart';
import 'YoutubePlayer.dart';
import 'YoutubePlaylistScreen.dart';
import 'YoutubeVideoChannelScreen.dart';

class YoutubeChannelScreen extends StatefulWidget {
  final String apiKey,channelId;

  YoutubeChannelScreen({Key key, this.apiKey, this.channelId}) : super(key: key);

  @override
  _YoutubeChannelState createState() => new _YoutubeChannelState();
}

class _YoutubeChannelState extends State<YoutubeChannelScreen> with AutomaticKeepAliveClientMixin<YoutubeChannelScreen> {
  @override
  bool get wantKeepAlive => true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  YoutubeAPI ytApi;
  YoutubeAPI ytApiPlaylist;
  List<YT_API> ytResult = [];
  List<YT_APIPlaylist> ytResultPlaylist = [];
  bool isLoading = true;
  bool isLoadingPlaylist = true;
  //String query = "JoyNews";

  Future<void> callAPI() async {
    print('UI callled');
    //await Jiffy.locale("fr");
    ytResult = await ytApi.channel(widget.channelId);
    setState(() {
      print('UI Updated');
      isLoading = false;
      callAPIPlaylist();
    });
  }

  Future<void> callAPIPlaylist() async {
    print('UI callled');
    //await Jiffy.locale("fr");
    ytResultPlaylist = await ytApiPlaylist.playlist(widget.channelId);
    setState(() {
      print('UI Updated');
      print(ytResultPlaylist[0].title);
      isLoadingPlaylist = false;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    ytApi = new YoutubeAPI(widget.apiKey, maxResults: 50, type: "video");
    ytApiPlaylist =
    new YoutubeAPI(widget.apiKey, maxResults: 50, type: "playlist");
    callAPI();
    //print('hello');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      appBar: appBar(),
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
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Nouveautés",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: "CeraPro",
                                fontWeight: FontWeight.bold,
                                color: colorPrimary),
                          ),
                        ),
                        traitWidget(),
                        Container(
                          child: isLoading
                              ? Center(
                                  child: makeShimmerVideos(),
                                  //child: CircularProgressIndicator(),
                                )
                              : makeItemVideos(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(right: 10),
                                child: Text(
                                  "Voir Plus...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                  ),
                                )
                              ),
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            YoutubeVideoChannelScreen(ytResult: ytResult,apikey: widget.apiKey,)),
                                        (Route<dynamic> route) => true);
                              },
                            )
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Nos Playlists",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: "CeraPro",
                                fontWeight: FontWeight.bold,
                                color: colorPrimary),
                          ),
                        ),
                        traitWidget(),
                        Container(
                          child: isLoadingPlaylist
                              ? Center(
                                  child: makeShimmerEmissions(),
                                  //child: CircularProgressIndicator(),
                                )
                              : makeItemEmissions(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(right: 10),
                                  child: Text(
                                    "Voir Plus...",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )
                              ),
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AllPlayListScreen(ytResult: ytResultPlaylist,apikey:widget.apiKey)),
                                        (Route<dynamic> route) => true);
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  /* SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    delegate: SliverChildListDelegate(
                      [
                        Container(

                          child: isLoadingPlaylist
                              ? Center(
                            child: makeShimmerEmissions(),
                            //child: CircularProgressIndicator(),
                          )
                              : makeItemEmissions(),
                        ),
                      ]
                    ),
                  )*/
                ],
              ))),
    );
  }

  Widget makeItemVideos() {
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
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => YoutubeVideoPlayer(
                                video: ytResult[position],
                               /* title: ytResult[position].title,
                                img: ytResult[position].thumbnail['medium']
                                    ['url'],
                                date: Jiffy(ytResult[position].publishedAt,
                                        "yyyy-MM-ddTHH:mm:ssZ")
                                    .yMMMMEEEEdjm,*/
                                related: "",
                                ytResult: ytResult,
                              )),
                          (Route<dynamic> route) => true);
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
                                ytResult[position].thumbnail['medium']
                                ['url'],
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
            );
      },
      itemCount: ytResult.length>8?8:ytResult.length,
    );
  }

  Widget makeShimmerVideos() {
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
                  height: 160.0,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(10),
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
        itemCount: 6);
  }

  Widget makeItemEmissions() {
    return ListView.builder(
      shrinkWrap: true,
     /* gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),*/
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, position) {
        return FadeAnimation(
            0.5,
            Hero(
              tag: new Text(ytResultPlaylist[position].url.replaceAll("https://www.youtube.com/playlist?list=", "")),
              child: GestureDetector(
                onTap: () {

                  Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => PlayListVideoScreen(
                                  title: ytResultPlaylist[position].id,apiKey: widget.apiKey,)),
                        (Route<dynamic> route) => true,);
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
                                height: 110,
                                //alignment: Alignment.center,
                                child: new Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    ClipRRect(
                                      //borderRadius: BorderRadius.circular(20),
                                      child:
                                      Image.network(
                                        ytResultPlaylist[position].thumbnail["medium"]["url"],
                                        height: 110,
                                        width: 150,
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
                                              ytResultPlaylist[position].title,
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
                                              builder: (context) => PlayListVideoScreen(
                                                title: ytResultPlaylist[position].url.replaceAll("https://www.youtube.com/playlist?list=", ""),apiKey: widget.apiKey,)),
                                              (Route<dynamic> route) => true,);
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
            ));
      },
      itemCount: 6,
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
                  height: 160.0,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(10),
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
        itemCount: 6);
  }
  Widget appBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 80,
              height: 50,
              margin: EdgeInsets.only(right: 50),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/logo.png')))),
        ],
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorPrimary, colorPrimary],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
        ),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
    );
  }
  traitWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Stack(
        children: [
          Container(
            height: 5,
            width: 120,
            color: Colors.grey,
          ),
          Container(
            height: 2,
            color: Colors.grey,
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }
}
