import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class QrController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var scannedResult = ''.obs;
  var apiResponse = ''.obs;

  // Base URL untuk API
  final String test = 'https://dreamtix-api-express.vercel.app/ping';
  final String baseUrl = 'https://dreamtix-api-express.vercel.app/api/qr';

  @override
  void onInit() {
    super.onInit();
    // Debug: Print saat controller diinisialisasi
    print('QrController initialized');
  }

  // Method untuk update QR dengan hasil scan - hanya return response
  Future<Map<String, dynamic>> updateQr(String qrResult) async {
    try {
      // Debug: Print parameter yang diterima
      print('updateQr called with: $qrResult');

      // Set loading state
      isLoading.value = true;
      print('Loading set to true');

      // Buat URL dengan hasil scan sebagai parameter
      final String url = '$baseUrl/$qrResult';
      print('API URL: $url');

      // Headers untuk request
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Kirim PATCH request dengan timeout
      final response = await http
          .patch(Uri.parse(url), headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        apiResponse.value = response.body;
        scannedResult.value = qrResult;

        return {
          'success': true,
          'message': 'QR Code berhasil diproses!',
          'data': response.body,
          'statusCode': response.statusCode,
        };
      } else {
        // Error dari server
        String errorMessage = 'Server error: ${response.statusCode}';

        // Coba parse error message dari response body
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Jika gagal parse, gunakan default message
        }

        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Error in updateQr: $e');

      return {
        'success': false,
        'message': 'Gagal memproses QR Code: ${e.toString()}',
        'error': e.toString(),
      };
    } finally {
      // Reset loading state
      isLoading.value = false;
      print('Loading set to false');
    }
  }

  // Method untuk reset scanner
  void resetScanner() {
    print('resetScanner called');
    scannedResult.value = '';
    apiResponse.value = '';
  }

  // Method untuk copy to clipboard - return status
  Future<Map<String, dynamic>> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return {
        'success': true,
        'message': 'Berhasil disalin ke clipboard',
      };
    } catch (e) {
      print('Error copying to clipboard: $e');
      return {
        'success': false,
        'message': 'Gagal menyalin ke clipboard',
        'error': e.toString(),
      };
    }
  }

  // Method untuk test koneksi API - return status
  Future<Map<String, dynamic>> testConnection() async {
    try {
      isLoading.value = true;
      print('Testing API connection...');

      final response = await http
          .get(
            Uri.parse(test),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      print('Test connection response: ${response.statusCode}');
      print('Test connection body: ${response.body}');

      return {
        'success': true,
        'message': 'Koneksi berhasil!',
        'statusCode': response.statusCode,
        'data': response.body,
      };
    } catch (e) {
      print('Test connection error: $e');
      return {
        'success': false,
        'message': 'Test koneksi gagal: ${e.toString()}',
        'error': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    print('QrController disposed');
    super.onClose();
  }
}