import 'package:flutter/material.dart';
import 'package:mapbox_navigation/screens/main_map.dart';

class HomeManagement extends StatefulWidget {
  const HomeManagement({Key? key}) : super(key: key);

  @override
  State<HomeManagement> createState() => _HomeManagementState();
}

class _HomeManagementState extends State<HomeManagement> {
  final List<Widget> _pages = [
    const pointOfInterestMap(),
  ];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
    );
  }
}
