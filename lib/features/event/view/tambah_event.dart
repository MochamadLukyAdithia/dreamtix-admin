
import 'package:dreamtix_admin/features/home/controller/HomeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TambahEvent extends StatefulWidget {
  const TambahEvent({super.key});

  @override
  State<TambahEvent> createState() => _TambahEventState();
}

class _TambahEventState extends State<TambahEvent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaEventC = TextEditingController();
  final TextEditingController artisC = TextEditingController();
  DateTime? selectedDate;

  final Homecontroller eventController = Get.find<Homecontroller>();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) return;

    final success = await eventController.createEvent(
      namaEvent: namaEventC.text,
      artis: artisC.text,
      waktu: selectedDate!,
    );

    if (success) {
      Get.back();
      Get.snackbar(
        "Berhasil",
        "Event berhasil ditambahkan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Gagal",
        "Gagal menambahkan event",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (result != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          selectedDate = DateTime(
            result.year,
            result.month,
            result.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Tambah Event", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() => Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(namaEventC, "Nama Event"),
                  const SizedBox(height: 16),
                  _buildTextField(artisC, "Artis"),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F3A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.toLocal()}".split('.')[0]
                            : "Pilih Tanggal & Waktu",
                        style: TextStyle(
                          color: selectedDate != null
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: eventController.isSubmitting.value ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: eventController.isSubmitting.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Simpan", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1F3A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
