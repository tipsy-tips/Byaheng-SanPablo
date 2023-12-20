import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

import '../helpers/dio_exceptions.dart';

String baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';
String accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN']!;
String navType = 'cycling';

Dio _dio = Dio();

Future<dynamic> getCyclingRouteUsingMapbox(LatLng source, LatLng destination) async {
  String url =
      '$baseUrl/$navType/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?alternatives=true&continue_straight=true&geometries=geojson&language=en&overview=full&steps=true&access_token=$accessToken';
  try {
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      // Handle a successful response here, e.g., return the decoded JSON data.
      return response.data;
    } else {
      // Handle non-200 status codes as needed.
      debugPrint('Request failed with status code ${response.statusCode}');
    }
  } on DioError catch (e) {
    final errorMessage = DioExceptions.fromDioError(e).toString();
    debugPrint(errorMessage);
  } catch (e) {
    // Handle other exceptions that may occur during the request.
    debugPrint('Error: $e');
  }
}

