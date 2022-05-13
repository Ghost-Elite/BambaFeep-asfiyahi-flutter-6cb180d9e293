import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_api/youtube_api.dart';

import '../constants.dart';
import 'youtubePlayer.dart';

class YoutubeVideoChannelScreen extends StatefulWidget {
  final List<YT_API> ytResult;
  final String apikey;
  YoutubeVideoChannelScreen({this.ytResult, this.apikey});

  @override
  _YoutubeChannelState createState() => new _YoutubeChannelState();
}

class _YoutubeChannelState extends State<YoutubeVideoChannelScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  YoutubeAPI ytApi;
  List<YT_API> ytResult = [];
  bool isLoading = true;

  Future<void> callAPI() async {
    ytResult=widget.ytResult;
    setState(() {
      print('UI Updated');
      ytResult.removeAt(0);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    ytApi = new YoutubeAPI(widget.apikey, maxResults: 50, type: "video");
    callAPI();
    //print('hello');
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
          decoration: BoxDecoration(
            color: colorPrimary
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
                              onTap: () {},
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
      margin: EdgeInsets.only(top: 10,bottom: 10),
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
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => YoutubeVideoPlayer(
                          video:ytResult[position],
                          /*url: ytResult[position].url,
                          title: ytResult[position].title,
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
          );
        },
        itemCount: ytResult.length,
      ),
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
}
