import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class NetworkCamerasScreen extends StatefulWidget {
  const NetworkCamerasScreen({super.key});

  @override
  _NetworkCamerasScreenState createState() => _NetworkCamerasScreenState();
}

class _NetworkCamerasScreenState extends State<NetworkCamerasScreen> {
  List<String> discoveredCameras = [];
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _discoverCameras();
  }

  Future<void> _discoverCameras() async {
    setState(() {
      isDiscovering = true;
    });

    const int port = 554; // Default RTSP port
    final List<String> cameras = [];
    final subnets = ["192.168.0", "192.168.1"]; // Adjust for your network

    for (String subnet in subnets) {
      final stream = NetworkAnalyzer.discover2(subnet, port, timeout: Duration(seconds: 2));
      await for (NetworkAddress addr in stream) {
        if (addr.exists) {
          cameras.add("rtsp://${addr.ip}:554/stream");
        }
      }
    }

    setState(() {
      discoveredCameras = cameras;
      isDiscovering = false;
    });
  }

  Future<void> _saveCamera(String url) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCameras = prefs.getStringList('savedCameras') ?? [];
    savedCameras.add("Network Camera|$url");
    await prefs.setStringList('savedCameras', savedCameras);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discover Network Cameras"),
        actions: [
          if (isDiscovering)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: discoveredCameras.isEmpty
          ? Center(
              child: isDiscovering
                  ? const Text("Discovering...")
                  : const Text("No cameras found."),
            )
          : ListView.builder(
              itemCount: discoveredCameras.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Camera ${index + 1}"),
                  subtitle: Text(discoveredCameras[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await _saveCamera(discoveredCameras[index]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Camera added.")),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
