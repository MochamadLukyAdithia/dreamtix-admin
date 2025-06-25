// controllers/category_controller.dart
import 'package:dreamtix_admin/features/tiket/model/Tiket.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dreamtix_admin/core/constant/apiUrl.dart' as api;

class CategoryController extends GetxController {
  var categories = <Category>[].obs;
  var isLoading = false.obs;
  final String baseUrl = '${api.apiUrl}';

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('$baseUrl/category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoryList = data['data'];
        categories.value = categoryList
            .map((json) => Category.fromJson(json))
            .toList();
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch categories: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error fetching categories: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
