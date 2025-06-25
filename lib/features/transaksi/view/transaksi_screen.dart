// screens/transaction_screen.dart
import 'package:dreamtix_admin/features/transaksi/controller/TransaksiController.dart';
import 'package:dreamtix_admin/features/transaksi/model/transaksi_model.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<TransactionData> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await TransactionController.getAllTransactions();
      if (response != null) {
        setState(() {
          transactions = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load transactions';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _showSuccessAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text(
              'Success',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'Error',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTransactionStatus(int idPesan, String newStatus) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    final success = await TransactionController.updateTransactionStatus(
      idTransaksi: idPesan,
      newStatus: newStatus,
    );

    Navigator.pop(context); // Close loading dialog

    if (success) {
      _showSuccessAlert('Status updated to $newStatus');
      _loadTransactions(); // Reload data
    } else {
      _showErrorAlert('Failed to update status');
    }
  }

  void _showStatusUpdateDialog(int idPesan, String currentStatus) {
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text(
          'Update Status',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: TransactionController.getStatusOptions().map((status) {
              return RadioListTile<String>(
                title: Text(
                  status,
                  style: const TextStyle(color: Colors.white),
                ),
                value: status,
                groupValue: selectedStatus,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setDialogState(() {
                    selectedStatus = value!;
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (selectedStatus != currentStatus) {
                _updateTransactionStatus(idPesan, selectedStatus);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text(
          'Transaction Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTransactions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : transactions.isEmpty
            ? const Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadTransactions,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionData transaction) {
    return Card(
      color: const Color(0xFF1E1E2E),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  transaction.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Orders
            ...transaction.pemesanans
                .map((pemesanan) => _buildOrderCard(pemesanan))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Pemesanan pemesanan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D3A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          Text(
            'Order #${pemesanan.idPesan}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Event details
          ...pemesanan.detailPemesanan
              .map((detail) => _buildEventDetail(detail))
              .toList(),

          const SizedBox(height: 12),

          // Transaction status
          ...pemesanan.transaksis
              .map(
                (transaksi) =>
                    _buildTransactionStatus(transaksi.idTransaksi, transaksi),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildEventDetail(DetailPemesanan detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              detail.tiket.event.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[800],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Event info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.tiket.event.namaEvent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${detail.tiket.category.nama} - ${detail.tiket.category.posisi}',
                  style: const TextStyle(color: Colors.blue, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${TransactionController.formatDate(detail.tiket.event.waktu)} at ${TransactionController.formatTime(detail.tiket.event.waktu)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${detail.quantity}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      TransactionController.formatCurrency(detail.total),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionStatus(int idPesan, Transaksi transaksi) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A4A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment: ${transaksi.metodePembayaran.nama}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(
                    TransactionController.getStatusColor(transaksi.status),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaksi.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _showStatusUpdateDialog(idPesan, transaksi.status),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
