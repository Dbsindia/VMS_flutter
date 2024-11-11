import 'package:flutter/material.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class NetworkCamerasScreen extends StatefulWidget {
  const NetworkCamerasScreen({super.key});

  @override
  _NetworkCamerasScreenState createState() => _NetworkCamerasScreenState();
}

class _NetworkCamerasScreenState extends State<NetworkCamerasScreen> {
  List<String> discoveredCameras = [];

  Future<void> _discoverCameras() async {
    const String subnet = "192.168.1"; // Adjust the subnet as needed
    const int port = 554; // RTSP port
    final List<String> cameras = [];

    final stream = NetworkAnalyzer.discover2(subnet, port, timeout: Duration(seconds: 2));
    await for (NetworkAddress addr in stream) {
      if (addr.exists) {
        cameras.add(addr.ip);
      }
    }

    if (mounted) {
      setState(() {
        discoveredCameras = cameras;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _discoverCameras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Network Cameras"),
      ),
      body: discoveredCameras.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: discoveredCameras.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Camera ${index + 1}"),
                  subtitle: Text(discoveredCameras[index]),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Selected: ${discoveredCameras[index]}")),
                    );
                  },
                );
              },
            ),
    );
  }
}
