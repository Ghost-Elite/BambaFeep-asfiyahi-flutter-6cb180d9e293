import 'dart:async';
import 'package:asfiyahi/animation/fadeanimation.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:webfeed/webfeed.dart';

import '../constants.dart';
import '../utils/utils.dart';
import 'ActuScreen.dart';

class ActuContainer extends StatefulWidget {
  final String url;

  ActuContainer({
    this.url,
  });

  @override
  _ActuContainerState createState() => _ActuContainerState();
}

class _ActuContainerState extends State<ActuContainer>
    with AutomaticKeepAliveClientMixin<ActuContainer> {
  @override
  bool get wantKeepAlive => true;
  bool isPlay = false;
  bool isVisible = false;
  bool isLoading = true;
  String linkUne = "";
  final logger = Logger();
  List<RssItem> rssList = [];
  List<RssItem> sliderList = [];
  int _current = 0;

  Future<void> getFeed() async {
    // RSS feed
    var client = new http.Client();
    client.get(widget.url).then((response) {
      return response.body;
    }).then((bodyString) {
      var channel = new RssFeed.parse(bodyString);
      rssList = channel.items;
      if(rssList.length>5){
        for (int i = 0; i < 5; i++) {
          sliderList.add(channel.items[i]);
        }
      }else{
        sliderList.addAll(channel.items);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getFeed();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setInvisible() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: isLoading
            ? makeShimmerItem()
            : CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(
                        height: 10,
                      ),
                      slider(),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(bottom: 90),
                            child: makeItemArticle(),
                          )
                        ],
                      )
                    ]),
                  )
                ],
              ),
      ),
    );
  }

  Widget slider() {
    return CarouselSlider(
      options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 16 / 9,
          enlargeCenterPage: true,
          height: 200,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
      items: sliderList.map((item) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => ActuScreen(
                      desc: item.content!=null?item.content.value:item.description,
                          title: item.title,
                          photo: item.description.contains("<img")
                              ? item.description
                                  .split("src=")[1]
                                  .split(" ")[0]
                                  .replaceAll("\"", "")
                                  .trim()
                              : "",
                          link: item.link,
                        )),
                (Route<dynamic> route) => true);
          },
          child: Container(
            width: double.infinity,
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  item.description.contains("<img")
                      ? Image.network(
                          item.description
                              .split("src=")[1]
                              .split(" ")[0]
                              .replaceAll("\"", "")
                              .trim(),
                          fit: BoxFit.cover)
                      : Image.asset(
                          "assets/images/logo.png",
                          fit: BoxFit.contain,
                          //color: Colors.white,
                        ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x2012385E), colorPrimary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: sliderList.map((item) {
                      int index = sliderList.indexOf(item);
                      return Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _current == index ? Colors.white : Colors.white54,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  makeItemArticle() {
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
                      photo: rssList[i].content.images.toString(),
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
                                            child: FadeAnimation(
                                                0.6,
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      right: 10,
                                                      bottom: 15),
                                                  child: Text(
                                                    "${rssList[i].categories[0].value}",
                                                    maxLines: 1,
                                                    textAlign: TextAlign.start,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                        FontWeight.normal,
                                                        color: Colors.black54),
                                                  ),
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
  /*Widget makeItemArticle() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, position) {
        return FadeAnimation(
            0.5,
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => ActuScreen(
                              desc: rssList[position].content.value,
                              title: rssList[position].title,
                              photo:
                                  rssList[position].description.contains("<img")
                                      ? rssList[position]
                                          .description
                                          .split("src=")[1]
                                          .split(" ")[0]
                                          .replaceAll("\"", "")
                                          .trim()
                                      : "",
                              link: rssList[position].link,
                            )),
                    (Route<dynamic> route) => true);
              },
              child: Container(
                  height: 140,
                  width: double.infinity,
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: rssList[position].description.contains("<img")
                            ? CachedNetworkImage(
                                height: 140,
                                width: 130,
                                imageUrl: rssList[position]
                                    .description
                                    .split("src=")[1]
                                    .split(" ")[0]
                                    .replaceAll("\"", "")
                                    .trim(),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Image.asset(
                                  "assets/images/logo.png",
                                  fit: BoxFit.contain,
                                  height: 140,
                                  width: 130,
                                  //color: colorPrimary,
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "assets/images/logo.png",
                                  fit: BoxFit.contain,
                                  height: 140,
                                  width: 130,
                                  //color: colorPrimary,
                                ),
                              )
                            : Image.asset(
                                "assets/images/logo.png",
                                fit: BoxFit.contain,
                                height: 140,
                                width: 130,
                                //color: colorPrimary,
                              ),
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                rssList[position].title,
                                textAlign: TextAlign.start,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "CeraPro",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.all(3),
                              child: Text(
                                //"by ${rssList[position].dc.creator}",
                                "",
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "CeraPro",
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Text(
                                    "Voir Plus",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "CeraPro",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            ));
      },
      itemCount: rssList.length,
    );
  }*/
  Widget makeShimmerItem() {
    return ListView.builder(
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
            itemCount: 6);
  }
}
