import 'package:flutter/material.dart';
import 'package:fix_my_city/screens/loading_screen.dart';

void main() {
  runApp(const FixMyCity());
}

class FixMyCity extends StatelessWidget {
  const FixMyCity({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
    );
  }
}
