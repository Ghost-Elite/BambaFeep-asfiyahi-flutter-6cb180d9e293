import 'newsrss.dart';

class NewsResponse {
  List<Newsrss> newsrss;

  NewsResponse({
      this.newsrss});

  NewsResponse.fromJson(dynamic json) {
    if (json['newsrss'] != null) {
      newsrss = [];
      json['newsrss'].forEach((v) {
        newsrss.add(Newsrss.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (newsrss != null) {
      map['newsrss'] = newsrss.map((v) => v.toJson()).toList();
    }
    return map;
  }

}