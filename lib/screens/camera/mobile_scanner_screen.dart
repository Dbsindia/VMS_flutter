import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerScreen extends StatelessWidget {
  final Function(String?) onDetect;

  const MobileScannerScreen({
    required this.onDetect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcode) {
          final String? code = barcode.barcodes.first.rawValue;

          // Pass the detected code to the parent widget via `onDetect`
          onDetect(code);

          // Navigate back after detection
          if (code != null) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid QR Code detected.')),
            );
          }
        },
      ),
    );
  }
}
