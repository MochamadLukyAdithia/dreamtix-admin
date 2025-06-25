import 'package:dreamtix_admin/features/event/view/event_screen.dart';
import 'package:dreamtix_admin/features/profile/view/profile_screen.dart';
import 'package:dreamtix_admin/features/scan/view/qr_screen.dart';
import 'package:dreamtix_admin/features/tiket/view/tiket_screen.dart';
import 'package:dreamtix_admin/features/transaksi/view/transaksi_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    EventListScreen(),
    TicketScreen(),
    TransactionScreen(),
    ProfileScreen(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(child: _buildNavItem(Icons.home, 'Home', 0)),
              Expanded(child: _buildNavItem(Icons.calendar_today, 'Event', 1)),
              const SizedBox(width: 60),
              Expanded(child: _buildNavItem(Icons.shop, 'Transaksi', 2)),
              Expanded(child: _buildNavItem(Icons.person, 'Profile', 3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.5),
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            HapticFeedback.mediumImpact();
            _openQRScanner(context);
          },
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _openQRScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && mounted) {
      _handleQRResult(result);
    }
  }

  void _handleQRResult(String qrValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'QR Code Ditemukan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nilai QR Code:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E27),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                qrValue,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Apa yang ingin Anda lakukan dengan data ini?',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              _processQRCode(qrValue);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Proses', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processQRCode(String qrValue) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Memproses QR Code: ${qrValue.length > 30 ? '${qrValue.substring(0, 30)}...' : qrValue}',
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Detail',
          textColor: Colors.white,
          onPressed: () {
            _showQRProcessingResult(qrValue);
          },
        ),
      ),
    );
  }

  void _showQRProcessingResult(String qrValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Detail Pemrosesan QR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QR Code Value:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E27),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  qrValue,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Status: Berhasil diproses',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
