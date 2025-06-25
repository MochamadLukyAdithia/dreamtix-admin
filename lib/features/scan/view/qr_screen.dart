import 'package:dreamtix_admin/features/scan/controller/QrController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  late final QrController qrController;

  String? scannedResult;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan benar
    qrController = Get.put(QrController(), permanent: false);
    print('QrController initialized in view');
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin kamera diperlukan untuk scan QR Code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onQRDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty && scannedResult == null) {
      final String? code = barcodes.first.rawValue;

      if (code != null && code.isNotEmpty) {
        print('QR Code detected: $code');

        setState(() {
          scannedResult = code;
        });

        cameraController.stop();
        HapticFeedback.mediumImpact();

        // Update controller state
        qrController.scannedResult.value = code;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code berhasil dipindai!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _toggleFlash() async {
    try {
      await cameraController.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  void _resetScanner() {
    print('Reset scanner called');
    setState(() {
      scannedResult = null;
    });
    qrController.resetScanner();
    cameraController.start();
  }

  // Method untuk menampilkan alert dialog success
  void _showSuccessAlert(String message) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Berhasil',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Tutup dialog
              _resetScanner(); // Auto reset scanner setelah sukses
            },
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      barrierDismissible: false,
    );
  }

  // Method untuk menampilkan alert dialog error
  void _showErrorAlert(String message) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Error',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      barrierDismissible: false,
    );
  }

  // Method untuk menampilkan alert dialog info
  void _showInfoAlert(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      barrierDismissible: false,
    );
  }

  void _copyToClipboard() async {
    if (scannedResult != null) {
      print('Copy to clipboard: $scannedResult');
      final result = await qrController.copyToClipboard(scannedResult!);

      if (result['success']) {
        _showSuccessAlert(result['message']);
      } else {
        _showErrorAlert(result['message']);
      }
    }
  }

  void _useResult() async {
    if (scannedResult != null) {
      print('Use result called with: $scannedResult');

      final result = await qrController.updateQr(scannedResult!);

      if (result['success']) {
        _showSuccessAlert(result['message']);
      } else {
        _showErrorAlert(result['message']);
      }
    }
  }

  void _testConnection() async {
    print('Test connection called');

    final result = await qrController.testConnection();

    if (result['success']) {
      _showInfoAlert(
        'Test Koneksi',
        'Response Status: ${result['statusCode']}\n${result['message']}',
      );
    } else {
      _showErrorAlert(result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
          // Tambahkan tombol test untuk debugging
          IconButton(
            onPressed: _testConnection,
            icon: const Icon(Icons.network_check, color: Colors.white),
            tooltip: 'Test Connection',
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera Scanner Section
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // Mobile Scanner
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onQRDetected,
                ),

                // Overlay dengan border
                Container(
                  decoration: ShapeDecoration(
                    shape: QRScannerOverlay(
                      borderColor: Colors.blue,
                      borderWidth: 4.0,
                      cutOutSize: 250.0,
                    ),
                  ),
                ),

                // Instruction text
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.08,
                  left: 0,
                  right: 0,
                  child: const Text(
                    'Arahkan kamera ke QR Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading indicator saat proses API
                Obx(
                  () => qrController.isLoading.value
                      ? Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Memproses QR Code...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Result Section
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              minHeight: 200,
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (scannedResult != null) ...[
                    // Result Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.qr_code, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Hasil Scan:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              scannedResult!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: qrController.isLoading.value
                                ? null
                                : _copyToClipboard,
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Salin'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => ElevatedButton.icon(
                              onPressed: qrController.isLoading.value
                                  ? null
                                  : _useResult,
                              icon: qrController.isLoading.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.send, size: 18),
                              label: Text(
                                qrController.isLoading.value
                                    ? 'Proses...'
                                    : 'Gunakan',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Reset Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: qrController.isLoading.value
                            ? null
                            : _resetScanner,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Scan Ulang'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Empty State
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            size: 48,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada QR Code yang dipindai',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Arahkan kamera ke QR Code untuk mulai scanning',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('Disposing QRScannerScreen');
    cameraController.dispose();
    // Hapus controller saat screen di-dispose
    if (Get.isRegistered<QrController>()) {
      Get.delete<QrController>();
    }
    super.dispose();
  }
}

// QR Scanner Overlay (sama seperti sebelumnya)
class QRScannerOverlay extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double cutOutSize;
  final Color overlayColor;

  const QRScannerOverlay({
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.cutOutSize = 200.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.5),
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );
    return Path()..addRect(cutOutRect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    return Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()..addRect(cutOutRect),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()..addRect(cutOutRect),
    );

    canvas.drawPath(overlayPath, overlayPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    const cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top + cornerLength),
      Offset(cutOutRect.left, cutOutRect.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top),
      Offset(cutOutRect.left + cornerLength, cutOutRect.top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(cutOutRect.right - cornerLength, cutOutRect.top),
      Offset(cutOutRect.right, cutOutRect.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.top),
      Offset(cutOutRect.right, cutOutRect.top + cornerLength),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom - cornerLength),
      Offset(cutOutRect.right, cutOutRect.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom),
      Offset(cutOutRect.right - cornerLength, cutOutRect.bottom),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(cutOutRect.left + cornerLength, cutOutRect.bottom),
      Offset(cutOutRect.left, cutOutRect.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom),
      Offset(cutOutRect.left, cutOutRect.bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QRScannerOverlay(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      cutOutSize: cutOutSize * t,
      overlayColor: overlayColor,
    );
  }
}
