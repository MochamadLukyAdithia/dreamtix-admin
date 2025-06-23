import 'package:dreamtix_admin/features/auth/view/login_screen.dart';
import 'package:dreamtix_admin/features/home/view/home_screen.dart';
import 'package:dreamtix_admin/features/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

class AppRoute {
  static const String splash = "/splash";
  static const String login = "/login";
  static const String home = "/home";
}

class AppPages {
  static final initial = AppRoute.splash;
  static final routes = [
    GetPage(name: AppRoute.splash, page: () => SplashScreen()),
    GetPage(name: AppRoute.login, page: () => LoginScreen()),
    GetPage(name: AppRoute.home, page: () => MainApp()),
  ];
}
