import 'dart:io';

import 'package:asfiyahi/constants.dart';
import 'package:asfiyahi/model/api_response.dart';
import 'package:asfiyahi/screens/BiblioScreen.dart';


import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import 'NewsScreen.dart';
import 'RadioMenuScreen.dart';
import 'TVMenuScreen.dart';

class HomeScreen extends StatefulWidget {
  final ApiResponse apiResponse;
  static int idpage = 0;

  HomeScreen({
    this.apiResponse,
  });

  @override
  _HomeState createState() => _HomeState();
}

enum AppState { idle, connected, mediaLoaded, error }
const int maxFailedLoadAttempts = 3;
class _HomeState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;
  String title = "Accueil";
  InterstitialAd _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int isShow = 0;
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _createInterstitialAd();
  }
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: InterstitialAd.testAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd.setImmersiveMode(true);
            _showInterstitialAd();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }
  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  void pageChanged(int index) {
    setState(() {
      _page = index;
    });
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
        HomeScreen.idpage = index;
        /*if (index == 0) {
          title = "Accueil";
        } else*/
        if (index == 0) {
          title = "Actu";
        } else if (index == 1) {
          title = "Asfiyahi TV";
        } else if (index == 2) {
          title = "Asfiyahi FM";
        }else if (index == 3) {
          title = "Rubriques";
        }
      },
      children: <Widget>[
        new NewsScreen(
          newsItem: widget.apiResponse.api[3],
        ),
        new TVMenuScreen(
          tvItem: widget.apiResponse.api[0],
          apiKey: widget.apiResponse.api[2].apiKey,
          channelId: widget.apiResponse.api[2].feedUrl,
        ),
        new RadioMenuScreen(
          radioItem: widget.apiResponse.api[1],
        ),
        new BiblioScreen(
          apiKey: widget.apiResponse.api[2].apiKey,
          channelId: widget.apiResponse.api[2].feedUrl,
          biblioItem: widget.apiResponse.api[3],
        ),
        /*new YoutubeChannelScreen(
          apiKey: widget.apiResponse.api[2].apiKey,
          channelId: widget.apiResponse.api[2].feedUrl,
        ),*/
      ],
    );
  }

  int _page = 0;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBar(),
        drawer: drawer(),
        body: buildPageView(),
        bottomNavigationBar: salomonBottomNavigation(),
        backgroundColor: colorPrimary,
      ),
    );
  }

  Widget drawer() {
    return new Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorPrimary, colorPrimaryClear],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: <Widget>[
            DrawerHeader(
                child: Center(
              child: Container(
                  //margin: EdgeInsets.only(bottom: 35),
                  child: Image(
                image: AssetImage('assets/images/logo.png'),
                width: 220,
              )),
            )),
            Column(
              children: <Widget>[
                 ListTile(
                  title: Text(
                    "Actualités",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  onTap: () {
                    gotoScreen(0);
                  },
                  leading: new IconButton(
                    icon: new Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      gotoScreen(0);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    "Asfiyahi TV",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  onTap: () {
                    gotoScreen(1);
                  },
                  leading: new IconButton(
                    icon: new Icon(
                      Icons.live_tv_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      gotoScreen(1);
                    },
                  ),
                ),
                ListTile(
                  title: Text("Asfiyahi FM",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  onTap: () {
                    gotoScreen(2);
                  },
                  leading: new IconButton(
                    icon: new Icon(
                      Icons.radio_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      gotoScreen(2);
                    },
                  ),
                ),
                ListTile(
                  title: Text("Rubriques",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  onTap: () {
                    gotoScreen(3);
                  },
                  leading: new IconButton(
                    icon: new Icon(
                      Icons.menu_book,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      gotoScreen(3);
                    },
                  ),
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        "Paramètres",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text("Partager",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  onTap: () {
                    openShare();
                  },
                  leading: new IconButton(
                    icon: new Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      openShare();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /*Widget bottomNavigation() {
    return CurvedNavigationBar(
      key: _bottomNavigationKey,
      index: _page,
      height: 50.0,
      items: <Widget>[
        *//*Icon(
          Icons.home_outlined,
          size: 30,
          color: Colors.white,
        ),*//*
        Icon(Icons.live_tv, size: 30, color: Colors.white),
        Icon(Icons.radio_outlined, size: 30, color: Colors.white),
        Icon(Icons.replay, size: 30, color: Colors.white),
      ],
      color: colorPrimary,
      buttonBackgroundColor: colorPrimary,
      backgroundColor: Colors.white,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 600),
      onTap: (index) {
        setState(() {
          _page = index;
          pageController.animateToPage(index,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        });
        *//*if (index == 0) {
          title = "Accueil";
        } else*//*
        if (index == 0) {
          title = "TV";
        } else if (index == 1) {
          title = "Radio";
        } else if (index == 2) {
          title = "Replay";
        }
      },
    );
  }*/

  Widget salomonBottomNavigation() {
    return SalomonBottomBar(
      currentIndex: _page,
      curve: Curves.ease,
      onTap: (i) => setState((){
        _page= i;
        pageController.animateToPage(i,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      } ),
      unselectedItemColor: Colors.white,
      items: [
        SalomonBottomBarItem(
          icon: Icon(FontAwesomeIcons.newspaper),
          title: Text("Actualités"),
          selectedColor: Colors.white,
        ),

        SalomonBottomBarItem(
          icon: Icon(Icons.live_tv),
          title: Text("Asfiyahi TV"),
          selectedColor: Colors.white,
        ),

        SalomonBottomBarItem(
          icon: Icon(Icons.radio_outlined),
          title: Text("Asfiyahi FM"),
          selectedColor: Colors.white,
        ),

        SalomonBottomBarItem(
          icon: Icon(Icons.menu_book),
          title: Text("Rubriques"),
          selectedColor: Colors.white,
        ),
      ],
    );
  }
  openShare() async {
    String link;
    if (Platform.isIOS) {
      link =
      "Télécharger l'application $appName sur AppStore : https://apps.apple.com/us/app/asfiyahi/id1477314500";
    } else {
      link =
      "Télécharger l'application $appName sur PlayStore : https://play.google.com/store/apps/details?id=com.acangroup.asfiyahi";
    }
    WcFlutterShare.share(
        sharePopupTitle: 'Partager via', text: link, mimeType: 'text/plain');
  }

  Widget appBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /*Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/logo.png')))),*/
          Text(
            title,
            style: TextStyle(
                fontFamily: 'CeraPro',
                fontWeight: FontWeight.bold,
                fontSize: 22),
          ),
          SizedBox(width: 50,)
        ],
      ),
      actions: [
        /*new GestureDetector(
          child: Container(
            padding: EdgeInsets.all(7),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(25.0)),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    Icons.featured_play_list_outlined,
                    size: 20,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "GuideTV",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  )
                ],
              ),
            ),
          ),
          onTap: () {
            Utils.navigationPage(context, GuideTVPage(), true);
          },
        ),*/
      ],
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorPrimary, colorPrimary],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          /*borderRadius:
                  BorderRadius.circular(10.0)*/
        ),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
    );
  }

  void gotoScreen(int index) {
    toggleDrawer();
    _page = index;
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  toggleDrawer() async {
    if (_scaffoldKey.currentState.isDrawerOpen) {
      _scaffoldKey.currentState.openEndDrawer();
    } else {
      _scaffoldKey.currentState.openDrawer();
    }
  }
}
