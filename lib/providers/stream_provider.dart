import 'package:flutter/foundation.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/stream_model.dart';
import '../controllers/vlc_controller_initializer.dart';
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

      // Initialize controllers but do not play streams immediately
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
    final controller = await VlcControllerInitializer.initializeSingle(
      url,
      options: {
        'network-caching': '150',
        'file-caching': '150',
        'live-caching': '150',
      },
    );
    return controller;
  }

  /// Delete a stream
  Future<void> deleteStream(int index) async {
    try {
      await _firestore.collection('cameraStreams').doc(streams[index].id).delete();
      controllers[index]?.dispose();
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
