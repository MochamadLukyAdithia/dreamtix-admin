import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dreamtix_admin/features/auth/controller/AuthController.dart';
import 'package:dreamtix_admin/core/constant/apiUrl.dart' as api;

class ProfileController extends GetxController {
  var adminData = Rxn<Map<String, dynamic>>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    try {
      isLoading.value = true;
      final token = authController.getToken();

      if (token == null) {
        // Redirect to login if no token
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse('${api.apiUrl}/admin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        adminData.value = data['data'];
      } else {
        // Handle error - maybe token expired
        showErrorAlert('Gagal memuat data admin');
      }
    } catch (e) {
      showErrorAlert('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showErrorAlert(String message) {
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
            const Text(
              'Error',
              style: TextStyle(
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

  void showSuccessAlert(String message) {
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
            const Text(
              'Success',
              style: TextStyle(
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

  void showLogoutDialog() {
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
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Konfirmasi Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
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

  void performLogout() {
    // Use the existing auth controller logout method
    authController.logout();

    // Show success message
    showSuccessAlert('Logout berhasil');
  }
}
