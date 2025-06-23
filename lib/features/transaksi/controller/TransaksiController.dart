// controllers/transaction_controller.dart
import 'dart:convert';
import 'package:dreamtix_admin/features/transaksi/model/transaksi_model.dart';
import 'package:http/http.dart' as http;

class TransactionController {
  static const String baseUrl = 'http://localhost:3000';

  // Headers untuk HTTP request
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /// Mengambil semua data transaksi untuk admin
  static Future<ApiResult<List<Transaction>>> getAllTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/transaksi/admin'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final TransactionResponse transactionResponse =
            TransactionResponse.fromJson(jsonData);

        return ApiResult.success(transactionResponse.data);
      } else {
        return ApiResult.error(
          'Failed to load transactions. Status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// Update status pembayaran transaksi
  static Future<ApiResult<bool>> updatePaymentStatus({
    required int idPesanan,
    required int idTransaksi,
    required String status,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/pesanan/$idPesanan/transaksi/$idTransaksi'),
        headers: _headers,
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return ApiResult.success(true);
      } else {
        final errorData = json.decode(response.body);
        return ApiResult.error(
          errorData['message'] ?? 'Failed to update payment status',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// Get transaction by ID
  static Future<ApiResult<Transaction>> getTransactionById(int idPesan) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/transaksi/$idPesan'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Transaction transaction = Transaction.fromJson(jsonData['data']);

        return ApiResult.success(transaction);
      } else {
        return ApiResult.error(
          'Failed to load transaction. Status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResult.error('Network error: $e');
    }
  }

  /// Filter transaksi berdasarkan status
  static List<Transaction> filterByStatus(
    List<Transaction> transactions,
    PaymentStatus status,
  ) {
    return transactions.where((transaction) {
      if (transaction.transaksis.isNotEmpty) {
        return transaction.transaksis.first.status == status.value;
      }
      return false;
    }).toList();
  }

  /// Filter transaksi berdasarkan tanggal
  static List<Transaction> filterByDate(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return transactions.where((transaction) {
      return transaction.tanggal.isAfter(
            startDate.subtract(Duration(days: 1)),
          ) &&
          transaction.tanggal.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  /// Mencari transaksi berdasarkan nama event
  static List<Transaction> searchByEventName(
    List<Transaction> transactions,
    String query,
  ) {
    if (query.isEmpty) return transactions;

    return transactions.where((transaction) {
      if (transaction.detailPemesanan.isNotEmpty) {
        final eventName =
            transaction.detailPemesanan.first.tiket.event.namaEvent;
        return eventName.toLowerCase().contains(query.toLowerCase());
      }
      return false;
    }).toList();
  }

  /// Hitung total pendapatan dari transaksi yang lunas
  static int calculateTotalRevenue(List<Transaction> transactions) {
    int total = 0;
    for (Transaction transaction in transactions) {
      if (transaction.transaksis.isNotEmpty &&
          transaction.transaksis.first.status == PaymentStatus.lunas.value) {
        for (DetailPemesanan detail in transaction.detailPemesanan) {
          total += detail.total;
        }
      }
    }
    return total;
  }

  /// Hitung statistik status pembayaran
  static Map<String, int> getPaymentStatusStats(
    List<Transaction> transactions,
  ) {
    Map<String, int> stats = {'LUNAS': 0, 'BELUM LUNAS': 0, 'DIBATALKAN': 0};

    for (Transaction transaction in transactions) {
      if (transaction.transaksis.isNotEmpty) {
        String status = transaction.transaksis.first.status;
        stats[status] = (stats[status] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// Validasi status pembayaran
  static bool isValidPaymentStatus(String status) {
    return PaymentStatus.values.any((ps) => ps.value == status);
  }
}

/// Class untuk handling result API dengan error handling
class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  ApiResult._({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });

  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  factory ApiResult.error(String error, [int? statusCode]) {
    return ApiResult._(error: error, statusCode: statusCode, isSuccess: false);
  }

  /// Menjalankan callback jika success
  R when<R>({
    required R Function(T data) success,
    required R Function(String error, int? statusCode) error,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    } else {
      return error(this.error ?? 'Unknown error', statusCode);
    }
  }
}

/// Helper class untuk utility functions
class TransactionUtils {
  /// Format currency ke format Rupiah
  static String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// Format DateTime ke string yang readable
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format DateTime ke format tanggal saja
  static String formatDateOnly(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  /// Get warna berdasarkan status pembayaran
  static String getStatusColorHex(String status) {
    switch (status.toUpperCase()) {
      case 'LUNAS':
        return '#4CAF50'; // Green
      case 'BELUM LUNAS':
        return '#FF9800'; // Orange
      case 'DIBATALKAN':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Validasi apakah tanggal event sudah lewat
  static bool isEventPassed(DateTime eventTime) {
    return DateTime.now().isAfter(eventTime);
  }

  /// Generate ID unik untuk transaksi baru (jika diperlukan)
  static String generateTransactionId() {
    return 'TRX${DateTime.now().millisecondsSinceEpoch}';
  }
}
