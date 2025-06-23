import 'package:dreamtix_admin/features/tiket/controller/TiketController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketScreen extends StatelessWidget {
  final TicketController controller = Get.put(TicketController());

  TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text("Daftar Tiket"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.tickets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.tickets.length,
          itemBuilder: (context, index) {
            final tiket = controller.tickets[index];
            return Card(
              color: Colors.white10,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  "${tiket.event.namaEvent} - ${tiket.category.nama}",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "Harga: ${tiket.harga}\nStok: ${tiket.stok}\nWaktu: ${tiket.event.waktu}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => controller.deleteTicket(tiket.idTiket),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
