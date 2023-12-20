import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

import '../helpers/commons.dart';
import '../helpers/directions_handler.dart';
import '../helpers/shared_prefs.dart';
import '../widgets/review_ride_bottom_sheet.dart';

class ReviewRoute extends StatefulWidget {
  final Map<String, dynamic> poi;
  final Map modifiedResponse;

  const ReviewRoute({Key? key, required this.poi, required this.modifiedResponse}) : super(key: key);

  @override
  State<ReviewRoute> createState() => _ReviewRouteState();
}

class _ReviewRouteState extends State<ReviewRoute> {
  // Mapbox Maps SDK related
  LatLng currentLocation = getCurrentLatLngFromSharedPrefs();

  late String distance;
  late String dropOffTime;
  late Map geometry;

  void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  @override
  void initState() {
    super.initState();
    _initialiseDirectionsResponse();
  }

  _initialiseDirectionsResponse() {
    distance = (widget.modifiedResponse['distance'] / 1000).toStringAsFixed(1);
    dropOffTime = getDropOffTime(widget.modifiedResponse['duration']);
    geometry = widget.modifiedResponse['geometry'];
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Review Route'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: getCenterCoordinatesForPolyline(geometry),
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                      urlTemplate:"https://api.mapbox.com/styles/v1/tipsyd/clk0rru4l00a601qr9475gngg/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidGlwc3lkIiwiYSI6ImNsaTM0bXRsNDBtczgzY3JyMG91emE1aGQifQ.M3-YdYVWSEdnPGJ0OW2zUg",
                      additionalOptions: {
                        'accessToken': "pk.eyJ1IjoidGlwc3lkIiwiYSI6ImNsaTM0bXRsNDBtczgzY3JyMG91emE1aGQifQ.M3-YdYVWSEdnPGJ0OW2zUg",
                        'id': 'mapbox.mapbox-streets-v8'
                      },
                      tileProvider: FMTC.instance('mapStore').getTileProvider(),
                      ),

                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: getCoordinatesFromGeometry(geometry),
                        color: Colors.indigo,
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 60,
                        height: 60,
                        point: currentLocation,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      ),
                      Marker(
                        width: 60,
                        height: 60,
                        point: LatLng(
                          widget.poi['coordinates']['latitude'],
                          widget.poi['coordinates']['longitude'],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            reviewRideBottomSheet(context, distance, dropOffTime, widget.poi),
          ],
        ),
      ),
    );
  }
}
