import 'dart:io';

import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:asfiyahi/constants.dart';
import 'package:asfiyahi/model/api.dart';
import 'package:asfiyahi/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';

import 'RadioPlayerScreen.dart';


class RadioMenuScreen extends StatefulWidget {
  final Api radioItem;

  RadioMenuScreen({this.radioItem});

  @override
  _RadioPageState createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioMenuScreen>
    with AutomaticKeepAliveClientMixin<RadioMenuScreen> {
  @override
  bool get wantKeepAlive => true;
  final logger = Logger();
  List<Api> radioList = [];
  String radioName = "", radioFreq = "", radioImg, radioUrl;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    setState(() {
      radioList.add(widget.radioItem);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredBanner?.dispose();
  }
  BannerAd _anchoredBanner;
  bool _loadingAnchoredBanner = false;
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
  Widget build(BuildContext context) {
    super.build(context);
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return  Scaffold(
            body: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              /*gradient: LinearGradient(
                colors: [colorPrimaryClear, colorPrimary],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),*/
            ),
            child: Stack(
              children: [
                Container(
                  child: isLoading
                      ? makeShimmerItem()
                      : CustomScrollView(slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate([
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: radioList.length > 0 ? 10 : 0,
                              ),
                              radioList.length > 0
                                  ? radioListWidget(radioList)
                                  : Container()
                            ]),
                          ),
                        ]),
                ),
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
        );
  }

  Widget appBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              //width: 110,
              child: Row(
                children: [
                  Icon(
                    Icons.radio,
                    size: 30,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Radios",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/logo.png')))),
        ],
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorPrimaryClear, colorPrimary],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(10.0)),
      ),
      elevation: 1.0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget radioListWidget(List<Api> radioList) {
    return new Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int i) {
          return new GestureDetector(
            onTap: () {
              setState(() {
                Utils.navigationPage(
                    context,
                    RadioPlayerScreen(
                        radioItem: widget.radioItem),
                    true);
              });
            },
            child: FadeAnimation(
                0.5,
                Container(
                    width: 150,
                    height: 150,
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
                    margin: EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /*CachedNetworkImage(
                          imageUrl: radioList[position].logo,
                        ),*/
                        Image.asset("$imageUri/logofm.jpg",width: 90,height: 80,),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          radioList[i].title,
                          style: TextStyle(
                              color: colorPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )
                      ],
                    ))),
          );
        },
        itemCount: radioList.length,
      ),
    );
  }

  Widget makeShimmerItem() {
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
}
