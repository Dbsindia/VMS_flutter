import 'package:flutter/foundation.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stream_model.dart';

class StreamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<StreamModel> streams = [];
  List<VlcPlayerController?> controllers = [];
  bool isLoading = false;
  int gridCount = 1; // Default layout: 1x1

  /// Load streams from Firestore
  Future<void> loadStreams() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('cameraStreams').get();
      streams = snapshot.docs.map((doc) {
        return StreamModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Dispose old controllers and create placeholders for new ones
      disposeControllers();
      controllers = List<VlcPlayerController?>.filled(
        streams.length,
        null,
        growable: false,
      );

      debugPrint("Streams loaded successfully: ${streams.length}");
    } catch (e) {
      debugPrint("Error loading streams: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize VLC Player Controller
  Future<VlcPlayerController> initializeController(String url) async {
    final existingIndex = streams.indexWhere((stream) => stream.url == url);

    if (existingIndex != -1 && controllers[existingIndex] != null) {
      final existingController = controllers[existingIndex];
      if (existingController != null &&
          existingController.value.isInitialized) {
        debugPrint("Reusing existing VLC controller for URL: $url");
        return existingController;
      }
    }

    try {
      final controller = VlcPlayerController.network(
        url,
        hwAcc: HwAcc.full,
        autoPlay: false,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            '--network-caching=300',
            '--rtsp-tcp',
          ]),
        ),
      );

      await controller.initialize();

      if (existingIndex != -1) {
        controllers[existingIndex] = controller;
      }

      debugPrint("VLC controller initialized for URL: $url");
      return controller;
    } catch (e) {
      debugPrint("Error initializing VLC Controller for URL $url: $e");
      throw Exception("Failed to initialize stream. Please check the URL.");
    }
  }

  /// Delete a Stream
  Future<void> deleteStream(int index) async {
    try {
      final streamId = streams[index].id;

      // Delete from Firestore
      await _firestore.collection('cameraStreams').doc(streamId).delete();

      // Dispose the controller
      controllers[index]?.stop();
      controllers[index]?.dispose();
      controllers.removeAt(index);
      streams.removeAt(index);

      notifyListeners();
      debugPrint("Stream deleted successfully: $streamId");
    } catch (e) {
      debugPrint("Error deleting stream: $e");
      throw Exception("Failed to delete stream. Try again.");
    }
  }

  /// Update Grid Layout
  void updateGridLayout(int count) {
    gridCount = count;
    notifyListeners();
    debugPrint("Grid layout updated to $gridCount x $gridCount");
  }

  /// Dispose All Controllers
  void disposeControllers() {
    for (var controller in controllers) {
      try {
        controller?.stop();
        controller?.dispose();
      } catch (e) {
        debugPrint("Error disposing controller: $e");
      }
    }
    controllers.clear();
    debugPrint("All controllers disposed.");
  }

  /// Refresh a single stream's status (online/offline)
  Future<void> refreshStreamStatus(int index) async {
    try {
      final url = streams[index].url;
      final controller = await initializeController(url);

      // Check if stream is reachable by attempting to play
      await controller.play();
      streams[index] = streams[index].copyWith(isOnline: true);

      debugPrint("Stream refreshed and marked as online: $url");
    } catch (e) {
      streams[index] = streams[index].copyWith(isOnline: false);
      debugPrint("Failed to refresh stream status: $e");
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }
}
