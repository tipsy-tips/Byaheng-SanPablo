import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_navigation/main.dart';
import 'package:mapbox_navigation/screens/home_management.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late ConnectivityResult _connectivityResult;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    // Initialize connectivity check
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    _connectivityResult = await Connectivity().checkConnectivity();
    // You can add further handling based on the connectivity result if needed.
    // For now, it continues to initialize location and save.
    await initializeLocationAndSave();
  }

  Future<void> initializeLocationAndSave() async {
    // Ensure all permissions are collected for Locations
    Location _location = Location();
    bool? _serviceEnabled;
    PermissionStatus? _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
    }

    _permissionGranted = await _location.hasPermission();
    // Remove the condition to show the warning
    // if (_permissionGranted != PermissionStatus.granted) {
    //   // Display a warning that location permission is not granted
    //   showLocationPermissionWarning();
    //   return;
    // }

    // Get the user's current location
    LocationData _locationData = await _location.getLocation();
    LatLng currentLatLng = LatLng(_locationData.latitude!, _locationData.longitude!);

    // Store the user location in sharedPreferences
    // Note: You need to replace 'sharedPreferences' with your actual implementation
    sharedPreferences.setDouble('latitude', currentLatLng.latitude);
    sharedPreferences.setDouble('longitude', currentLatLng.longitude);

    // Check if offline mode (no internet connection)
    if (_connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isOffline = true;
      });
    }

    // Delay for a moment to show the loading screen
    await Future.delayed(Duration(seconds: 2));

    // Navigate to HomeManagement page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeManagement()),
          (route) => false,
    );
  }


  void showLocationPermissionWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Required"),
        content: Text("Please grant location permission to continue."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop(); // Close the app
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/image/splash.png'),
          if (_isOffline)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              child: Padding(
                padding: const EdgeInsets.all(20.0), // Adjust padding as needed
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red, // Set the background color to red
                    borderRadius: BorderRadius.circular(10.0), // Set rounded corners
                  ),
                  padding: const EdgeInsets.all(16.0), // Inner padding
                  child: Text(
                    'Will Continue in Offline Mode',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
