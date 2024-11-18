import 'package:flutter/foundation.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/stream_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<StreamModel> streams = [];
  List<VlcPlayerController?> controllers = [];
  bool isLoading = false;
  int gridCount = 1; // Default to 1x1 layout

  /// Load streams from Firestore
  Future<void> loadStreams() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('cameraStreams').get();
      streams = snapshot.docs.map((doc) {
        return StreamModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Clear and initialize controllers for new streams
      _disposeControllers();
      controllers = List<VlcPlayerController?>.filled(
        streams.length,
        null,
        growable: false,
      );

      debugPrint("Streams loaded successfully. Total: ${streams.length}");
    } catch (e) {
      debugPrint("Error loading streams: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Initialize a controller when needed
  Future<VlcPlayerController> initializeController(String url) async {
    try {
      // Check if a controller already exists for this URL
      final existingIndex = streams.indexWhere((stream) => stream.url == url);
      if (existingIndex != -1 && controllers[existingIndex] != null) {
        final existingController = controllers[existingIndex];
        if (existingController != null &&
            existingController.value.isInitialized) {
          return existingController;
        }
      }

      // Create a new controller
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

      return controller;
    } catch (e) {
      debugPrint("Error initializing VLC Controller: $e");
      throw Exception("Failed to initialize stream. Please check the URL.");
    }
  }

  /// Delete a stream
  Future<void> deleteStream(int index) async {
    try {
      final streamId = streams[index].id;

      // Delete from Firestore
      await _firestore.collection('cameraStreams').doc(streamId).delete();

      // Dispose of the controller and update lists
      controllers[index]?.dispose();
      controllers.removeAt(index);
      streams.removeAt(index);

      notifyListeners();
      debugPrint("Stream deleted successfully. ID: $streamId");
    } catch (e) {
      debugPrint("Error deleting stream: $e");
      throw Exception("Failed to delete the stream. Please try again.");
    }
  }

  /// Update grid layout
  void updateGridLayout(int count) {
    gridCount = count;
    notifyListeners();
  }

  /// Dispose all VLC controllers
  void _disposeControllers() {
    for (var controller in controllers) {
      if (controller != null && controller.value.isInitialized) {
        try {
          controller.stop();
          controller.dispose();
        } catch (e) {
          debugPrint("Error disposing controller: $e");
        }
      }
    }
    controllers.clear();
    debugPrint("All controllers disposed.");
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
}
