import 'dart:convert';
import 'package:dreamtix_admin/features/auth/model/Admin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class Authcontroller extends GetxController {
  var isPasswordVisible = false.obs;
  void togglePassword() => isPasswordVisible.toggle();

  final box = GetStorage();

  Future<void> loginAdmin(String username, String password) async {
    print("Username ${username}");
    print("Password ${password}");
    final url = Uri.parse("http://10.0.2.2:3000/api/admin/login");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": "${username}",
          "password": "${password}",
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['data']['token'];

        // Simpan token di storage
        await box.write('admin_token', token);

        Get.snackbar(
          "Login Berhasil",
          "Token disimpan",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigasi ke halaman dashboard
        Get.offAllNamed('/home'); // Ganti sesuai rute kamu
      } else {
        Get.snackbar(
          "Login Gagal",
          "Username atau password salah",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Ambil token kapan pun diperlukan
  String? getToken() {
    return box.read('admin_token');
  }

  // Logout dan hapus token
  void logout() {
    box.remove('admin_token');
    Get.offAllNamed('/login');
  }
}

final authController = Authcontroller();
