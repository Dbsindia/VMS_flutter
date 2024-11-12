import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerScreen extends StatelessWidget {
  final Function(String?) onDetect;

  const MobileScannerScreen({required this.onDetect, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcode) {
          final String? code = barcode.barcodes.first.rawValue;

          if (code != null) {
            // Pass the result back to the parent widget
            onDetect(code);

            // Navigate back after detection
            Navigator.pop(context);
          } else {
            // Handle cases where the QR code might not have valid data
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid QR Code detected.')),
            );
          }
        },
      ),
    );
  }
}
