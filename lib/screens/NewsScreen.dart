import 'dart:io';

import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:asfiyahi/model/api.dart';
import 'package:asfiyahi/model/newsrss.dart';
import 'package:asfiyahi/services/apiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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


class NewsScreen extends StatefulWidget {
  static int idpage = 0;
  final Api newsItem;
  NewsScreen({this.newsItem});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with AutomaticKeepAliveClientMixin<NewsScreen> {
  @override
  bool get wantKeepAlive => true;
  String linkNews = "";
  List<Newsrss> allitems = [];
  bool isLoading = false;
  final logger = Logger();

  BannerAd _anchoredBanner;
  bool _loadingAnchoredBanner = false;
  Future<void> getNewsItems() async {
    setState(() {
      isLoading = true;
    });
    final dio = Dio();
    final client = RestClient(dio, baseUrl: linkNews);
    client.getData().then((it) async {
      setState(() {
        logger.i(it.newsrss[0].feedUrl);
        getFeed(it.newsrss[0].feedUrl);
      });
    }).catchError((Object obj) {
      setState(() {
        isLoading = false;
      });
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          //if (res.statusCode == 500) {}
          logger.e("Got error : ${res.statusCode} -> ${res.statusMessage}");

          break;
        default:
      }
    });
  }

  List<RssItem> rssList = [];

  Future<void> getFeed(String url) async {
    // RSS feed
    var client = new http.Client();
    client.get(url).then((response) {
      return response.body;
    }).then((bodyString) {
      var channel = new RssFeed.parse(bodyString);
      rssList = channel.items;
      setState(() {
        isLoading = false;
      });
    });
  }
  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize size =
    await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: AdRequest(),
      adUnitId: Platform.isAndroid
          ? admobBanAndroid
          : admobBanIos,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    //Jiffy.locale("fr");
    linkNews = widget.newsItem.feedUrl;
    //getGroupVOD();
    getNewsItems();
  }
  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            title: new Text(appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary)),
            content: new Text(
              'Etes-vous sûr de vouloir fermer l\'application?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            actionsPadding: EdgeInsets.only(left: 10, right: 40),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  width: 90,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[800], Colors.blue],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(35)),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  child: Text(
                    "Annuler",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              new GestureDetector(
                onTap: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: Container(
                  width: 90,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[800], Colors.redAccent],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(35)),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  child: Text(
                    "Fermer",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
  @override
  void dispose() {
    super.dispose();
    _anchoredBanner?.dispose();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return new WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          body: Container(
            color: Colors.white,
            child: Stack(
              children: [
                RefreshIndicator(
                    child: Container(
                      margin: EdgeInsets.only(top: 10,bottom: _anchoredBanner != null?_anchoredBanner.size.height.toDouble()+4:0),
                      child: Row(
                        children: [
                          !isLoading
                              ? Expanded(
                                  child: CustomScrollView(
                                  slivers: [
                                    SliverList(
                                        delegate: SliverChildListDelegate([
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Text(
                                          "A la UNE",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      traitWidget(),
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
                    onRefresh: getNewsItems),
                if (_anchoredBanner != null)
                  Align(
                    child: Container(
                      color: Colors.white,
                      width: _anchoredBanner.size.width.toDouble(),
                      height: _anchoredBanner.size.height.toDouble(),
                      child: AdWidget(ad: _anchoredBanner),
                    ),
                    alignment: Alignment.bottomCenter,
                  )
              ],
            ),
          ),
        ),
        onWillPop: _onBackPressed);
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
                      photo: rssList[i]
                          .description
                          .split("src=")[1]
                          .split(" ")[0]
                          .replaceAll("\"", "")
                          .trim(),
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
                                  rssList[i].description!=null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            rssList[i]
                                                .description
                                                .split("src=")[1]
                                                .split(" ")[0]
                                                .replaceAll("\"", "")
                                                .trim(),
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
        itemCount: rssList.length > 40 ? 40 : rssList.length,
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
}
