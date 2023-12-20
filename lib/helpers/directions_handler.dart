import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_navigation/main.dart';

import '../requests/mapbox_requests.dart';

// ----------------------------- Gets POI's Location, Distance, Duration & Geometry -----------------------------
Future<Map> getDirectionsAPIResponse(LatLng currentLatLng, Map<String, dynamic> poiDocument) async {
  double latitude = poiDocument['coordinates']['latitude'];
  double longitude = poiDocument['coordinates']['longitude'];

  final response = await getCyclingRouteUsingMapbox(currentLatLng, LatLng(latitude, longitude));

  final Map geometry = response['routes'][0]['geometry'];
  final num duration = response['routes'][0]['duration'];
  final num distance = response['routes'][0]['distance'];

  print('-------------------${poiDocument['name']}-------------------');
  print(distance);
  print(duration);

  final Map modifiedResponse = {
    "geometry": geometry,
    "duration": duration,
    "distance": distance,
  };

  return modifiedResponse;
}

LatLng getCenterCoordinatesForPolyline(Map geometry) {
  List coordinates = geometry['coordinates'];
  int pos = (coordinates.length / 2).round();
  return LatLng(coordinates[pos][1], coordinates[pos][0]);
}

double calculateZoomLevel(LatLngBounds bounds, double mapWidth, double mapHeight) {
  final double padding = 50.0;
  double zoomLevel;

  double latFraction = (bounds.north - bounds.south) / 360.0;
  double lngFraction = (bounds.east - bounds.west) / 360.0;

  double latZoom = (mapHeight - padding * 2) / (latFraction * 256.0);
  double lngZoom = (mapWidth - padding * 2) / (lngFraction * 256.0);

  zoomLevel = latZoom < lngZoom ? latZoom : lngZoom;

  return zoomLevel;
}

// Function to save directions API response for a Firestore document
void saveDirectionsAPIResponse(String documentId, String response) {
  final String key = 'POI--$documentId';
  sharedPreferences.setString(key, response);
}

List<LatLng> getCoordinatesFromGeometry(Map geometry) {
  List coordinates = geometry['coordinates'];
  return coordinates.map((coord) {
    double latitude = coord[1];
    double longitude = coord[0];
    return LatLng(latitude, longitude);
  }).toList();
}



