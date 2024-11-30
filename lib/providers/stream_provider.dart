import 'package:endroid/controllers/vlc_controller_initializer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stream_model.dart';
import 'package:easy_onvif/onvif.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class StreamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<StreamModel> streams = [];
  List<VlcPlayerController?> controllers = [];
  bool isLoading = false;
  int gridCount = 1; // Default layout: 1x1
  Onvif? onvif;

  /// Initialize ONVIF with credentials
  Future<void> initializeOnvif({
    required String host,
    required String username,
    required String password,
  }) async {
    try {
      onvif = await Onvif.connect(
        host: host,
        username: username,
        password: password,
      );
      debugPrint("ONVIF initialized for $host");
    } catch (e) {
      debugPrint("Failed to initialize ONVIF: $e");
      throw Exception("Failed to initialize ONVIF for host $host");
    }
  }

  /// Load streams with a real-time listener
  void loadStreams() {
    _firestore.collection('cameraStreams').snapshots().listen((snapshot) {
      streams = snapshot.docs.map((doc) {
        return StreamModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      _syncControllersWithStreams();
      notifyListeners();
    });

    isLoading = false;
    notifyListeners();
  }

  /// Sync controllers with streams to avoid mismatches
  void _syncControllersWithStreams() {
    while (controllers.length > streams.length) {
      final controller = controllers.removeLast();
      controller?.stop();
      controller?.dispose();
    }
    while (controllers.length < streams.length) {
      controllers.add(null);
    }
  }

  /// Discover ONVIF devices and add them to the stream list
  Future<void> discoverCameras(
      String subnet, int port, String username, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final discoveredDevices = await _discoverDevices(subnet, port);

      for (final ip in discoveredDevices) {
        try {
          await initializeOnvif(
            host: ip,
            username: username,
            password: password,
          );

          // Fetch RTSP URL and Snapshot URL
          final rtspUrl = await _fetchRtspUrl();
          final snapshotUrl = await _fetchSnapshotUrl();

          if (rtspUrl == null || !rtspUrl.startsWith('rtsp://')) {
            debugPrint("Invalid RTSP URL for device at $ip");
            continue;
          }

          final newStream = StreamModel(
            id: '', // Firestore will assign the ID
            name: 'Discovered Device ($ip)',
            url: rtspUrl,
            snapshotUrl: snapshotUrl ?? '',
            isOnline: true,
            createdAt: DateTime.now(),
          );

          // Save to Firestore
          await _firestore.collection('cameraStreams').add(newStream.toJson());
        } catch (e) {
          debugPrint("Error discovering device at $ip: $e");
        }
      }
    } catch (e) {
      debugPrint("Error during discovery: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Discover devices using ping_discover_network
  Future<List<String>> _discoverDevices(String subnet, int port) async {
    final List<String> devices = [];
    final stream = NetworkAnalyzer.discover2(subnet, port);

    await for (final addr in stream) {
      if (addr.exists) {
        devices.add(addr.ip);
        debugPrint('Discovered device: ${addr.ip}');
      }
    }
    return devices;
  }

  /// Fetch RTSP URL using ONVIF
  Future<String?> _fetchRtspUrl() async {
    try {
      if (onvif == null) {
        throw Exception(
            "ONVIF is not initialized. Call initializeOnvif first.");
      }

      final profiles = await onvif!.media.getProfiles();
      if (profiles.isNotEmpty) {
        return await onvif!.media.getStreamUri(profiles.first.token);
      }
    } catch (e) {
      debugPrint("Error fetching RTSP URL: $e");
    }
    return null;
  }

  Future<String?> _fetchSnapshotUrl() async {
    try {
      if (onvif == null) {
        throw Exception(
            "ONVIF is not initialized. Call initializeOnvif first.");
      }

      final profiles = await onvif!.media.getProfiles();
      if (profiles.isNotEmpty) {
        return await onvif!.media.getSnapshotUri(profiles.first.token);
      }
    } catch (e) {
      debugPrint("Error fetching Snapshot URL: $e");
    }
    return null;
  }

  /// Validate a stream by pinging the RTSP URL
  Future<bool> _validateStream(StreamModel stream) async {
    // Simulate validation logic (e.g., network ping)
    return stream.isValidUrl;
  }

  /// Refresh the status of all streams
  Future<void> refreshStreamStatus() async {
    for (var stream in streams) {
      final isValid = await _validateStream(stream);
      final updatedStream = stream.updateOnlineStatus(isValid);

      // Update Firestore with the new status
      await _firestore
          .collection('cameraStreams')
          .doc(updatedStream.id)
          .update(updatedStream.toJson());
    }

    notifyListeners();
  }

  /// Initialize VLC Player Controller
  Future<VlcPlayerController> initializeController(String url) async {
  try {
    debugPrint("Initializing VLC Player with URL: $url");

    // Ensure URL is valid before initializing
    if (url.isEmpty || !url.startsWith('rtsp://')) {
      throw Exception("Invalid RTSP URL: $url");
    }

    // Create a new controller instance
    final controller = VlcPlayerController.network(
      url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    // Wait for initialization
    await controller.initialize();
    return controller;
  } catch (e) {
    debugPrint("Failed to initialize VLC Player: $e");
    throw Exception("Failed to initialize VLC Player: $e");
  }
}


  /// Delete a Stream
  Future<void> deleteStream(int index) async {
    if (index < 0 || index >= streams.length) {
      throw Exception("Invalid stream index. Unable to delete.");
    }

    try {
      final streamId = streams[index].id;

      await _firestore.collection('cameraStreams').doc(streamId).delete();

      controllers[index]?.stop();
      controllers[index]?.dispose();

      streams = List<StreamModel>.from(streams)..removeAt(index);
      controllers = List<VlcPlayerController?>.from(controllers)
        ..removeAt(index);

      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting stream: $e");
      throw Exception("Failed to delete stream. Reason: $e");
    }
  }

  /// Update Grid Layout
  void updateGridLayout(int count) {
    gridCount = count;
    notifyListeners();
  }

  /// Dispose All Controllers
  void disposeControllers() {
    for (var controller in controllers) {
      controller?.stop();
      controller?.dispose();
    }
    controllers.clear();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }
}
