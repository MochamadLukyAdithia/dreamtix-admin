// screens/ticket_screen.dart
import 'package:dreamtix_admin/features/tiket/controller/TiketController.dart';
import 'package:dreamtix_admin/features/tiket/model/Tiket.dart';
import 'package:dreamtix_admin/features/tiket/view/form_dialog_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketScreen extends StatelessWidget {
  final TicketController controller = Get.put(TicketController());
  TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C2D),
      appBar: AppBar(
        title: const Text(
          "Management Event",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1B3A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          );
        }

        if (controller.tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  "Belum ada tiket",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tambah tiket pertama Anda",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchTickets,
          color: const Color(0xFF6C63FF),
          backgroundColor: const Color(0xFF1E1E3A),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.tickets.length,
            itemBuilder: (context, index) {
              final tiket = controller.tickets[index];
              return _buildTicketCard(context, tiket);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTicketDialog(context, null),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket tiket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E1E3A), const Color(0xFF2A2A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTicketHeader(tiket),
            const SizedBox(height: 16),
            _buildTicketInfo(tiket),
            const SizedBox(height: 12),
            _buildEventDateTime(tiket),
            const SizedBox(height: 16),
            _buildActionButtons(context, tiket),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketHeader(Ticket tiket) {
    return Row(
      children: [
        // Image section dengan ukuran tetap
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              tiket.event.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 30,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
          ),
        ),
        // Text section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tiket.event.namaEvent,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "by ${tiket.event.artis}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C63FF), width: 1),
          ),
          child: Text(
            tiket.category.nama,
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketInfo(Ticket tiket) {
    return Row(
      children: [
        _buildInfoCard(
          icon: Icons.attach_money,
          label: "Harga",
          value: "Rp ${_formatNumber(tiket.harga)}",
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 12),
        _buildInfoCard(
          icon: Icons.inventory,
          label: "Stok",
          value: "${tiket.stok}",
          color: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildEventDateTime(Ticket tiket) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.white.withOpacity(0.7), size: 16),
          const SizedBox(width: 8),
          Text(
            _formatDateTime(tiket.event.waktu),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Ticket tiket) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          icon: Icons.edit,
          color: const Color(0xFF2196F3),
          onPressed: () => _showTicketDialog(context, tiket),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.delete,
          color: const Color(0xFFF44336),
          onPressed: () => _showDeleteDialog(context, tiket),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _showTicketDialog(BuildContext context, Ticket? ticket) {
    showDialog(
      context: context,
      builder: (context) => TicketFormDialog(ticket: ticket),
    );
  }

  void _showDeleteDialog(BuildContext context, Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Hapus Tiket",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus tiket ${ticket.event.namaEvent} - ${ticket.category.nama}?",
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Batal",
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteTicket(ticket.idTiket);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
