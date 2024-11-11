import 'package:endroid/screens/bluetooth_devices_screen.dart';
import 'package:endroid/screens/network_cameras_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AddCameraScreen extends StatefulWidget {
  const AddCameraScreen({super.key});

  @override
  AddCameraScreenState createState() => AddCameraScreenState(); // Made State public
}

class AddCameraScreenState extends State<AddCameraScreen> {
  String scannedResult = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Camera"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // QR Code Scanner
          ListTile(
            leading: const Icon(Icons.qr_code_scanner, color: Colors.deepPurple),
            title: const Text("Scan QR Code"),
            subtitle: const Text("Scan a QR code to add a camera"),
            onTap: _scanQrCode,
          ),
          const Divider(),

          // Connect to Bluetooth Devices
          ListTile(
            leading: const Icon(Icons.bluetooth, color: Colors.deepPurple),
            title: const Text("Connect via Bluetooth"),
            subtitle: const Text("Search and connect to nearby Bluetooth devices"),
            onTap: _searchBluetoothDevices,
          ),
          const Divider(),

          // Discover Cameras on Same Network
          ListTile(
            leading: const Icon(Icons.wifi, color: Colors.deepPurple),
            title: const Text("Discover Network Cameras"),
            subtitle: const Text("Find and add cameras on the same network"),
            onTap: _discoverNetworkCameras,
          ),
          const Divider(),

          // Manual Camera Addition
          ListTile(
            leading: const Icon(Icons.add, color: Colors.deepPurple),
            title: const Text("Add Camera Manually"),
            subtitle: const Text("Enter camera details manually"),
            onTap: () => _addCameraManually(context),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCamera(String name, String url) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cameras = prefs.getStringList('savedCameras') ?? [];
    cameras.add('$name|$url');
    await prefs.setStringList('savedCameras', cameras);
  }

  Future<void> _scanQrCode() async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRCodeScannerScreen(),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      scannedResult = result;
    });

    await _saveCamera("QR Camera", result);
    if (!mounted) return; // Double-check before using BuildContext
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Scanned and added: $result")),
    );
  }

  void _searchBluetoothDevices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BluetoothDevicesScreen(),
      ),
    );
  }

  void _discoverNetworkCameras() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NetworkCamerasScreen(),
      ),
    );
  }

  Future<void> _addCameraManually(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Camera Manually"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Enter Camera Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: "Enter RTSP or IP URL",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    urlController.text.isNotEmpty) {
                  await _saveCamera(nameController.text, urlController.text);
                  if (!mounted) return; // Ensure widget is still valid
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Camera added successfully!")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}

class QRCodeScannerScreen extends StatelessWidget {
  const QRCodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
      ),
      body: MobileScanner(
        onDetect: (barcode, _) {
          if (barcode.rawValue != null) {
            Navigator.pop(context, barcode.rawValue);
          }
        },
      ),
    );
  }
}
