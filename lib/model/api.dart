class Api {
  String title;
  String desc;
  String type;
  String streamUrl;
  String feedUrl;
  String apiKey;

  Api({
      this.title, 
      this.desc,
      this.type, 
      this.streamUrl, 
      this.feedUrl, 
      this.apiKey});

  Api.fromJson(dynamic json) {
    title = json['title'];
    desc = json['desc'];
    type = json['type'];
    streamUrl = json['stream_url'];
    feedUrl = json['feed_url'];
    apiKey = json['api_key'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['title'] = title;
    map['desc'] = desc;
    map['type'] = type;
    map['stream_url'] = streamUrl;
    map['feed_url'] = feedUrl;
    map['api_key'] = apiKey;
    return map;
  }

}