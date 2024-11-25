import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcControllerInitializer {
  /// Initializes a list of VLC Player controllers for the provided URLs
  static Future<List<VlcPlayerController>> initialize(
    List<String> urls, {
    required Map<String, String> options, // VLC advanced options
    bool autoPlay = true, // Optional: AutoPlay flag
    HwAcc hwAcc = HwAcc.full, // Optional: Hardware acceleration
    int retryCount = 3, // Number of retries for initialization
    Duration retryDelay = const Duration(seconds: 2), // Delay between retries
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
          retryDelay: retryDelay,
        );
        controllers.add(controller);
        debugPrint("Controller initialized for URL: $url");
      } catch (e) {
        debugPrint("Failed to initialize controller for URL: $url. Error: $e");
      }
    }

    return controllers;
  }

  /// Initializes a single VLC Player controller for a specific URL
  static Future<VlcPlayerController> initializeSingle(
    String url, {
    required Map<String, String> options, // VLC advanced options
    bool autoPlay = true, // Optional: AutoPlay flag
    HwAcc hwAcc = HwAcc.full, // Optional: Hardware acceleration
    int retryCount = 3, // Number of retries for initialization
    Duration retryDelay = const Duration(seconds: 2), // Delay between retries
  }) async {
    return await _initializeWithRetries(
      url,
      options: options,
      autoPlay: autoPlay,
      hwAcc: hwAcc,
      retryCount: retryCount,
      retryDelay: retryDelay,
    );
  }

  /// Helper method to initialize a VLC Player controller with retries
  static Future<VlcPlayerController> _initializeWithRetries(
    String url, {
    required Map<String, String> options,
    bool autoPlay = true,
    HwAcc hwAcc = HwAcc.full,
    int retryCount = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    if (url.isEmpty ||
        !(url.startsWith('rtsp://') ||
            url.startsWith('http://') ||
            url.startsWith('https://'))) {
      throw Exception("Invalid URL format: $url");
    }

    for (int attempt = 1; attempt <= retryCount; attempt++) {
      try {
        debugPrint(
            "Initializing VLC controller for URL: $url (Attempt $attempt/$retryCount)");
        final controller = VlcPlayerController.network(
          url,
          hwAcc: hwAcc,
          autoPlay: autoPlay,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions([
              '--network-caching=500', // Caching duration
              '--rtsp-tcp', // Use TCP for RTSP
              '--no-stats', // Disable stats
              '--drop-late-frames', // Drop late frames for smoother playback
              '--skip-frames', // Skip frames to maintain sync
            ]),
          ),
        );

        // Debugging for controller state
        controller.addListener(() {
          debugPrint("Controller state: ${controller.value}");
        });

        await controller.initialize();
        debugPrint(
            "Successfully initialized controller for URL: $url on attempt $attempt");
        return controller;
      } catch (e) {
        debugPrint("Attempt $attempt failed for URL: $url. Error: $e");
        if (attempt < retryCount) {
          await Future.delayed(retryDelay * attempt); // Exponential backoff
        }
      }
    }

    throw Exception(
        "Failed to initialize VLC Player controller for URL: $url after $retryCount attempts.");
  }

  /// Disposes all controllers gracefully to free resources
  static void disposeControllers(List<VlcPlayerController> controllers) {
    for (var controller in controllers) {
      try {
        if (controller.value.isInitialized) {
          controller.stop();
          controller.dispose();
          debugPrint("Controller disposed successfully.");
        } else {
          debugPrint("Controller is not initialized. Skipping disposal.");
        }
      } catch (e) {
        debugPrint("Error disposing controller: $e");
      }
    }
  }
}
