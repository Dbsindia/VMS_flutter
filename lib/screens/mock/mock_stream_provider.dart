import 'package:endroid/models/stream_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class MockStreamProvider with ChangeNotifier {
  List<StreamModel> streams = [];
  List<VlcPlayerController?> controllers = [];
  bool isLoading = false;
  int gridCount = 1; // Default layout: 1x1

  MockStreamProvider() {
    _loadMockData();
  }

  /// Load mock streams
  void _loadMockData() {
    streams = [
      StreamModel(
        id: '1',
        name: 'Test Stream 1',
        url: 'rtsp://test.stream/1',
        snapshotUrl: 'rtsp://192.168.1.18/live/0/MAIN',
        isOnline: true,
        createdAt: DateTime.now(),
      ),
      StreamModel(
        id: '2',
        name: 'Test Stream 2',
        url: 'rtsp://test.stream/2',
        snapshotUrl: 'https://via.placeholder.com/150',
        isOnline: false,
        createdAt: DateTime.now(),
      ),
    ];
    controllers = List<VlcPlayerController?>.filled(
      streams.length,
      null,
    );
    notifyListeners();
  }

  /// Initialize VLC Controller
  Future<VlcPlayerController> initializeController(String url) async {
    final controller = VlcPlayerController.network(
      url,
      hwAcc: HwAcc.full,
      autoPlay: true,
    );
    await controller.initialize();
    return controller;
  }

  /// Mock delete a stream
  Future<void> deleteStream(int index) async {
    if (index < 0 || index >= streams.length) return;
    streams.removeAt(index);
    controllers.removeAt(index);
    notifyListeners();
  }

  /// Update Grid Layout
  void updateGridLayout(int count) {
    gridCount = count;
    notifyListeners();
  }

  /// Dispose all controllers
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
