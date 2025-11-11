// lib/screens/splash_screen.dart

import 'dart:async'; // Penting untuk 'Timer'
import 'package:flutter/material.dart';
import 'package:convert_uas/screens/main_screen.dart'; // Pastikan ini ke MainScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Set durasi splash screen (mis: 3 detik)
    await Future.delayed(Duration(milliseconds: 3000), () {});

    // Navigasi ke MainScreen (halaman dengan bottom nav)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.change_circle_outlined,
              size: 100.0,
              color: Colors.white,
            ),
            SizedBox(height: 24.0),
            Text(
              'Hybrid Converter',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 48.0),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}