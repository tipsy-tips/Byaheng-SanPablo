import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NewsDetailPage extends StatelessWidget {
  final DocumentSnapshot newsData; // Pass the Firestore document to the detail page

  NewsDetailPage(this.newsData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            SizedBox(height: 16.0),
            _buildTitle(),
            _buildDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return newsData['image_url'] != null
        ? Image.network(
      newsData['image_url'],
      width: double.infinity,
      height: 200.0,
      fit: BoxFit.cover,
    )
        : Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 200.0,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    return newsData['title'] != null
        ? Text(
      newsData['title'],
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    )
        : Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 24.0,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDescription() {
    return newsData['description'] != null
        ? Text(
      newsData['description'],
      style: TextStyle(fontSize: 18.0),
    )
        : Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 18.0,
        color: Colors.white,
      ),
    );
  }
}
