import 'package:dreamtix_admin/features/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  final Color bgColor = const Color(0xFF0D0B29);
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Get.offNamed(AppRoute.login);
    });

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('./assets/images/logo.png', height: 200),
            const SizedBox(height: 20),
            const Text(
              'DreamTix',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
