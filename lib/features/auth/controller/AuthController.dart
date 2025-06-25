import 'dart:convert';
import 'package:dreamtix_admin/features/auth/model/Admin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import "package:dreamtix_admin/core/constant/apiUrl.dart" as api;

class Authcontroller extends GetxController {
  var isPasswordVisible = false.obs;
  void togglePassword() => isPasswordVisible.toggle();

  final box = GetStorage();

  void showSuccessAlert(String title, String message, {VoidCallback? onClose}) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (onClose != null) onClose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showErrorAlert(String title, String message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> loginAdmin(String username, String password) async {
    print("Username ${username}");
    print("Password ${password}");
    final url = Uri.parse("${api.apiUrl}/admin/login");

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

        showSuccessAlert(
          "Login Berhasil",
          "Token disimpan",
          onClose: () {
            // Navigasi ke halaman dashboard setelah alert ditutup
            Get.offAllNamed('/home'); // Ganti sesuai rute kamu
          },
        );
      } else {
        showErrorAlert("Login Gagal", "Username atau password salah");
      }
    } catch (e) {
      showErrorAlert("Error", e.toString());
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
