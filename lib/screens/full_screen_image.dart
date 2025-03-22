import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imagePath;
  final bool isNetwork;

  const FullScreenImage({super.key, required this.imagePath, required this.isNetwork});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: InteractiveViewer(
          child: isNetwork
              ? Image.network(imagePath) // Display network image
              : Image.file(File(imagePath)), // Display local image
        ),
      ),
    );
  }
}
