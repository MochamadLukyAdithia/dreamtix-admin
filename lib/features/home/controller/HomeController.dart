import 'dart:convert';
import 'package:dreamtix_admin/features/home/model/EventModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dreamtix_admin/core/constant/apiUrl.dart' as api;

class Homecontroller extends GetxController {
  final events = <EventModel>[].obs;
  final isLoading = false.obs;

  final isSubmitting = false.obs;

  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse('${api.apiUrl}/events'));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        events.value = data.map((e) => EventModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createEvent({
    required String namaEvent,
    required String artis,
    required DateTime waktu,
    int idAdmin = 1,
  }) async {
    isSubmitting.value = true;
    try {
      final body = jsonEncode({
        "id_admin": idAdmin,
        "nama_event": namaEvent,
        "artis": artis,
        "waktu": waktu,
      });

      final response = await http.post(
        Uri.parse("${api.apiUrl}/events"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchEvents(); // refresh data
        return true;
      } else {
        print('Create failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating event: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onInit() {
    fetchEvents();
    super.onInit();
  }
}
