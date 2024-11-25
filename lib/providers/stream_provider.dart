import 'package:endroid/controllers/vlc_controller_initializer.dart';
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
      ).toList(); // Convert to a growable list

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
  if (url.isEmpty || !(url.startsWith('rtsp://') || url.startsWith('http://') || url.startsWith('https://'))) {
    throw Exception("Invalid URL format: $url");
  }

  debugPrint("Initializing VLC controller for URL: $url");

  final existingIndex = streams.indexWhere((stream) => stream.url == url);

  // Reuse existing controller if it's already initialized
  if (existingIndex != -1 && controllers[existingIndex] != null) {
    final existingController = controllers[existingIndex];
    if (existingController != null && existingController.value.isInitialized) {
      debugPrint("Reusing existing controller for URL: $url");
      return existingController;
    }
  }

  // Initialize a new controller
  try {
    final controller = await VlcControllerInitializer.initializeSingle(
      url,
      options: {
        'network-caching': '500',
        'rtsp-tcp': '',
      },
    );

    controller.addListener(() {
      debugPrint("VLC Controller State for $url: ${controller.value}");
    });

    if (existingIndex != -1) {
      controllers[existingIndex] = controller;
    }

    return controller;
  } catch (e) {
    debugPrint("Error initializing VLC Controller for URL $url: $e");
    throw Exception("Failed to initialize stream. Please check the URL.");
  }
}


  /// Delete a Stream
  Future<void> deleteStream(int index) async {
    if (index < 0 || index >= streams.length) {
      throw Exception("Invalid stream index. Unable to delete.");
    }

    try {
      final streamId = streams[index].id;

      final documentSnapshot =
          await _firestore.collection('cameraStreams').doc(streamId).get();

      if (!documentSnapshot.exists) {
        throw Exception("Stream does not exist in Firestore.");
      }

      await _firestore.collection('cameraStreams').doc(streamId).delete();

      if (controllers[index] != null) {
        await controllers[index]?.stop();
        controllers[index]?.dispose();
      }

      streams = List<StreamModel>.from(streams)..removeAt(index);
      controllers = List<VlcPlayerController?>.from(controllers)
        ..removeAt(index);

      notifyListeners();
    } catch (e) {
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

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }
}
