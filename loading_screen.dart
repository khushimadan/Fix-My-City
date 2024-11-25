import 'package:flutter/material.dart';
import 'package:fix_my_city/screens/onboarding_screen1.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen1()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 160,
              width: 250,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/logo.png'), fit: BoxFit.fill),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'FixMyCity',
              style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF009944)),
            ),
          ],
        ),
      ),
    );
  }
}
