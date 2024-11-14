import 'package:flutter/foundation.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/stream_model.dart';
import '../controllers/vlc_controller_initializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<StreamModel> streams = [];
  List<VlcPlayerController> controllers = [];
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

      await _initializeControllers();
    } catch (e) {
      debugPrint("Error loading streams: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Initialize VLC controllers
  Future<void> _initializeControllers() async {
    // Dispose old controllers
    for (var controller in controllers) {
      controller.dispose();
    }
    controllers.clear();

    // Initialize new controllers
    controllers = await VlcControllerInitializer.initialize(
      streams.map((stream) => stream.url).toList(),
      options: {
        'network-caching': '200',
        'file-caching': '200',
        'live-caching': '200',
      },
    );
    notifyListeners();
  }

  /// Refresh streams
  Future<void> refreshStreams() async {
    await loadStreams();
  }

  /// Delete a stream
  Future<void> deleteStream(int index) async {
    try {
      await _firestore.collection('cameraStreams').doc(streams[index].id).delete();
      controllers[index].dispose();
      controllers.removeAt(index);
      streams.removeAt(index);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting stream: $e");
    }
  }

  /// Update grid layout
  void updateGridLayout(int count) {
    gridCount = count;
    notifyListeners();
  }
}
