
import 'package:asfiyahi/constants.dart';
import 'package:asfiyahi/model/api_response.dart';
import 'package:asfiyahi/model/news_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'apiService.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET("api.php")
  Future<ApiResponse> getAppDetails();
  @GET("")
  Future<NewsResponse> getData();
/*
  @GET("")
  Future<VODResponse> getVideoData();*/
}
