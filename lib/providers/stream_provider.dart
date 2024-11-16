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

      controllers = List<VlcPlayerController?>.filled(
        streams.length,
        null,
        growable: false,
      );
    } catch (e) {
      debugPrint("Error loading streams: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Initialize a controller when needed
  Future<VlcPlayerController> initializeController(String url) async {
    try {
      final controller = VlcPlayerController.network(
        url,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            '--network-caching=150',
            '--file-caching=150',
            '--live-caching=150',
          ]),
        ),
      );
      return controller;
    } catch (e) {
      debugPrint("Error initializing VLC Controller: $e");
      throw Exception("Failed to initialize the stream. Check the URL.");
    }
  }

  /// Delete a stream
  Future<void> deleteStream(int index) async {
    try {
      final streamId = streams[index].id;
      await _firestore.collection('cameraStreams').doc(streamId).delete();
      controllers[index]?.dispose();
      controllers.removeAt(index);
      streams.removeAt(index);
      notifyListeners(); // Notify listeners to refresh the UI
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
  void disposeControllers() {
    for (var controller in controllers) {
      controller?.dispose();
    }
    controllers.clear();
  }
}
