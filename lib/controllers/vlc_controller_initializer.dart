import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcControllerInitializer {
  /// Initializes a list of VLC Player controllers for the provided URLs
  static Future<List<VlcPlayerController>> initialize(
    List<String> urls, {
    required Map<String, String> options, // VLC advanced options
    bool autoPlay = true,                // Optional: AutoPlay flag
    HwAcc hwAcc = HwAcc.full,            // Optional: Hardware acceleration
    int retryCount = 3,                  // Number of retries for initialization
  }) async {
    List<VlcPlayerController> controllers = [];

    for (var url in urls) {
      try {
        final controller = await _initializeWithRetries(
          url,
          options: options,
          autoPlay: autoPlay,
          hwAcc: hwAcc,
          retryCount: retryCount,
        );
        controllers.add(controller);
        print("Controller initialized for URL: $url");
      } catch (e) {
        print("Failed to initialize controller for URL: $url. Error: $e");
      }
    }

    return controllers;
  }

  /// Initializes a single VLC Player controller for a specific URL
  static Future<VlcPlayerController> initializeSingle(
    String url, {
    required Map<String, String> options, // VLC advanced options
    bool autoPlay = true,                // Optional: AutoPlay flag
    HwAcc hwAcc = HwAcc.full,            // Optional: Hardware acceleration
    int retryCount = 3,                  // Number of retries for initialization
  }) async {
    return await _initializeWithRetries(
      url,
      options: options,
      autoPlay: autoPlay,
      hwAcc: hwAcc,
      retryCount: retryCount,
    );
  }

  /// Helper method to initialize a VLC Player controller with retries
  static Future<VlcPlayerController> _initializeWithRetries(
    String url, {
    required Map<String, String> options,
    bool autoPlay = true,
    HwAcc hwAcc = HwAcc.full,
    int retryCount = 3,
  }) async {
    VlcPlayerController? controller;
    for (int attempt = 0; attempt < retryCount; attempt++) {
      try {
        controller = VlcPlayerController.network(
          url,
          hwAcc: hwAcc,
          autoPlay: autoPlay,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions(
              options.entries.map((entry) => '--${entry.key}=${entry.value}').toList(),
            ),
          ),
        );
        await controller.initialize();
        print("Successfully initialized controller for URL: $url on attempt $attempt");
        return controller;
      } catch (e) {
        print("Attempt $attempt failed for URL: $url. Error: $e");
      }
    }

    throw Exception("Failed to initialize VLC Player controller for URL: $url after $retryCount attempts.");
  }

  /// Disposes all controllers gracefully to free resources
  static void disposeControllers(List<VlcPlayerController> controllers) {
    for (var controller in controllers) {
      if (controller.value.isInitialized) {
        try {
          controller.stop(); // Stop any ongoing playback
          controller.dispose();
          print("Controller disposed successfully.");
        } catch (e) {
          print("Error disposing controller: $e");
        }
      } else {
        print("Controller is not initialized. Skipping disposal.");
      }
    }
  }
}
