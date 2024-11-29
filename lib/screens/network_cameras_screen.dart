import 'package:flutter/material.dart';
import 'package:endroid/services/firebase_service.dart'; // Import FirebaseService
import 'package:uuid/uuid.dart';
import 'package:easy_onvif/onvif.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class NetworkCamerasScreen extends StatefulWidget {
  const NetworkCamerasScreen({super.key});

  @override
  State<NetworkCamerasScreen> createState() => _NetworkCamerasScreenState();
}

class _NetworkCamerasScreenState extends State<NetworkCamerasScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();

  List<Map<String, String>> discoveredDevices = [];
  bool isDiscovering = false;

  /// Discover devices in the local network
  Future<void> _discoverDevices() async {
    const int port = 80; // Default ONVIF port
    const String subnet = "192.168.1"; // Update for your network

    setState(() {
      discoveredDevices.clear();
      isDiscovering = true;
    });

    try {
      final stream = NetworkAnalyzer.discover2(subnet, port);

      await for (final addr in stream) {
        if (addr.exists) {
          setState(() {
            discoveredDevices.add({
              'ip': addr.ip,
              'name': 'Discovered Device (${addr.ip})',
            });
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error discovering devices: $e")),
      );
    } finally {
      setState(() {
        isDiscovering = false;
      });
    }
  }

  /// Discover cameras using ONVIF for the given IP
  Future<void> _discoverCameras(String ip) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in username and password.")),
      );
      return;
    }

    setState(() => isDiscovering = true);

    try {
      final onvif = await Onvif.connect(
        host: ip,
        username: username,
        password: password,
      );

      final deviceInfo = await onvif.deviceManagement.getDeviceInformation();
      final profiles = await onvif.media.getProfiles();

      if (profiles.isEmpty) {
        throw Exception("No profiles available for $ip");
      }

      final rtspUrl = await onvif.media.getStreamUri(profiles.first.token);
      final snapshotUrl = await onvif.media.getSnapshotUri(profiles.first.token);

      final camera = {
        'name': deviceInfo.model ?? 'Unknown Camera',
        'url': rtspUrl ?? '',
        'snapshotUrl': snapshotUrl ?? '',
      };

      await _saveCameraToFirestore(camera['name']!, camera['url']!, camera['snapshotUrl']!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to device at $ip: $e")),
      );
    } finally {
      setState(() => isDiscovering = false);
    }
  }

  /// Save discovered camera to Firestore
  Future<void> _saveCameraToFirestore(String name, String rtspUrl, String snapshotUrl) async {
    final cameraId = _uuid.v4();
    try {
      await _firebaseService.addCameraStream(cameraId, name, rtspUrl, snapshotUrl: snapshotUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera '$name' added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save camera: $e")),
      );
    }
  }

  /// Show dialog to collect ONVIF credentials
  void _showCredentialsDialog(String ip) {
    _ipController.text = ip;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter ONVIF Credentials"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(labelText: "Camera IP Address"),
                readOnly: true,
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _discoverCameras(ip);
              },
              child: const Text("Discover"),
            ),
          ],
        );
      },
    );
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _discoverDevices,
          ),
        ],
      ),
      body: discoveredDevices.isEmpty
          ? Center(
              child: isDiscovering
                  ? const Text("Discovering devices...")
                  : const Text("No devices found. Tap refresh to search."),
            )
          : ListView.builder(
              itemCount: discoveredDevices.length,
              itemBuilder: (context, index) {
                final device = discoveredDevices[index];
                return ListTile(
                  title: Text(device['name']!),
                  subtitle: Text(device['ip']!),
                  onTap: () => _showCredentialsDialog(device['ip']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _saveCameraToFirestore(
                      device['name']!,
                      device['ip']!,
                      '', // Placeholder for snapshot URL if not available
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _ipController.dispose();
    super.dispose();
  }
}
