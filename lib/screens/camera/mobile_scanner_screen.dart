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
        onDetect: (barcode, args) {
          // Extract the barcode data
          final String? code = barcode.rawValue;

          // Pass the result back to the parent widget
          onDetect(code);

          // Navigate back after detection
          Navigator.pop(context);
        },
      ),
    );
  }
}
