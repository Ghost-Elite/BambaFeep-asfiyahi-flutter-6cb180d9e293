import 'api.dart';

class ApiResponse {
  List<Api> api;

  ApiResponse({
      this.api});

  ApiResponse.fromJson(dynamic json) {
    if (json['api'] != null) {
      api = [];
      json['api'].forEach((v) {
        api.add(Api.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (api != null) {
      map['api'] = api.map((v) => v.toJson()).toList();
    }
    return map;
  }

}