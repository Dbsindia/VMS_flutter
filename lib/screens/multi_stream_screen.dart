import 'package:endroid/screens/add_camera_screen.dart';
import 'package:endroid/screens/bluetooth_devices_screen.dart';
import 'package:endroid/screens/camera/mobile_scanner_screen.dart';
import 'package:endroid/screens/network_cameras_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stream_provider.dart' as custom_stream_provider;
import '../widgets/stream_card.dart';
import 'full_screen_view.dart';

class MultiStreamScreen extends StatefulWidget {
  const MultiStreamScreen({super.key});

  @override
  State<MultiStreamScreen> createState() => _MultiStreamScreenState();
}

class _MultiStreamScreenState extends State<MultiStreamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStreamsOnInit();
    });
  }

  /// Load streams from the provider during initialization
  Future<void> _loadStreamsOnInit() async {
    try {
      final streamProvider = Provider.of<custom_stream_provider.StreamProvider>(
        context,
        listen: false,
      );
      streamProvider.loadStreams(); // Real-time listener
    } catch (e) {
      debugPrint("Error loading streams during init: $e");
      _showSnackBar("Failed to load streams on init.");
    }
  }

  /// Show a snackbar with the given message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Open the camera options bottom sheet
  void _openAddCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.qr_code_scanner, color: Colors.deepPurple),
              title: const Text("Scan QR Code"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MobileScannerScreen(
                      onDetect: (String? code) {
                        if (code != null) {
                          _showSnackBar("QR Code Detected: $code");
                        } else {
                          _showSnackBar("Invalid QR Code");
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth, color: Colors.deepPurple),
              title: const Text("Discover Bluetooth Devices"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BluetoothDevicesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.wifi, color: Colors.deepPurple),
              title: const Text("Discover Network Cameras"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NetworkCamerasScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.deepPurple),
              title: const Text("Add Camera Manually"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCameraScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final streamProvider =
        Provider.of<custom_stream_provider.StreamProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Streams"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                streamProvider.loadStreams(); // Refresh using real-time updates
                _showSnackBar("Streams refreshed.");
              } catch (e) {
                _showSnackBar("Failed to refresh streams: $e");
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Camera",
            onPressed: () => _openAddCameraOptions(context),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.grid_view),
            tooltip: "Change Layout",
            onSelected: (value) {
              streamProvider.updateGridLayout(value);
              _showSnackBar("Layout changed to $value x $value");
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("1x1 Layout")),
              const PopupMenuItem(value: 2, child: Text("2x2 Layout")),
              const PopupMenuItem(value: 3, child: Text("3x3 Layout")),
            ],
          ),
        ],
      ),
      body: streamProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : streamProvider.streams.isEmpty
              ? const Center(child: Text("No streams available. Add one!"))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final gridCount = streamProvider.gridCount;
                    final childAspectRatio = gridCount == 1
                        ? 1.5
                        : constraints.maxWidth /
                            (constraints.maxHeight / gridCount);

                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: streamProvider.streams.length,
                      itemBuilder: (context, index) {
                        final stream = streamProvider.streams[index];
                        return StreamCard(
                          stream: stream,
                          onOfflineAssistance: () {
                            _showSnackBar(
                                "Check power supply and network cables.");
                          },
                         onCardDoubleTap: () async {
  if (!stream.isValidUrl) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid RTSP URL.")),
    );
    return;
  }

  try {
    final controller = await streamProvider.initializeController(stream.url);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenView(
          stream: stream,
          controller: controller,
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  }
},

                          onDelete: () async {
                            try {
                              await streamProvider.deleteStream(index);
                              _showSnackBar(
                                  "${stream.name} deleted successfully.");
                            } catch (e) {
                              _showSnackBar(
                                  "Error deleting stream: ${e.toString()}");
                            }
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}
