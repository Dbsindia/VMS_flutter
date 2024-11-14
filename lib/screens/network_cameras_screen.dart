import 'package:flutter/material.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:endroid/services/firebase_service.dart'; // Import FirebaseService
import 'package:uuid/uuid.dart';

class NetworkCamerasScreen extends StatefulWidget {
  const NetworkCamerasScreen({super.key});

  @override
  _NetworkCamerasScreenState createState() => _NetworkCamerasScreenState();
}

class _NetworkCamerasScreenState extends State<NetworkCamerasScreen> {
  final FirebaseService _firebaseService = FirebaseService(); // FirebaseService instance
  final Uuid _uuid = const Uuid(); // For generating unique IDs

  List<String> discoveredCameras = [];
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _discoverCameras(); // Discover cameras on init
  }

  /// Discover cameras on the network
  Future<void> _discoverCameras() async {
    setState(() => isDiscovering = true);

    const int port = 554; // Default RTSP port
    final List<String> cameras = [];
    final subnets = ["192.168.0", "192.168.1"]; // Adjust for your network

    try {
      for (String subnet in subnets) {
        final stream = NetworkAnalyzer.discover2(
          subnet,
          port,
          timeout: const Duration(seconds: 2),
        );

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
    } catch (e) {
      setState(() => isDiscovering = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to discover cameras: $e")),
      );
    }
  }

  /// Save discovered camera to Firestore
  Future<void> _saveCameraToFirestore(String url) async {
    final cameraId = _uuid.v4(); // Generate unique ID
    final cameraName = "Discovered Camera ${discoveredCameras.indexOf(url) + 1}";

    try {
      await _firebaseService.addCameraStream(cameraId, cameraName, url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera '$cameraName' added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save camera: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discover Network Cameras"),
        actions: [
          if (isDiscovering)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.white),
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
                      await _saveCameraToFirestore(discoveredCameras[index]);
                    },
                  ),
                );
              },
            ),
    );
  }
}
