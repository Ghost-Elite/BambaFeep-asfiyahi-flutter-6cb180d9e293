import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:asfiyahi/constants.dart';
import 'package:asfiyahi/model/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wakelock/wakelock.dart';
import 'package:youtube_api/youtube_api.dart';

import 'YoutubePlayer.dart';
import 'YoutubeVideoChannelScreen.dart';

// ignore: must_be_immutable
class TVMenuScreen extends StatefulWidget {
  final Api tvItem;
  final String apiKey, channelId;

  TVMenuScreen({
    this.tvItem,
    this.apiKey,
    this.channelId,
  });

  @override
  _TVMenuScreenState createState() => _TVMenuScreenState();
}

class _TVMenuScreenState extends State<TVMenuScreen>
    with AutomaticKeepAliveClientMixin<TVMenuScreen> {
  @override
  bool get wantKeepAlive => true;
  final logger = Logger();
  String tvurl = "";
  String linktv = "";
  BetterPlayerController playerController;
  GlobalKey _betterPlayerKey = GlobalKey();
  YoutubeAPI ytApi;
  List<YT_API> ytResult = [];
  bool isLoading = true;
  var betterPlayerConfiguration = BetterPlayerConfiguration(
    autoPlay: true,
    looping: false,
    fullScreenByDefault: false,
    translations: [
      BetterPlayerTranslations(
        languageCode: "fr",
        generalDefaultError: "Impossible de lire la vidéo",
        generalNone: "Rien",
        generalDefault: "Défaut",
        generalRetry: "Réessayez",
        playlistLoadingNextVideo: "Chargement de la vidéo suivante",
        controlsNextVideoIn: "Vidéo suivante dans",
        overflowMenuPlaybackSpeed: "Vitesse de lecture",
        overflowMenuSubtitles: "Sous-titres",
        overflowMenuQuality: "Qualité",
        overflowMenuAudioTracks: "Audio",
        qualityAuto: "Auto",
      ),
    ],
    allowedScreenSleep: false,
    controlsConfiguration: BetterPlayerControlsConfiguration(
      iconsColor: Colors.white,
      controlBarColor: colorPrimary,
      enablePip: true,
      enableSubtitles: false,
      enablePlaybackSpeed: false,
      loadingColor: colorPrimary,
      enableSkips: false,
      overflowMenuIconsColor: colorPrimary,
    ),
  );
  String tvTitle = "";
  String tvIcon = "";

  Future<void> callAPI() async {
    print('UI callled');
    //await Jiffy.locale("fr");
    ytResult = await ytApi.channel(widget.channelId);
    setState(() {
      print('UI Updated');
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    setState(() {
      tvurl = widget.tvItem.feedUrl;
      tvTitle = widget.tvItem.title;
      logger.i(tvurl);
    });

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      tvurl,
      liveStream: true,
      hlsTrackNames: ["3G 360p", "SD 480p", "HD 1080p"],
      /*notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: tvTitle,
            author: "DMedia",
            imageUrl:tvIcon,
          ),*/
    );
    if (playerController != null) {
      playerController.pause();
      playerController.setupDataSource(betterPlayerDataSource);
    } else {
      playerController = BetterPlayerController(betterPlayerConfiguration,
          betterPlayerDataSource: betterPlayerDataSource);
    }
    playerController.setBetterPlayerGlobalKey(_betterPlayerKey);
    ytApi = new YoutubeAPI(widget.apiKey, maxResults: 50, type: "video");
    callAPI();
  }

  @override
  void dispose() {
    if (playerController != null) playerController.dispose();
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
      adUnitId: Platform.isAndroid ? admobBanAndroid : admobBanIos,
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

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            title: new Text('Eutelsat TV',
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
                  width: 85,
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
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                ),
              ),
              new GestureDetector(
                onTap: () {
                  playerController?.dispose();
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: Container(
                  width: 85,
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
                    "Quitter",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
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
            body: Container(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 300),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          if (_anchoredBanner != null)
                            Container(
                              color: Colors.white,
                              width: _anchoredBanner.size.width.toDouble(),
                              height: _anchoredBanner.size.height.toDouble(),
                              child: AdWidget(ad: _anchoredBanner),
                            ),
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
                                          fontWeight: FontWeight.bold),
                                    )),
                                onTap: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              YoutubeVideoChannelScreen(
                                                ytResult: ytResult,
                                                apikey: widget.apiKey,
                                              )),
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
                ),
              ),
              player(),
              Container(
                  height: 65,
                  width: double.infinity,
                  padding: EdgeInsets.all(3),
                  margin: EdgeInsets.only(top: 230),
                  decoration: BoxDecoration(
                      //borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                      color: Colors.white,
                      border: Border.all(color: colorPrimary)),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: colorPrimary,
                        ),
                        margin: EdgeInsets.all(5),
                        child: Image.asset(
                          "assets/images/logo.png",
                          fit: BoxFit.contain,
                          height: 140,
                          width: 130,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "${tvTitle.toUpperCase()}",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: "CeraPro",
                            fontWeight: FontWeight.bold,
                            color: colorPrimary),
                      ),
                    ],
                  )),
            ],
          ),
        )),
        onWillPop: _onBackPressed);
  }

  Widget player() {
    return Container(
        width: double.infinity,
        height: 230,
        color: Colors.black,
        child: Center(
            child: Stack(
          children: <Widget>[
            playerController != null
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: BetterPlayer(
                      controller: playerController,
                      key: _betterPlayerKey,
                    ),
                  )
                : Container(),
          ],
        )));
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
                            /*   title: ytResult[position].title,
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
      itemCount: ytResult.length > 8 ? 8 : ytResult.length,
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
}
