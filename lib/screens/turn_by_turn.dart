import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_navigation/screens/main_map.dart';

import '../helpers/shared_prefs.dart';
import '../ui/rate_ride.dart';

class TurnByTurn extends StatefulWidget {
  final LatLng destination;

  const TurnByTurn({Key? key, required this.destination}) : super(key: key);

  @override
  _TurnByTurnState createState() => _TurnByTurnState();
}

class _TurnByTurnState extends State<TurnByTurn> {
  late LatLng source;

  late MapBoxNavigation _mapBoxNavigation;
  late MapBoxOptions _navigationOptions;

  String? _platformVersion;
  String? _instruction;

  bool _isMultipleStop = false;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  bool _inFreeDrive = false;
  MapBoxNavigationViewController? _controller;

  @override
  void initState() {
    super.initState();
    _mapBoxNavigation = MapBoxNavigation();
    source = getCurrentLatLngFromSharedPrefs();
    _initializeNavigationOptions();
    _mapBoxNavigation.registerRouteEventListener(onRouteEvent);
    _startNavigation();
  }

  void _initializeNavigationOptions() {
      _navigationOptions = MapBoxOptions(
      initialLatitude: source.latitude,
      initialLongitude: source.longitude,
      language: "en",
      simulateRoute: false,
      units: VoiceUnits.metric,
      mapStyleUrlDay: "mapbox://styles/tipsyd/clpwyzewz008q01mrevqvba89",
      mapStyleUrlNight: "mapbox://styles/tipsyd/clpwyzewz008q01mrevqvba89",
      alternatives: true,
      enableRefresh: true,
      isOptimized: true,
      animateBuildRoute: true,
      mode: MapBoxNavigationMode.drivingWithTraffic,
      voiceInstructionsEnabled: true,
      bannerInstructionsEnabled: true,
    );
  }

  Future<void> _startNavigation() async {

    final wayPoints = <WayPoint>[
      WayPoint(
        name: "Starting Point",
        latitude: source.latitude,
        longitude: source.longitude,
        isSilent: true
      ),
      WayPoint(
        name: "Destination",
        latitude: widget.destination.latitude,
        longitude: widget.destination.longitude,
        isSilent: true
      ),
    ];

    _mapBoxNavigation.startNavigation(
      wayPoints: wayPoints,
      options: _navigationOptions
    );
  }

  Future<void> onRouteEvent(e) async {
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null) {
            _instruction = progressEvent.currentStepInstruction;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller?.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
          setState(() {
            _routeBuilt = false;
            _isNavigating = false;
          });
          await _controller?.finishNavigation();
          Navigator.of(context).pop(); // Close the current screen
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const RateRide(),
          ));

        break;
      default:
        break;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapBoxNavigationView(
          options: _navigationOptions,
          onRouteEvent: onRouteEvent,
          onCreated:
              (MapBoxNavigationViewController controller) async {
            _controller = controller;
            controller.initialize();
          }),
    );
  }
}
