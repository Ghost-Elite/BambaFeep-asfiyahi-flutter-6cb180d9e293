class Newsrss {
  String title;
  String desc;
  String sdimage;
  String type;
  String streamUrl;
  String feedUrl;

  Newsrss({
      this.title, 
      this.desc, 
      this.sdimage, 
      this.type, 
      this.streamUrl, 
      this.feedUrl});

  Newsrss.fromJson(dynamic json) {
    title = json['title'];
    desc = json['desc'];
    sdimage = json['sdimage'];
    type = json['type'];
    streamUrl = json['stream_url'];
    feedUrl = json['feed_url'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['title'] = title;
    map['desc'] = desc;
    map['sdimage'] = sdimage;
    map['type'] = type;
    map['stream_url'] = streamUrl;
    map['feed_url'] = feedUrl;
    return map;
  }

}