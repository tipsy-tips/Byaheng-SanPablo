import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_navigation/screens/review_ride.dart';
import 'package:shimmer/shimmer.dart';

import '../helpers/directions_handler.dart';
import '../helpers/shared_prefs.dart';

class POIDetails extends StatefulWidget {
  final Map<String, dynamic> poi;// Add this parameter

  POIDetails({required this.poi}); // Update the constructor

  @override
  _POIDetailsState createState() => _POIDetailsState();
}

class _POIDetailsState extends State<POIDetails> {
  int _selectedCategoryIndex = 0;
  LatLng currentLocation = getCurrentLatLngFromSharedPrefs();

  void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  @override
  void initState() {
    super.initState();
  }

// Define a list of asset paths for your icons
  final List<String> categoryIcons = [
    'assets/icon/about.png', // About
    'assets/icon/history.png', // History
    'assets/icon/accessibility.png', // Accessibility
    'assets/icon/activities.png', // Activities
    'assets/icon/amenities.png', // Amenities
    'assets/icon/contact-mail.png', // Contacts
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        boxShadow: [
          BoxShadow(
            color: Color(0x809e9e9e),
            offset: Offset(0.0, 3.0),
            blurRadius: 7.0,
            spreadRadius: 5.0,
            blurStyle: BlurStyle.normal,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              widget.poi['name'],
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                GeoPoint geoPoint = widget.poi['coordinates'];
                double latitude = geoPoint.latitude;
                double longitude = geoPoint.longitude;

                Map<String, dynamic> poiData = {
                  'name': widget.poi['name'],
                  'coordinates': {
                    'latitude': latitude,
                    'longitude': longitude,
                  },
                };

                LatLng currentLatLng = getCurrentLatLngFromSharedPrefs();
                Map modifiedResponse =
                await getDirectionsAPIResponse(currentLatLng, poiData);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewRoute(
                      poi: poiData,
                      modifiedResponse: modifiedResponse,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "Preview Route",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: (widget.poi['images'] != null && widget.poi['images'].isNotEmpty)
                ? CarouselSlider.builder(
              itemCount: widget.poi['images'].length,
              options: CarouselOptions(
                enlargeCenterPage: true,
                viewportFraction: 0.7,
                autoPlay: true,
                aspectRatio: 16 / 9,
              ),
              itemBuilder: (context, index, realIndex) {
                final imageUrl = widget.poi['images'][index];
                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Provide a fallback widget for broken images
                          return Container(
                            color: Colors.grey, // You can customize the color
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 64.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Text(
                'No images available',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(categoryIcons.length, (index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedCategoryIndex == index
                        ? Colors.blue
                        : Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  icon: Image.asset(
                    categoryIcons[index],
                    width: 32.0,
                    height: 32.0,
                    color: _selectedCategoryIndex == index
                        ? Colors.blue
                        : Colors.black,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: buildCategoryContent(),
          ),
        ],
      ),
    );
  }
  Widget buildCategoryContent() {
    switch (_selectedCategoryIndex) {
      case 0:
        return buildAboutContent();
      case 1:
        return buildHistoryContent();
      case 2:
        return buildAccessibilityContent();
      case 3:
        return buildActivitiesContent();
      case 4:
        return buildAmenitiesContent();
      case 5:
        return buildContactsContent();
      default:
        return Container(); // Default content when no category is selected
    }
  }
  Widget buildAboutContent() {
    String about = widget.poi['about'] ?? '';

    return about != null && about.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.0),
        Text(
          'About',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Text(
                about,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0),
        // Add more details about the About category here
      ],
    )
        : Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.0),
              Container(
                color: Colors.blue,
                height: 28.0,
                width: 100.0,
              ),
              SizedBox(height: 8.0),
              Container(
                color: Colors.grey[300],
                height: 16.0,
                width: double.infinity,
              ),
              SizedBox(height: 8.0),
              Container(
                color: Colors.grey[300],
                height: 16.0,
                width: double.infinity,
              ),
              SizedBox(height: 16.0),
              // Add more details about the About category here
            ],
        ),
    );
  }
  Widget buildHistoryContent() {
    String history = widget.poi['history'] ?? '';

    return history.isNotEmpty
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(height: 8.0),
          Text(
          'History',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
          SizedBox(height: 8.0),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Text(
                  history,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ),
        SizedBox(height: 16.0),
      ],
    )
        : Center(
          child: Text(
            'No content available yet, please try again at a later time',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
  }
  Widget buildAccessibilityContent() {
    final List<String> accessibility = (widget.poi['accessibility'] as List<dynamic>?)
        ?.cast<String>()
        .where((item) => item.isNotEmpty) // Filter out empty strings
        .toList() ?? [];

    return accessibility.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.0),
        Text(
          'Accessibility',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: accessibility.map((accessibilityItem) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8.0,
                          ),
                          SizedBox(width: 8.0),
                          Flexible(
                            child: Text(
                              accessibilityItem,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0), // Add spacing below each accessibilityItem
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    )
        : Center(
      child: Text(
        'No content available yet, please try again at a later time',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
  Widget buildActivitiesContent() {
    final List<String> activities = (widget.poi['activities'] as List<dynamic>?)
        ?.cast<String>()
        .where((activity) => activity.isNotEmpty) // Filter out empty strings
        .toList() ?? [];

    return activities.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.0),
        Text(
          'Activities',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: activities.map((activity) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              activity,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0), // Add spacing below each activity
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    )
        : Center(
      child: Text(
        'No content available yet, please try again at a later time',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
  Widget buildAmenitiesContent() {
    final List<String> amenities = (widget.poi['amenities'] as List<dynamic>?)
        ?.cast<String>()
        .where((amenity) => amenity.isNotEmpty) // Filter out empty strings
        .toList() ?? [];

    return amenities.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.0),
        Text(
          'Amenities',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: amenities.map((amenity) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              amenity,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0), // Add spacing below each amenity
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    )
        : Center(
      child: Text(
        'No content available yet, please try again at a later time',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
  Widget buildContactsContent() {
    String contactNo = widget.poi['contactNo'] ?? ''; // Set default value to an empty string if null

    return contactNo.isNotEmpty
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.0),
        Text(
          'Contacts Details',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          height: 200,
          child: ListView(
            children: [
              Text(
                contactNo,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        : Center(
      child: Text(
        'No content available yet, please try again at a later time',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

}