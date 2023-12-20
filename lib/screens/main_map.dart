import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:mapbox_navigation/screens/turn_by_turn.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../helpers/shared_prefs.dart';
import '../widgets/zoombuttons_plugin_option.dart';
import 'news_detail_page.dart';
import 'poi_details.dart';

/*class WebViewPage extends StatefulWidget {
  final String embeddedCode;

  WebViewPage({required this.embeddedCode});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}
class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.dataFromString('''
          <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <style>
                body {
                  margin: 15;
                  padding: 15;
                  overflow-x: hidden;
                }
                iframe {
                  width: 100%;
                  height: 100%;
                  position: absolute;
                  top: 0;
                  left: 0;
                }
              </style>
            </head>
            <body>
              <div class="content-container">
                ${widget.embeddedCode}
              </div>
            </body>
          </html>
        ''', mimeType: 'text/html'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facebook Posts')),
      body: WebViewWidget(controller: _controller),
    );
  }
}*/ // Disabled due to removal of News/Events

Future<String> getPath() async {
  final cacheDirectory = await getTemporaryDirectory();
  final path = cacheDirectory.path;
  print('Cache Path: $path');
  return path;
}
TileLayer _tileLayerOptions = TileLayer(
  urlTemplate: "https://api.mapbox.com/styles/v1/tipsyd/clplfufpe009z01r88j1fdi8p/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidGlwc3lkIiwiYSI6ImNsaTM0bXRsNDBtczgzY3JyMG91emE1aGQifQ.M3-YdYVWSEdnPGJ0OW2zUg",
  additionalOptions: {
    'accessToken': 'pk.eyJ1IjoidGlwc3lkIiwiYSI6ImNsaTM0bXRsNDBtczgzY3JyMG91emE1aGQifQ.M3-YdYVWSEdnPGJ0OW2zUg',
    'id': 'mapbox.mapbox-streets-v8',
  },
  tileProvider: FMTC.instance('mapStore').getTileProvider(),
);

// Custom ChoiceButton Widget
class ChoiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final String phoneNumber;
  final String landlineNumber;
  final Color buttonColor; // Add a Color property

  const ChoiceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.phoneNumber,
    required this.landlineNumber,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // Show confirmation dialog before performing the action
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By pressing "Confirm," you acknowledge that prank calls to emergency hotline numbers are illegal and may result in severe penalties.',
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Show detailed information in the "Learn More" dialog
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Learn More'),
                            content: Text(
                              'Any person who would be found to make prank calls to emergency hotline numbers should be held liable with the following penalties:\n\n'
                                  '- Arresto menor or jail time of one day to 30 days, and a fine of P5,000 for the first offense.\n'
                                  '- Arresto mayor or jail time of one month and one day to six months, and a fine of P10,000 for the second offense.\n'
                                  '- Prision correccional or six months and one day to six years, and a fine of P20,000 for the third and succeeding offenses.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Learn More'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Choose Option'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  final call = Uri.parse('tel:$landlineNumber');
                                  if (await canLaunchUrl(call)) {
                                    launchUrl(call);
                                  } else {
                                    throw 'Could not launch $call';
                                  }
                                },
                                child: Text('Landline - $landlineNumber'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(buttonColor),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  final call = Uri.parse('tel:$phoneNumber');
                                  if (await canLaunchUrl(call)) {
                                    launchUrl(call);
                                  } else {
                                    throw 'Could not launch $call';
                                  }
                                },
                                child: Text('Phone Number - $phoneNumber'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(buttonColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text('Confirm'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(buttonColor),
                  ),
                ),
              ],
              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            );
          },
        );
      },
      icon: Icon(icon),
      label: Text(label),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(buttonColor), // Use the buttonColor property
      ),
    );
  }
}

class NetworkStatusListener extends StatefulWidget {
  @override
  _NetworkStatusListenerState createState() => _NetworkStatusListenerState();
}
class _NetworkStatusListenerState extends State<NetworkStatusListener> {
  bool isOnline = true;
  bool showNotification = false;

  @override
  void initState() {
    super.initState();
    initConnectivity();
  }

  Future<void> initConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    updateConnectionStatus(connectivityResult);

    Connectivity().onConnectivityChanged.listen((result) {
      updateConnectionStatus(result);
    });
  }

  void updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      isOnline = result != ConnectivityResult.none;
      showNotification = true;
      if (isOnline) {
        Timer(Duration(seconds: 10), () {
          setState(() {
            showNotification = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Your other widgets go here
        if (showNotification)
          NotificationWidget(
            isOnline: isOnline,
            persistent: !isOnline,
          ),
      ],
    );
  }
}

class NotificationWidget extends StatelessWidget {
  final bool isOnline;
  final bool persistent;

  NotificationWidget({required this.isOnline, required this.persistent});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 790,
      left: 8,
      right: 8,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.0, -1.0), // Start from the top
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        )),
        child: Dismissible(
          key: Key('notificationKey'),
          onDismissed: (_) {
            // Handle dismissal logic if needed
          },
          direction: DismissDirection.up,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1000),
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isOnline ? 'Online' : 'Offline mode',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrafficToggleButton extends StatefulWidget {
  final Function(bool) onToggle;

  TrafficToggleButton({required this.onToggle});

  @override
  _TrafficToggleButtonState createState() => _TrafficToggleButtonState();
}
class _TrafficToggleButtonState extends State<TrafficToggleButton> {
  bool isTrafficEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: FractionalTranslation(
        translation: Offset(-0.36, 6.2),
        child: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: isTrafficEnabled ? Colors.yellow : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              final newIsTrafficEnabled = !isTrafficEnabled;
              if (mounted) {
                setState(() {
                  isTrafficEnabled = newIsTrafficEnabled;

                  // Update the TileLayerOptions
                  _tileLayerOptions = TileLayer(
                    urlTemplate: isTrafficEnabled
                        ? "https://api.mapbox.com/styles/v1/tipsyd/clk0rru4l00a601qr9475gngg/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidGlwc3lkIiwiYSI6ImNsaTM0bXRsNDBtczgzY3JyMG91emE1aGQifQ.M3-YdYVWSEdnPGJ0OW2zUg"
                        : "https://api.mapbox.com/styles/v1/tipsyd/clplfufpe009z01r88j1fdi8p/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidGlwc3lkIiwiYSI6ImNsaTM0bXRsNDBtczgzY3JyMG91emE1aGQifQ.M3-YdYVWSEdnPGJ0OW2zUg",
                    additionalOptions: {
                      'accessToken': 'your-access-token',
                      'id': 'mapbox.mapbox-streets-v8',
                    },
                    userAgentPackageName: 'com.spc.tourism_app',
                    tileProvider: FMTC.instance('mapStore').getTileProvider(),
                  );
                });
              }

              // Notify the parent widget about the toggle
              widget.onToggle(newIsTrafficEnabled);

              // Print the current state
              print("newIsTrafficEnabled in onToggle: $isTrafficEnabled");
            },
            icon: Icon(
              Icons.traffic,
              color: isTrafficEnabled ? Colors.black : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class pointOfInterestMap extends StatefulWidget {

  const pointOfInterestMap({Key? key}) : super(key: key);

  @override
  State<pointOfInterestMap> createState() => _pointOfInterestMapState();
}
class _pointOfInterestMapState extends State<pointOfInterestMap> {
  void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  // Connection Variables
  bool _isOffline = false;
  IconData _locationIcon = Icons.my_location;

  // Traffic Variables
  bool isTrafficEnabled = false;

  // Search Bar Variables
  List<DocumentSnapshot>? searchResults;
  late Future<List<DocumentSnapshot>> futureData;

  //Flutter Location Variables
  late FollowOnLocationUpdate _followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;

  //Mapbox Variables
  LatLng currentLocation = getCurrentLatLngFromSharedPrefs();
  late final MapController _mapController;
  final Location location = Location();
  LatLng? _userLocation;
  int selectedFilterCategory = 8;

  //Firebase Variables
  QuerySnapshot? querySnapshot;
  final Uri _url = Uri.parse('tel:911');
  //final _newsAndEventsController = StreamController<QuerySnapshot>(); Disabled due to removal of News/Events
  //final _facebookPostsController = StreamController<QuerySnapshot>(); Disabled due to removal of News/Events

  //Maps POIS Variables
  final Map<int, Map<String, dynamic>> _filterOptions = {
    0: {
      'label': 'All',
      'icon': Icons.layers,
      'category': 'All',
    },
    1: {
      'label': 'Lakes',
      'icon': Icons.water,
      'category': 'Lakes',
    },
    2: {
      'label': 'Restaurant',
      'icon': Icons.restaurant,
      'category': 'Restaurants',
    },
    3: {
      'label': 'Resort',
      'icon': Icons.houseboat,
      'category': 'Resorts',
    },
    4: {
      'label': 'Hotel',
      'icon': Icons.hotel,
      'category': 'Hotels',
    },
    5: {
      'label': 'Travel Agencies',
      'icon': Icons.travel_explore,
      'category': 'Travel Agencies',
    },
    6: {
      'label': 'Farms',
      'icon': Icons.energy_savings_leaf,
      'category': 'Farm',
    },
    7: {
      'label': 'Events Place',
      'icon': Icons.event,
      'category': 'Events Place',
    },
  };
  late final customMarkers = <Marker>[];

  //Slide Panel Variables
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 95.0;

  //Showcase Widget
  BuildContext? myContext;
  final GlobalKey _one =  GlobalKey();
  final GlobalKey _two =  GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four =  GlobalKey();
  final GlobalKey _five =  GlobalKey();
  final GlobalKey _six =  GlobalKey();

  @override
  void initState() {
    _checkConnectivity();

    checkAndSetLocationIcon();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _showMultipleChoiceDialog(context);
    });

    futureData = fetchData();

    //_initNewsAndEventsStream();
    //_initFacebookPostsStream();

    _fabHeight = _initFabHeight;
    _followOnLocationUpdate = FollowOnLocationUpdate.always;
    _followCurrentLocationStreamController = StreamController<double?>();
    _mapController = MapController();

    location.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _userLocation =
            LatLng(currentLocation.latitude, currentLocation.longitude);
      });
    });

    loadPOIMarkers();

    super.initState();
  }

  @override
  void dispose() {
    //_newsAndEventsController.close();
    //_facebookPostsController.close();
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * 0.5;

    return ShowCaseWidget(
      builder: Builder(
        builder: (context) {
          myContext = context;
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  //~Mapbox Map~~\\
                  SizedBox(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: currentLocation,
                        initialZoom: 12.0,
                        maxZoom: 22.0,
                        minZoom: 8.0,
                        onPositionChanged: (MapPosition position, bool hasGesture) {
                          if (hasGesture && _followOnLocationUpdate != FollowOnLocationUpdate.never) {
                            setState(() => _followOnLocationUpdate = FollowOnLocationUpdate.never);
                          }
                        },
                      ),
                      children: [
                        _tileLayerOptions,
                        CurrentLocationLayer(
                          followCurrentLocationStream: _followCurrentLocationStreamController.stream,
                          followOnLocationUpdate: _followOnLocationUpdate,
                          style: const LocationMarkerStyle(
                            marker: DefaultLocationMarker(
                              child: Icon(
                                Icons.navigation,
                                color: Colors.white,
                              ),
                            ),
                            markerSize: Size(40, 40),
                            markerDirection: MarkerDirection.heading,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Showcase(
                                key: _three,
                                targetPadding: EdgeInsets.all(5.0),
                                description: 'Locate User Button',
                                child: FloatingActionButton(
                                  heroTag: "locateUserBtn",
                                  onPressed: () async {
                                    bool hasLocationPermission = await checkLocationPermission();
                                    setState(() {
                                      _followOnLocationUpdate = hasLocationPermission
                                          ? FollowOnLocationUpdate.always
                                          : FollowOnLocationUpdate.never;
                                      _locationIcon = hasLocationPermission
                                          ? Icons.my_location
                                          : Icons.location_disabled;
                                    });
                                    if (hasLocationPermission) {
                                      _followCurrentLocationStreamController.add(15);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Location permission is denied.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    _locationIcon,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        MarkerLayer(
                          markers: customMarkers,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: FractionalTranslation(
                            translation: Offset(0.0, 0.140),
                            child: Showcase(
                              key: _five,
                              description: 'Map with togglable traffic button and zoom control',
                              child: FlutterMapZoomButtons(
                                minZoom: 4,
                                maxZoom: 19,
                                mini: true,
                                padding: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  toolTip(),

                  if (isTrafficEnabled) trafficLegend(),

                  TrafficToggleButton(
                    onToggle: (bool isEnabled) {
                      if (!_isOffline) {
                        setState(() {
                          isTrafficEnabled = isEnabled;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Traffic is partially working in offline mode. The traffic shown is from the last online activity.",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),

                  //~Filters~\\
                  Positioned(
                    top: 85.0,
                    left: 16.0,
                    right: 16.0,
                    child: Showcase(
                      targetPadding: EdgeInsets.only(top: 70, left: 15, right: 15, bottom: 10),
                      tooltipPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      key: _one,
                      description: 'Search Bar & Filter Options',
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: _filterOptions.entries.map((entry) {
                                  final index = entry.key;
                                  final filter = entry.value;
                                  final isSelected = selectedFilterCategory == index;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedFilterCategory = index;
                                          final selectedCategory = _filterOptions[index]?['category'];
                                          List<String> selectedCategories = [
                                            selectedCategory
                                          ];
                                          filterMarkers(selectedCategories);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              32.0),
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              filter['icon'],
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              filter['label'],
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  //~Emergency Button~\\
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Showcase(
                        targetPadding: EdgeInsets.all(5.0),
                        key: _two,
                        description: 'Emergency Button',
                        child: FloatingActionButton(
                          heroTag: "showBottomMenuBtn",
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Container(
                                    height: 200,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        ElevatedButton(
                                          onPressed: () {
                                            // Show another dialog with multiple-choice options
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Center(child: Text('Select Help Type')),
                                                  contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SizedBox(height: 10),
                                                      ChoiceButton(
                                                        icon: Icons.local_hospital,
                                                        label: 'Medical Emergency',
                                                        onPressed: () {
                                                          // Handle the action when the button is pressed
                                                        },
                                                        phoneNumber: '09985407171',
                                                        landlineNumber: '(049) 8000-405',
                                                        buttonColor: Colors.red, // Red for Emergency
                                                      ),
                                                      ChoiceButton(
                                                        icon: Icons.local_fire_department,
                                                        label: 'Fire Emergency',
                                                        onPressed: () {
                                                          // Handle the action when the button is pressed
                                                        },
                                                        phoneNumber: '09985407171',
                                                        landlineNumber: '(049) 8000-405',
                                                        buttonColor: Colors.orange, // Red for Emergency
                                                      ),

                                                      ChoiceButton(
                                                        icon: Icons.local_police,
                                                        label: 'Police Emergency',
                                                        onPressed: () {
                                                          // Handle the action when the button is pressed
                                                        },
                                                        phoneNumber: '09985407171',
                                                        landlineNumber: '(049) 8000-405',
                                                        buttonColor: Colors.blue, // Red for Emergency
                                                      ),
                                                      SizedBox(height: 10),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.red),
                                          ),
                                          child: const Text('Call for help'),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            final destination = LatLng(
                                              14.041666860235837,
                                              121.32510489468005,
                                            );

                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => TurnByTurn(
                                                  destination: destination,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
                                          ),
                                          child: const Text('Evacuation Center'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.emergency),
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ),

                  NetworkStatusListener(),
                  FeedbackButton(),
                  buildFloatingSearchBar(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ~~ Functions Related ~~ \\

        //Hanlding Panel\\
        Future<void> showSlidingUpPanel(BuildContext context, Map<String, dynamic> poi) {
          final screenHeight = MediaQuery
              .of(context)
              .size
              .height;
          final panelHeightFraction = 0.9; // Adjust this fraction as needed

          printError("~~~~POI Details INITIALIZED~~~~");

          return showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: screenHeight * panelHeightFraction,
                child: Column(
                  children: [
                    Expanded(
                      child: POIDetails(poi: poi),
                    ),
                  ],
                ),
              );
            },
            isScrollControlled: true,
          );
        }

        //Loading POIS\\
        Marker buildPin(LatLng point, String name) =>
            Marker(
              point: point,
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () async {
                  // Handle marker tap here
                  final poiDocument = await getPOIDocumentByName(name);
                  if (poiDocument != null) {
                    // Show the sliding-up panel with selected POI details using Firestore data
                    await showSlidingUpPanel(
                        context, poiDocument.data() as Map<String, dynamic>);
                  }
                },
                child: Image.asset(
                  'assets/icon/location.png',
                  width: 50,
                  height: 50,
                ),
              ),
            );
        Future<void> loadPOIMarkers() async {
          try {
            // Fetch POIs data from Firestore
            final QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('pois').get();

            // Clear existing markers
            customMarkers.clear();

            // Create a counter map to track the occurrence of each filter
            final Map<String, int> filterCounter = {};

            // Overall number of all filters
            int overallFilterCount = 0;

            // Lists for coordinates with 0, 0 value
            final List<String> zeroCoordinatesList = [];

            // Iterate through the Firestore documents and add markers to the map
            for (final DocumentSnapshot document in querySnapshot.docs) {
              final geoPoint = document['coordinates'] as GeoPoint;
              final poiLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
              final name = document['name'] as String;
              final filter = document['filter'] as String;

              // Check if coordinates are (0, 0)
              if (geoPoint.latitude == 0.0 && geoPoint.longitude == 0.0) {
                zeroCoordinatesList.add(
                  'Coordinates: LatLng(latitude: 0.0, longitude: 0.0), Name: $name --- !WARNING NO COORDINATES!---',
                );
              } else {
                // Print POI information
                printError('Coordinates: $poiLocation, Name: $name, Filter: $filter');

                // Update filter counter
                filterCounter[filter] = (filterCounter[filter] ?? 0) + 1;

                // Increment overall filter count
                overallFilterCount++;

                // Create a marker for each POI using the new method
                final marker = buildPin(poiLocation, name);

                // Add the marker to the list
                customMarkers.add(marker);
              }
            }

            // Print filter counter information
            printError('Filter Counter: $filterCounter');

            // Print overall number of all filters
            printError('Overall Filter Count: $overallFilterCount');

            // Print coordinates with 0, 0 value
            for (final String zeroCoordinates in zeroCoordinatesList) {
              printError(zeroCoordinates);
            }

            // Update the map with the new markers
            setState(() {});
          } catch (e) {
            printError("Error loading POI markers: $e");
          }
        }
        Future<DocumentSnapshot?> getPOIDocumentByName(String name) async {
          final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('pois').where(
              'name', isEqualTo: name).get();

          if (querySnapshot.docs.isNotEmpty) {
            return querySnapshot.docs.first;
          } else {
            return null;
          }
        }

        // Check location permission status
        Future<bool> checkLocationPermission() async {
          final status = await Location().hasPermission();
          return status == PermissionStatus.granted;
        }
        Future<void> checkAndSetLocationIcon() async {
          bool hasLocationPermission = await checkLocationPermission();
          setState(() {
            _locationIcon =
            hasLocationPermission ? Icons.my_location : Icons.location_disabled;
          });
        }

        //Filter System\\
        Future<void> filterMarkers(List<String> selectedCategories) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('pois')
        .get();
    setState(() {
      customMarkers.clear(); // Clear existing markers// Clear filtered markers

      if (querySnapshot != null) {
        for (final DocumentSnapshot document in querySnapshot.docs) {
          final geoPoint = document['coordinates'] as GeoPoint;
          final poiLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
          final name = document['name'];
          final category = document['filter'];

          if (selectedCategories.contains('All') ||
              selectedCategories.contains(category)) {
            final marker = buildPin(poiLocation, name);
            customMarkers.add(marker); // Add the marker to the list
          }
        }
      }
    });
  }
        Future<void> _showMultipleChoiceDialog(BuildContext context) async {
          List<bool> selectedOptions = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false
          ];
          List<String> categories = _filterOptions.values.map((
              option) => option['category'] as String).toList();

          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Where do you want to travel?'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      16.0), // Adjust the radius as needed
                ),
                content: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: <Widget>[
                    _buildOptionButton(context, selectedOptions, 0, 'All'),
                    _buildOptionButton(context, selectedOptions, 1, 'Lakes'),
                    _buildOptionButton(context, selectedOptions, 2, 'Restaurants'),
                    _buildOptionButton(context, selectedOptions, 3, 'Resorts'),
                    _buildOptionButton(context, selectedOptions, 4, 'Hotels'),
                    _buildOptionButton(context, selectedOptions, 5, 'Travel Agencies'),
                    _buildOptionButton(context, selectedOptions, 6, 'Farms'),
                    _buildOptionButton(context, selectedOptions, 7, 'Events Place'),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      // Handle the selected options
                      List<String> selectedCategories = [];
                      for (int i = 0; i < selectedOptions.length; i++) {
                        if (selectedOptions[i]) {
                          selectedCategories.add(categories[i]);
                        }
                      }

                      print('Selected Categories: $selectedCategories');
                      filterMarkers(selectedCategories);
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }

        //Stream Handler\\
        Future<List<DocumentSnapshot>> fetchData() async {
          try {
            final snapshot = await FirebaseFirestore.instance.collection('pois')
                .get();
            final List<DocumentSnapshot> documents = snapshot.docs;
            printError('Fetched ${documents.length} documents');
            return documents;
          } catch (e) {
            printError('Error fetching data: $e');
            return [];
          }
        }

        //Bug and Feedback Reporting\\
        void _showFeedbackDialog(BuildContext context) {
          String selectedCategory = '';
          TextEditingController feedbackController = TextEditingController();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text("Report Bug/Feedback"),
                      content: Column(
                        children: [
                          Text("Please select a category:"),
                          SizedBox(height: 10),
                          _buildCategoryDropdown(
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                            selectedCategory: selectedCategory,
                          ),
                          SizedBox(height: 20),
                          Text("Please provide your feedback or report a bug:"),
                          SizedBox(height: 10),
                          TextField(
                            controller: feedbackController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance.collection('bugs_and_feedbacks').add({
                                'category': selectedCategory,
                                'feedback': feedbackController.text,
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              // Display success notification
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Feedback submitted successfully!'),
                                  backgroundColor: Colors.green, // Set background color to green
                                  duration: Duration(seconds: 6),
                                ),
                              );

                              print('Feedback submitted successfully');
                            } catch (error) {
                              // Handle the error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error submitting feedback: $error'),
                                  backgroundColor: Colors.red, // Set background color to red
                                  duration: Duration(seconds: 6),
                                ),
                              );

                              print('Error submitting feedback: $error');
                            }

                            Navigator.of(context).pop();
                          },
                          child: Text("Submit"),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          }

        //Checking Connectivity\\
        Future<void> _checkConnectivity() async {
          var connectivityResult = await Connectivity().checkConnectivity();
          _updateConnectivityStatus(connectivityResult);

          Connectivity().onConnectivityChanged.listen((result) {
            _updateConnectivityStatus(result);
          });
        }
        void _updateConnectivityStatus(ConnectivityResult result) {
          setState(() {
            _isOffline = result == ConnectivityResult.none;
          });
        }

        //Webview\\
        /*void _navigateToWebView(BuildContext context, String embeddedCode) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(embeddedCode: embeddedCode),
                  ),
                );
              }*/ //Disabled due to removal of News/Events
        /*void _initNewsAndEventsStream() {
                FirebaseFirestore.instance
                    .collection('news_and_events')
                    .snapshots()
                    .listen((event) {
                  _newsAndEventsController.add(event);
                }, onError: (error) {
                  // Handle errors
                });
              }
              void _initFacebookPostsStream() {
                FirebaseFirestore.instance
                    .collection('facebookPosts')
                    .snapshots()
                    .listen((event) {
                  _facebookPostsController.add(event);
                }, onError: (error) {
                  // Handle errors
                });
              }*/ // Disabled due to removal of News/Events

  // ~~Widgets  Related~~ \\
  Widget trafficLegend() {
    return Positioned(
      top: 140.0,
      left: 26.0,
      right: 16.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendItemContainer("Low", Colors.green),
          const SizedBox(height: 8.0),
          _legendItemContainer("Moderate", Colors.yellow),
          const SizedBox(height: 8.0),
          _legendItemContainer("Heavy", Colors.orangeAccent),
          const SizedBox(height: 8.0),
          _legendItemContainer("High", Colors.redAccent),
        ],
      ),
    );
  }
  Widget _legendItemContainer(String text, Color color) {
    final textWidth = _calculateTextWidth(text, TextStyle(fontSize: 16.0));
    return Container(
      padding: EdgeInsets.all(8.0),
      width: textWidth + 40.0, // Add some padding for better visual appearance
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: _legendItem(text, color),
    );
  }
  Widget _legendItem(String text, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: color,
        ),
        SizedBox(width: 8.0),
        Text(
          text,
          style: TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }
  double _calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }
  Widget toolTip() {
    return Align(
      alignment: Alignment.topRight,
      child: FractionalTranslation(
        translation: Offset(-0.36, 7.6),
        // Adjust the second value to move it down
        child: Container(
          width: 40.0, // Adjust the width as needed
          height: 40.0, // Adjust the height as needed
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              // Delay starting the showcase until after the dialog is dismissed
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                ShowCaseWidget.of(myContext!).startShowCase([
                  _one,
                  _two,
                  _three,
                  _four,
                  _five,
                  _six,
                ]);
              });
            },
            icon: Icon(
              Icons.question_mark,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
  Widget FeedbackButton() {
    return Align(
      alignment: Alignment.topRight,
      child: FractionalTranslation(
        translation: Offset(-0.36, 9.0),
        child: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Builder(
            builder: (context) => IconButton(
              onPressed: _isOffline
                  ? null // Disable the button when there's no internet connection
                  : () {
                // Show feedback/report dialog
                if (_isOffline) {
                  // Show a red Snackbar indicating a connection problem
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "There's a problem with your connection.",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  _showFeedbackDialog(context);
                }
              },
              icon: Icon(
                Icons.bug_report,
                color: _isOffline ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCategoryDropdown({required Function(String) onChanged, required String selectedCategory}) {
    // Replace this list with your own categories
    List<String> categories = ['Bug Report', 'Feature Request', 'General Feedback'];

    return DropdownButton<String>(
      isExpanded: true,
      hint: Text("Select a category"),
      value: selectedCategory.isNotEmpty ? selectedCategory : null,
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        onChanged(newValue ?? '');
      },
    );
  }
  Widget _buildOptionButton(BuildContext context, List<bool> selectedOptions,int index, String text) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return selectedOptions[index]
                ? Colors.blue // Color when selected
                : Colors.white; // Default color
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: BorderSide(color: Colors.black), // Border color
          ),
        ),
      ),
      onPressed: () {
        // Toggle the selection state
        selectedOptions[index] = !selectedOptions[index];
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            color: selectedOptions[index] ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
  Widget buildDragIcon() => GestureDetector(
        child: Center(
          child: Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
  Widget buildFloatingSearchBar() {
    final bool isPortrait =
        MediaQuery
            .of(context)
            .orientation == Orientation.portrait;

    return FloatingSearchBar(
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (String query) async {
        // Convert the query to lowercase
        String lowercaseQuery = query.toLowerCase();

        // Wait for the future to complete
        List<DocumentSnapshot> documents = await futureData;

        // Use the where method to filter documents based on the lowercase name field
        List<DocumentSnapshot> filteredDocuments = documents
            .where((document) {
          Map<String, dynamic> poi = document.data() as Map<String, dynamic>;
          String lowercaseName = poi['name'].toLowerCase();

          return lowercaseName.contains(lowercaseQuery);
        })
            .toList();

        // Update the UI with the filtered results
        setState(() {
          searchResults = filteredDocuments;
        });
      },
      // animating between opened and closed states.
      transition: CircularFloatingSearchBarTransition(),
      actions: <Widget>[
        FloatingSearchBarAction(
          child: CircularButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (BuildContext context, Animation<double> transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: futureData,
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final List<DocumentSnapshot> documents =
                      snapshot.data ?? [];
                  return documents.isEmpty
                      ? Text('No data available.')
                      : buildSearchResults(documents);
                }
              },
            ),
          ),
        );
      },
    );
  }
  Widget buildSearchResults(List<DocumentSnapshot> documents) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: ListView.builder(
        itemCount: searchResults?.length ?? 6,
        itemBuilder: (context, index) {
          if (searchResults != null) {
            final Map<String, dynamic>? poiData = (searchResults![index].data() as Map<String, dynamic>?) ?? null;

            if (poiData != null) {
              final String name = poiData['name'] as String;

              return ListTile(
                title: Text(name),
                leading: Icon(Icons.place),
                onTap: () {
                  showSlidingUpPanel(context, poiData);
                },
              );
            }
          }

          // Placeholder widget for shimmer effect
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: ListTile(
              title: Container(
                height: 16,
                color: Colors.white,
              ),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
  /*  Widget _panel(ScrollController sc) {
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView(
                controller: sc,
                children: <Widget>[
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 30,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 18.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "News/Events in San Pablo",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // News & Events
                        _buildNewsAndEvents(_newsAndEventsController.stream),
                        _buildFacebookPosts(_facebookPostsController.stream),

                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                ],
              ),
            );
          }
      Widget _floatingCollapsed() {
            return Showcase(
              key: _four,
              // Unique key for the tooltip
              description: 'Drag up to see News/Events within San Pablo City',
              // Tooltip text
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                margin: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                child: const Center(
                  child: Text(
                    "News/Events in San Pablo",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }
      Widget _buildNewsAndEvents(Stream<QuerySnapshot> stream) {
        return StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerEffect();
            }

            if (_isOffline) {
              return _buildNoInternetMessage();
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Text("No news or events available yet. Please come back later.");
            }

            return Column(
              children: snapshot.data!.docs.map((newsOrEvent) {
                return Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to a new page with full information about the selected news.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailPage(newsOrEvent),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 6.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F3F5),
                        // Gray background color// Black border outline
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                            ),
                            child: Image.network(
                              newsOrEvent['image_url'],
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  newsOrEvent['title'],
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  newsOrEvent['description'],
                                  style: TextStyle(fontSize: 14.0),
                                  overflow: TextOverflow.ellipsis, // Add this line
                                  maxLines: 3, // Optionally, limit the number of lines before truncation
                                ),
                                Text(
                                  "Tags: ${newsOrEvent['tags'].join(', ')}",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      }
      Widget _buildFacebookPosts(Stream<QuerySnapshot> stream) {
        return StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerEffect();
            }

            if (_isOffline) {
              return _buildNoInternetMessageFacebook();
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Text("No Facebook posts available yet. Please come back later.");
            }

            return Column(
              children: snapshot.data!.docs.map((facebookPost) {
                return Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      _navigateToWebView(context, facebookPost['embeddedCode']);
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 6.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F3F5), // Gray background color
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                            ),
                            child: Image.network(
                              facebookPost['image_url'],
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  facebookPost['title'],
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  facebookPost['description'],
                                  style: TextStyle(fontSize: 14.0),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                                Text(
                                  "Tags: Facebook",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      }*/ // Disabled due to removal of News/Events
  /*  Widget _buildShimmerEffect() {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: List.generate(
              5, // Adjust the number of shimmer items as needed
                  (index) => Container(
                margin: EdgeInsets.only(bottom: 16.0),
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 100.0,
                          height: 100.0,
                          color: Colors.white,
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 18.0,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8.0),
                              Container(
                                width: double.infinity,
                                height: 14.0,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8.0),
                              Container(
                                width: double.infinity,
                                height: 11.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      Widget _buildNoInternetMessage() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No internet connection"),
            SizedBox(height: 10),
            Text("Please check your connection and try again."),
          ],
        );
      }
      Widget _buildNoInternetMessageFacebook() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(''),
            SizedBox(height: 10),
            Text(''),
          ],
        );
      }*/ // Disabled due to removal of News/Events
}