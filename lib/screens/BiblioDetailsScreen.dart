import 'dart:io';

import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:asfiyahi/model/newsrss.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:webfeed/webfeed.dart';

import '../constants.dart';
import '../utils/utils.dart';
import 'ActuScreen.dart';


class BiblioDetailsScreen extends StatefulWidget {
  static int idpage = 0;
  final Newsrss newsItem;
  BiblioDetailsScreen({this.newsItem});

  @override
  _BiblioDetailsScreenState createState() => _BiblioDetailsScreenState();
}

class _BiblioDetailsScreenState extends State<BiblioDetailsScreen> with AutomaticKeepAliveClientMixin<BiblioDetailsScreen> {
  @override
  bool get wantKeepAlive => true;
  String linkNews = "";
  List<Newsrss> allitems = [];
  bool isLoading = false;
  final logger = Logger();

  List<RssItem> rssList = [];

  Future<void> getFeed() async {
    // RSS feed
    setState(() {
      isLoading = true;
    });
    var client = new http.Client();
    client.get(linkNews).then((response) {
      return response.body;
    }).then((bodyString) {
      var channel = new RssFeed.parse(bodyString);
      rssList = channel.items;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    //Jiffy.locale("fr");
    linkNews = widget.newsItem.feedUrl;
    logger.i('ghost-eliet',linkNews);
    //getGroupVOD();
    getFeed();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            RefreshIndicator(
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      !isLoading
                          ? Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                  delegate: SliverChildListDelegate([
                                    rssList.length > 0
                                        ? lastNewsWidget()
                                        : Container(
                                      height: 200,
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                          child: Column(
                                            children: [
                                              Icon(Icons.build_circle_outlined,size: 70,),
                                              SizedBox(height: 10,),
                                              Text(
                                                "La rubrique actualité est en cours de maintenance.",
                                                textAlign: TextAlign.center,
                                                style:
                                                TextStyle(fontSize: 20),
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                    /*rssList.length > 0
                                          ? moreButtonWidget("actu")
                                          : Container(),*/
                                  ]))
                            ],
                          ))
                          : makeShimmerItem(),
                    ],
                  ),
                ),
                onRefresh: getFeed),
          ],
        ),
      ),
    );
  }

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  openShare() async {
    String link;
    if (Platform.isIOS) {
      link =
          "Télécharger l'application $appName sur AppStore : $appStoreLink";
    } else {
      link =
          "Télécharger l'application $appName sur PlayStore : $playStoreLink";
    }
    WcFlutterShare.share(
        sharePopupTitle: 'Partager via', text: link, mimeType: 'text/plain');
  }


  lastNewsWidget() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, i) {

          return FadeAnimation(
            0.5,
            GestureDetector(
              onTap: () {
                Utils.navigationPage(
                    context,
                    ActuScreen(
                      desc: rssList[i].content!=null?rssList[i].content.value:rssList[i].description,
                      title: rssList[i].title,
                      photo: rssList[i].image.toString(),
                      link: rssList[i].link,
                    ),
                    true);
              },
              child: Container(
                  margin: EdgeInsets.only(left: 10, right: 5),
                  child: Container(
                    width: 200,
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
                                children: <Widget>[
                                  rssList[i].description.contains("<img")
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child:
                                          Image.network(
                                            rssList[i].image.toString().replaceAll("imagette", "default"),
                                            height: 120,
                                            width: 150,
                                            fit: BoxFit.cover,
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
                                          ),
                                        )
                                      : Image.asset(
                                          "assets/images/logo.png",
                                          fit: BoxFit.contain,
                                          height: 100,
                                          width: 100,
                                        ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Flexible(
                                      child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        child: FadeAnimation(
                                            0.6,
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              //height: 70,
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                rssList[i].title,
                                                maxLines: 3,
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            )),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            bottom: 15),
                                        child: FadeAnimation(
                                            0.6,
                                            Row(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.date_range,color: colorPrimary,size: 15,),
                                                    SizedBox(width: 5,),
                                                    Container(
                                                      child: Text(
                                                        Jiffy(rssList[i].pubDate,
                                                            "EEE, dd MMM yyyy HH:mm:ssZ")
                                                            .format("dd-MM-yyyy"),
                                                        maxLines: 1,
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                            FontWeight.normal,
                                                            color: Colors.black54),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(width: 10,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.access_time_outlined,color: colorPrimary,size: 15,),
                                                    SizedBox(width: 5,),
                                                    Container(
                                                      child: Text(
                                                        Jiffy(rssList[i].pubDate,
                                                            "EEE, dd MMM yyyy HH:mm:ssZ")
                                                            .format("HH:mm"),
                                                        maxLines: 1,
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                            FontWeight.normal,
                                                            color: Colors.black54),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            )),
                                      )
                                    ],
                                  ))
                                ],
                              ),
                            )),
                        Divider(
                          height: 0,
                        ),
                      ],
                    ),
                  )),
            ),
          );
        },
        itemCount: rssList.length > 12 ? 12 : rssList.length,
      ),
    );
  }

  Widget makeShimmerItem() {
    return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, position) {
              return FadeAnimation(
                0.5,
                Container(
                    margin: EdgeInsets.only(left: 10, right: 5),
                    child: Container(
                      width: 180,
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
                                  children: <Widget>[
                                    Shimmer.fromColors(
                                        baseColor: Colors.grey[400],
                                        highlightColor: Colors.white,
                                        child: Container(
                                          height: 90.0,
                                          width: 100,
                                          padding: EdgeInsets.all(20),
                                          margin: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Shimmer.fromColors(
                                                baseColor: Colors.grey[400],
                                                highlightColor: Colors.white,
                                                child: Container(
                                                  height: 10.0,
                                                  margin: EdgeInsets.only(
                                                      top: 10,
                                                      bottom: 10,
                                                      right: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    //borderRadius: BorderRadius.circular(20),
                                                  ),
                                                )),
                                            Shimmer.fromColors(
                                                baseColor: Colors.grey[400],
                                                highlightColor: Colors.white,
                                                child: Container(
                                                  height: 10.0,
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    //borderRadius: BorderRadius.circular(20),
                                                  ),
                                                )),
                                            Shimmer.fromColors(
                                                baseColor: Colors.grey[400],
                                                highlightColor: Colors.white,
                                                child: Container(
                                                  height: 10.0,
                                                  margin: EdgeInsets.only(
                                                      top: 10,
                                                      bottom: 10,
                                                      right: 100),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    //borderRadius: BorderRadius.circular(20),
                                                  ),
                                                )),
                                          ],
                                        ),
                                        Shimmer.fromColors(
                                            baseColor: Colors.grey[400],
                                            highlightColor: Colors.white,
                                            child: Container(
                                              height: 10.0,
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                //borderRadius: BorderRadius.circular(20),
                                              ),
                                            )),
                                      ],
                                    ))
                                  ],
                                ),
                              )),
                          Divider(
                            height: 0,
                          ),
                        ],
                      ),
                    )),
              );
            },
            itemCount: 6));
  }

  traitWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Stack(
        children: [
          Container(
            height: 5,
            width: 120,
            color: Colors.green,
          ),
          Container(
            height: 2,
            color: Colors.green,
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }
  appBar() {
    return AppBar(
      title: Text(widget.newsItem.title,style: TextStyle(fontSize: 22),),
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
