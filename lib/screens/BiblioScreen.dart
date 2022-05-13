import 'dart:io';

import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:asfiyahi/model/api.dart';
import 'package:asfiyahi/model/newsrss.dart';
import 'package:asfiyahi/screens/BiblioDetailsScreen.dart';
import 'package:asfiyahi/services/apiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import '../constants.dart';
import '../utils/utils.dart';
import 'YoutubeChannelScreen.dart';

class BiblioScreen extends StatefulWidget {
  static int idpage = 0;
  final Api biblioItem;
  final String apiKey,channelId;

  BiblioScreen({this.biblioItem, this.apiKey, this.channelId});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<BiblioScreen>
    with AutomaticKeepAliveClientMixin<BiblioScreen> {
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
        it.newsrss.removeAt(0);
        allitems = it.newsrss;
        allitems.add(new Newsrss(title: "Youtube",sdimage: "youtube.png",feedUrl: ""));
        //allitems.add(new Newsrss(title: "Facebook",sdimage: "facebook.png",feedUrl: ""));
        allitems[0].sdimage="islam.png";
        allitems[1].sdimage="ramadan.png";
        allitems[2].sdimage="tidjaniya.png";
        allitems[3].sdimage="portraits.png";
        allitems[4].sdimage="causerie.png";
        isLoading = false;
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

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    //Jiffy.locale("fr");
    linkNews = widget.biblioItem.feedUrl;
    //getGroupVOD();
    getNewsItems();
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
  void dispose() {
    super.dispose();
    _anchoredBanner?.dispose();
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
                                      allitems.length > 0
                                          ? biblioWidget()
                                          : Container(
                                              height: 200,
                                              padding: EdgeInsets.all(20),
                                              child: Center(
                                                  child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.build_circle_outlined,
                                                    size: 70,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "La rubrique biblothéque est en cours de maintenance.",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                ],
                                              )),
                                            ),
                                      /*rssList.length > 0
                                          ? moreButtonWidget("actu")
                                          : Container(),*/
                                    ]))
                                  ],
                                ))
                              : Expanded(
                                  child: makeShimmerItem(),
                                ),
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
      link = "Télécharger l'application $appName sur AppStore : $appStoreLink";
    } else {
      link =
          "Télécharger l'application $appName sur PlayStore : $playStoreLink";
    }
    WcFlutterShare.share(
        sharePopupTitle: 'Partager via', text: link, mimeType: 'text/plain');
  }

  biblioWidget() {
    return Container(
      child: GridView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            //childAspectRatio: 4 / 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, i) {
          return FadeAnimation(
            0.5,
            GestureDetector(
              onTap: () {
                if(i==5){
                  Utils.navigationPage(context, YoutubeChannelScreen(channelId: widget.channelId,apiKey:widget.apiKey ,), true);
                }else if(i==6){

                }else{
                  Utils.navigationPage(
                      context,
                      BiblioDetailsScreen(newsItem: allitems[i]),
                      true);
                }
              },
              child: Container(
                  margin: EdgeInsets.all( 10),
                  child: FadeAnimation(
                      0.5,
                      Container(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: colorPrimary,
                                blurRadius: 1.5,
                                spreadRadius: 0.5),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: allitems[i].sdimage!=""?Image.asset(
                                "$imageUri/${allitems[i].sdimage}",
                                fit: BoxFit.contain,
                                height: 75,
                                width: 75,
                              ):Image.asset(
                                "$imageUri/logo.png",
                                fit: BoxFit.contain,
                                height: 100,
                                width: 100,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                child: FadeAnimation(
                                    0.6,
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        allitems[i].title,
                                        maxLines: 3,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ))),
                          ],
                        ),
                      ))),
            ),
          );
        },
        itemCount: allitems.length,
      ),
    );
  }

  Widget makeShimmerItem() {
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
      itemCount: 8,
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
