import 'package:dreamtix_admin/features/transaksi/controller/TransaksiController.dart';
import 'package:flutter/material.dart';
import 'package:dreamtix_admin/features/transaksi/model/transaksi_model.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  TransactionResponse? _transactionData;
  bool _isLoading = true;
  String _selectedPeriod = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  Future<void> _loadTransactionData() async {
    setState(() => _isLoading = true);

    try {
      final data = await TransactionController.getAllTransactions();
      setState(() {
        _transactionData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading transaction data: $e');
    }
  }

  // Calculate analytics from transaction data
  Map<String, dynamic> _calculateAnalytics() {
    if (_transactionData == null || _transactionData!.data.isEmpty) {
      return {
        'totalRevenue': 0,
        'totalTransactions': 0,
        'totalTickets': 0,
        'completedTransactions': 0,
        'pendingTransactions': 0,
        'cancelledTransactions': 0,
        'averageOrderValue': 0,
        'topEvents': <Map<String, dynamic>>[],
        'revenueByStatus': <String, int>{},
        'ticketsByCategory': <String, int>{},
      };
    }

    int totalRevenue = 0;
    int totalTransactions = 0;
    int totalTickets = 0;
    int completedTransactions = 0;
    int pendingTransactions = 0;
    int cancelledTransactions = 0;

    Map<String, int> eventRevenue = {};
    Map<String, int> eventTickets = {};
    Map<String, int> revenueByStatus = {};
    Map<String, int> ticketsByCategory = {};

    for (var userData in _transactionData!.data) {
      for (var pemesanan in userData.pemesanans) {
        totalTransactions++;

        // Calculate tickets and revenue from detail pemesanan
        for (var detail in pemesanan.detailPemesanan) {
          totalTickets += detail.quantity;
          totalRevenue += detail.total;

          String eventName = detail.tiket.event.namaEvent;
          String categoryName = detail.tiket.category.nama;

          // Track revenue by event
          eventRevenue[eventName] =
              (eventRevenue[eventName] ?? 0) + detail.total;
          eventTickets[eventName] =
              (eventTickets[eventName] ?? 0) + detail.quantity;

          // Track tickets by category
          ticketsByCategory[categoryName] =
              (ticketsByCategory[categoryName] ?? 0) + detail.quantity;
        }

        // Count transactions by status
        for (var transaksi in pemesanan.transaksis) {
          String status = transaksi.status.toUpperCase();

          int orderTotal = pemesanan.detailPemesanan.fold(
            0,
            (sum, detail) => sum + detail.total,
          );
          revenueByStatus[status] = (revenueByStatus[status] ?? 0) + orderTotal;

          switch (status) {
            case 'LUNAS':
              completedTransactions++;
              break;
            case 'PENDING':
              pendingTransactions++;
              break;
            case 'DIBATALKAN':
              cancelledTransactions++;
              break;
          }
        }
      }
    }

    // Create top events list
    List<Map<String, dynamic>> topEvents = eventRevenue.entries
        .map(
          (entry) => {
            'name': entry.key,
            'revenue': entry.value,
            'tickets': eventTickets[entry.key] ?? 0,
          },
        )
        .toList();

    topEvents.sort((a, b) => b['revenue'].compareTo(a['revenue']));
    topEvents = topEvents.take(5).toList();

    double averageOrderValue = totalTransactions > 0
        ? totalRevenue / totalTransactions
        : 0;

    return {
      'totalRevenue': totalRevenue,
      'totalTransactions': totalTransactions,
      'totalTickets': totalTickets,
      'completedTransactions': completedTransactions,
      'pendingTransactions': pendingTransactions,
      'cancelledTransactions': cancelledTransactions,
      'averageOrderValue': averageOrderValue,
      'topEvents': topEvents,
      'revenueByStatus': revenueByStatus,
      'ticketsByCategory': ticketsByCategory,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : RefreshIndicator(
                onRefresh: _loadTransactionData,
                color: Colors.blue,
                backgroundColor: const Color(0xFF1A1F3A),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),

                      _buildAnalyticsCards(),
                      const SizedBox(height: 20),
                      _buildRevenueChart(),
                      const SizedBox(height: 20),
                      _buildTopEvents(),
                      const SizedBox(height: 20),
                      _buildCategoryBreakdown(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Analytics & Laporan Keuntungan',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Icon(Icons.analytics, color: Colors.blue, size: 24),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCards() {
    final analytics = _calculateAnalytics();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Total Pendapatan',
                TransactionController.formatCurrency(analytics['totalRevenue']),
                Icons.attach_money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalyticsCard(
                'Total Transaksi',
                '${analytics['totalTransactions']}',
                Icons.receipt_long,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Tiket Terjual',
                '${analytics['totalTickets']}',
                Icons.confirmation_number,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalyticsCard(
                'Rata² Nilai Order',
                TransactionController.formatCurrency(
                  analytics['averageOrderValue'].round(),
                ),
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.arrow_upward, color: color, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    final analytics = _calculateAnalytics();
    final revenueByStatus = analytics['revenueByStatus'] as Map<String, int>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pendapatan Berdasarkan Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...revenueByStatus.entries.map((entry) {
            final percentage = analytics['totalRevenue'] > 0
                ? (entry.value / analytics['totalRevenue'] * 100)
                : 0.0;

            Color statusColor = Color(
              TransactionController.getStatusColor(entry.key),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            TransactionController.formatCurrency(entry.value),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopEvents() {
    final analytics = _calculateAnalytics();
    final topEvents = analytics['topEvents'] as List<Map<String, dynamic>>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Terlaris',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (topEvents.isEmpty)
            Center(
              child: Text(
                'Belum ada data event',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            )
          else
            ...topEvents.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E27),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? Colors.amber
                            : index == 1
                            ? Colors.grey[400]
                            : index == 2
                            ? Colors.brown
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${event['tickets']} tiket terjual',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      TransactionController.formatCurrency(event['revenue']),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final analytics = _calculateAnalytics();
    final ticketsByCategory =
        analytics['ticketsByCategory'] as Map<String, int>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Tiket per Kategori',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (ticketsByCategory.isEmpty)
            Center(
              child: Text(
                'Belum ada data kategori',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            )
          else
            ...ticketsByCategory.entries.map((entry) {
              final totalTickets = analytics['totalTickets'] as int;
              final percentage = totalTickets > 0
                  ? (entry.value / totalTickets * 100)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${entry.value} tiket',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
