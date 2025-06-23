import 'dart:convert';
import 'package:dreamtix_admin/features/tiket/model/Tiket.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TicketController extends GetxController {
  var tickets = <Ticket>[].obs;
  final String baseUrl = "http://10.0.2.2:3000/api/tikets";

  @override
  void onInit() {
    fetchTickets();
    super.onInit();
  }

  Future<void> fetchTickets() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        tickets.value = data.map((json) => Ticket.fromJson(json)).toList();
      } else {
        Get.snackbar("Error", "Failed to fetch tickets");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteTicket(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      if (res.statusCode == 200) {
        tickets.removeWhere((ticket) => ticket.idTiket == id);
      } else {
        Get.snackbar("Error", "Failed to delete ticket");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // Tambahkan create dan update jika diperlukan
}
