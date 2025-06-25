// ticket_controller.dart
import 'dart:convert';
import 'package:dreamtix_admin/features/tiket/model/Tiket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dreamtix_admin/core/constant/apiUrl.dart' as api;

class TicketController extends GetxController {
  var tickets = <Ticket>[].obs;
  var isLoading = false.obs;
  final String baseUrl = "${api.apiUrl}/event/tikets";

  @override
  void onInit() {
    fetchTickets();
    super.onInit();
  }

  // READ - Fetch all tickets
  Future<void> fetchTickets() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Response hanya memiliki 'data' field langsung
        if (responseData.containsKey('data')) {
          final List data = responseData['data'];
          tickets.value = data.map((json) => Ticket.fromJson(json)).toList();
          if (tickets.isNotEmpty) {
            Get.snackbar(
              "Berhasil",
              "Data tiket berhasil dimuat (${tickets.length} tiket)",
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        } else {
          _showErrorSnackbar("Format response tidak valid");
        }
      } else {
        _showErrorSnackbar("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorSnackbar("Network error: ${e.toString()}");
      print("Fetch tickets error: $e"); // Debug log
    } finally {
      isLoading.value = false;
    }
  }

  // CREATE - Add new ticket
  Future<void> createTicket(Map<String, dynamic> ticketData) async {
    try {
      isLoading.value = true;

      // Prepare data sesuai dengan struktur yang diharapkan API
      final requestData = {
        'harga': ticketData['harga'],
        'stok': ticketData['stok'],
        'nama_event': ticketData['nama_event'],
        'artis': ticketData['artis'],
        'waktu': ticketData['waktu'],
        'image': ticketData["image"],
        'nama': ticketData['nama'],
      };
      print("INI DATA ${requestData}");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      print(
        "Create response: ${response.statusCode} - ${response.body}",
      ); // Debug log

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh the list to get the new ticket
        await fetchTickets();
        Get.snackbar(
          "Berhasil",
          "Tiket baru berhasil ditambahkan",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        try {
          final responseData = json.decode(response.body);
          _showErrorSnackbar(
            "Error: ${responseData['message'] ?? 'Gagal menambah tiket'}",
          );
        } catch (e) {
          _showErrorSnackbar("Server error: ${response.statusCode}");
        }
      }
    } catch (e) {
      _showErrorSnackbar("Network error: ${e.toString()}");
      print("Create ticket error: $e"); // Debug log
    } finally {
      isLoading.value = false;
    }
  }

  // UPDATE - Edit existing ticket
  Future<void> updateTicket(int id, Map<String, dynamic> ticketData) async {
    try {
      isLoading.value = true;

      // Prepare data sesuai dengan struktur yang diharapkan API
      final requestData = {
        'id_category': ticketData['id_category'] ?? 1,
        'id_event': ticketData['id_event'] ?? 1,
        'harga': ticketData['harga'],
        'stok': ticketData['stok'],
        // Data event
        'event': {
          'nama_event': ticketData['nama_event'],
          'artis': ticketData['artis'],
          'waktu': ticketData['waktu'],
        },
        // Data category
        'category': {
          'nama': ticketData['category_nama'],
          'posisi': ticketData['posisi'],
        },
      };

      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      print(
        "Update response: ${response.statusCode} - ${response.body}",
      ); // Debug log

      if (response.statusCode == 200) {
        // Refresh the list to get updated data
        await fetchTickets();
        Get.snackbar(
          "Berhasil",
          "Tiket berhasil diperbarui",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF2196F3),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        try {
          final responseData = json.decode(response.body);
          _showErrorSnackbar(
            "Error: ${responseData['message'] ?? 'Gagal memperbarui tiket'}",
          );
        } catch (e) {
          _showErrorSnackbar("Server error: ${response.statusCode}");
        }
      }
    } catch (e) {
      _showErrorSnackbar("Network error: ${e.toString()}");
      print("Update ticket error: $e"); // Debug log
    } finally {
      isLoading.value = false;
    }
  }

  // DELETE - Remove ticket
  Future<void> deleteTicket(int id) async {
    try {
      isLoading.value = true;
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        "Delete response: ${response.statusCode} - ${response.body}",
      ); // Debug log

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local list immediately for better UX
        tickets.removeWhere((ticket) => ticket.idTiket == id);
        Get.snackbar(
          "Berhasil",
          "Tiket berhasil dihapus",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        try {
          final responseData = json.decode(response.body);
          _showErrorSnackbar(
            "Error: ${responseData['message'] ?? 'Gagal menghapus tiket'}",
          );
        } catch (e) {
          _showErrorSnackbar("Server error: ${response.statusCode}");
        }
        // Refresh to ensure data consistency
        await fetchTickets();
      }
    } catch (e) {
      _showErrorSnackbar("Network error: ${e.toString()}");
      print("Delete ticket error: $e"); // Debug log
      // Refresh to ensure data consistency
      await fetchTickets();
    } finally {
      isLoading.value = false;
    }
  }

  // Get ticket by ID
  Ticket? getTicketById(int id) {
    try {
      return tickets.firstWhere((ticket) => ticket.idTiket == id);
    } catch (e) {
      return null;
    }
  }

  // Search tickets by event name or artist
  List<Ticket> searchTickets(String query) {
    if (query.isEmpty) return tickets;

    return tickets.where((ticket) {
      return ticket.event.namaEvent.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          ticket.event.artis.toLowerCase().contains(query.toLowerCase()) ||
          ticket.category.nama.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Filter tickets by category
  List<Ticket> filterByCategory(String categoryName) {
    return tickets
        .where(
          (ticket) =>
              ticket.category.nama.toLowerCase() == categoryName.toLowerCase(),
        )
        .toList();
  }

  // Get tickets with low stock (less than 10)
  List<Ticket> getLowStockTickets() {
    return tickets.where((ticket) => ticket.stok < 10).toList();
  }

  // Get upcoming events (events that haven't happened yet)
  List<Ticket> getUpcomingEvents() {
    final now = DateTime.now();
    return tickets.where((ticket) => ticket.event.waktu.isAfter(now)).toList();
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchTickets();
  }

  // Private method to show error messages
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    if (tickets.isEmpty) {
      return {
        'totalTickets': 0,
        'totalRevenue': 0,
        'averagePrice': 0,
        'totalStock': 0,
        'lowStockCount': 0,
        'upcomingEventsCount': 0,
      };
    }

    final totalRevenue = tickets.fold<int>(
      0,
      (sum, ticket) => sum + (ticket.harga * ticket.stok),
    );
    final totalStock = tickets.fold<int>(0, (sum, ticket) => sum + ticket.stok);
    final averagePrice =
        tickets.fold<int>(0, (sum, ticket) => sum + ticket.harga) /
        tickets.length;
    final lowStockCount = getLowStockTickets().length;
    final upcomingEventsCount = getUpcomingEvents().length;

    return {
      'totalTickets': tickets.length,
      'totalRevenue': totalRevenue,
      'averagePrice': averagePrice.round(),
      'totalStock': totalStock,
      'lowStockCount': lowStockCount,
      'upcomingEventsCount': upcomingEventsCount,
    };
  }

  // Helper method untuk mendapatkan category ID dari nama (untuk form)
  int? getCategoryIdByName(String name) {
    try {
      final ticket = tickets.firstWhere((t) => t.category.nama == name);
      return ticket.category.idCategory;
    } catch (e) {
      return null;
    }
  }

  // Helper method untuk mendapatkan event ID dari nama (untuk form)
  int? getEventIdByName(String name) {
    try {
      final ticket = tickets.firstWhere((t) => t.event.namaEvent == name);
      return ticket.idEvent;
    } catch (e) {
      return null;
    }
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
