import 'package:asfiyahi/model/api.dart';
import 'package:flutter/material.dart';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:volume/volume.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import '../constants.dart';

class RadioPlayerScreen extends StatefulWidget {
  final Api radioItem;

  RadioPlayerScreen({this.radioItem});

  @override
  _RadioPlayerPageState createState() => _RadioPlayerPageState();
}

class _RadioPlayerPageState extends State<RadioPlayerScreen>
    with WidgetsBindingObserver {
  final logger = Logger();
  AssetsAudioPlayer _player = AssetsAudioPlayer.newPlayer();
  String radioName = "", radioFreq = "", radioImg, radioUrl;
  int pos = 0;
  bool isLoading = false;
  bool isLoadingAOD = false;


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _player?.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    initAudioStreamType();
    _init(widget.radioItem);
  }

  void _init(Api item) {
    radioName = item.title;
    radioFreq = item.desc;
    radioUrl = item.streamUrl;
    //_player.dispose();
    logger.i(radioUrl);
    try {
      _player.onErrorDo = (error) {
        error.player.stop();
      };
      _player
          .open(
            Audio.liveStream(radioUrl,
                metas: Metas(
                    title: radioName,
                    artist: "Live",
                    image: MetasImage.asset("assets/images/logo.png"))),
            autoStart: true,
            showNotification: true,
          )
          .then((value) => (setState(() {
                isLoading = false;
              })));
    } catch (t) {
      print(t);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    _player?.dispose();
    _player = null;
  }

  @override
  void dispose() {
    _player?.dispose();
    _player = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("$imageUri/bg_radio.png"),
                    fit: BoxFit.cover)),
            child: Stack(
              children: [appBar(), player()],
            )));
  }

  Widget appBar() {
    return AppBar(
      centerTitle: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, size: 30, color: colorPrimary),
        onPressed: (){
          _player?.dispose();
          _player = null;
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> initAudioStreamType() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  setVol(int i) async {
    await Volume.setVol(i, showVolumeUI: ShowVolumeUI.SHOW);
  }

  Widget player() {
    return Container(
        child: Stack(
      children: [
        Container(
          height: 270,
          margin: EdgeInsets.only(top: 120),
          child: Center(
              child: Image.asset(
                      "$imageUri/radiofreq.png",
                      height: 250,
                      width: 250,
                      fit: BoxFit.fill,
                    )
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 80, left: 30, right: 30),
          child: Center(
              child: Text(
            "Vous écoutez\n$radioName",
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 28, color: colorPrimary),
          )),
        ),
        Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height - 245),
            //color: Colors.black,
            child: Column(
              children: [
                Container(
                  height: 100,
                  margin: EdgeInsets.only(bottom: 50),
                  alignment: Alignment.bottomCenter,
                  child: PlayerBuilder.isPlaying(
                    player: _player,
                    builder: (context, isPlaying) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              String text =
                                  "Ecouter $radioName sur l'application $appName sur Play Store : $playStoreLink";
                              WcFlutterShare.share(
                                  sharePopupTitle: 'Partagez via',
                                  text: text,
                                  mimeType: 'text/plain');
                            },
                            child: Icon(
                              Icons.share_outlined,
                              size: 30,
                              color: colorPrimary,
                            ),
                          ),
                          !isLoading
                              ? GestureDetector(
                                  onTap: () async {
                                    try {
                                      await _player.playOrPause();
                                    } catch (t) {
                                      logger.i(t);
                                    }
                                  },
                                  child: Image(
                                    image: isPlaying
                                        ? AssetImage("assets/images/pause.png")
                                        : AssetImage("assets/images/play.png"),
                                    height: 80,
                                    width: 80,
                                    color:colorPrimary,
                                  ))
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                          GestureDetector(
                            onTap: () {
                              Volume.getVol.then((value) => {setVol(value)});
                            },
                            child: Icon(
                              Icons.volume_up_outlined,
                              size: 35,
                              color: colorPrimary,
                            ),
                          ),

                        ],
                      );
                    },
                  ),
                ),
                PlayerBuilder.isPlaying(
                    player: _player,
                    builder: (context, isPlaying) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 90,
                          child: isPlaying
                              ? Image.asset(
                                  "assets/images/equalizer.gif",
                                  fit: BoxFit.cover,
                            color: colorPrimary,
                                )
                              : Image.asset(
                                  "assets/images/equalizeroff.png",
                                  fit: BoxFit.cover,
                            color: colorPrimary,
                                ));
                    }),
              ],
            )),
      ],
    ));
  }

}
