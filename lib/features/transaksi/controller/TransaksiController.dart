// controllers/transaction_controller.dart
import 'dart:convert';
import 'package:dreamtix_admin/features/transaksi/model/transaksi_model.dart';
import 'package:http/http.dart' as http;
import 'package:dreamtix_admin/core/constant/apiUrl.dart' as api;

class TransactionController {
  static final String baseUrl = "${api.apiUrl}/transaksi";
  static final String pesananUrl = '${api.apiUrl}/pesanan';

  // Read all transactions
  static Future<TransactionResponse?> getAllTransactions() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return TransactionResponse.fromJson(jsonResponse);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }

  // Update transaction status
  static Future<bool> updateTransactionStatus({
    required int idTransaksi,
    required String newStatus,
  }) async {
    try {
      print(idTransaksi);
      final response = await http.patch(
        Uri.parse('$baseUrl/$idTransaksi'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Update failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception occurred while updating: $e');
      return false;
    }
  }

  // Get transaction by ID
  static Future<TransactionData?> getTransactionById(int idPesan) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$idPesan'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          return TransactionData.fromJson(jsonResponse['data'][0]);
        }
        return null;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }

  // Helper method to format currency
  static String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Helper method to format date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to format time
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to get status color
  static int getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'LUNAS':
        return 0xFF4CAF50; // Green
      case 'PENDING':
        return 0xFFFF9800; // Orange
      case 'DIBATALKAN':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  // Get available status options
  static List<String> getStatusOptions() {
    return ['PENDING', 'LUNAS', 'DIBATALKAN'];
  }
}
