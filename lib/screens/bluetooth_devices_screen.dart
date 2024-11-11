import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDevicesScreen extends StatefulWidget {
  const BluetoothDevicesScreen({super.key});

  @override
  BluetoothDevicesScreenState createState() => BluetoothDevicesScreenState();
}

class BluetoothDevicesScreenState extends State<BluetoothDevicesScreen> {
  late List<BluetoothDevice> connectedDevices;

  @override
  void initState() {
    super.initState();
    _loadConnectedDevices();
  }

  void _loadConnectedDevices() {
    connectedDevices = FlutterBluePlus.connectedDevices;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Devices"),
      ),
      body: connectedDevices.isEmpty
          ? const Center(child: Text("No connected Bluetooth devices."))
          : ListView.builder(
              itemCount: connectedDevices.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = connectedDevices[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth, color: Colors.deepPurple),
                  title: Text(device.platformName), // Use `platformName` for device name
                  subtitle: Text("ID: ${device.remoteId}"), // Use `remoteId` for device ID
                  onTap: () {
                    // Handle Bluetooth device interaction
                  },
                );
              },
            ),
    );
  }
}
