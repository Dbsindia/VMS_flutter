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
        !(url.startsWith('rtsp://') || url.startsWith('http://'))) {
      throw Exception("Invalid URL format: $url");
    }

    Exception? lastError;

    for (int attempt = 1; attempt <= retryCount; attempt++) {
      try {
        debugPrint("Initializing VLC for $url (Attempt $attempt)");
        final controller = VlcPlayerController.network(
          url,
          hwAcc: hwAcc,
          autoPlay: autoPlay,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions([
              '--network-caching=500',
              '--rtsp-tcp',
              '--no-stats',
            ]),
          ),
        );

        await controller.initialize();
        debugPrint("VLC Controller initialized for $url");
        return controller;
      } catch (e) {
        lastError = e as Exception?;
        debugPrint("Initialization failed for $url: $e");
        if (attempt < retryCount) {
          await Future.delayed(retryDelay);
        }
      }
    }

    throw Exception(
        "Failed to initialize VLC Player for $url after $retryCount attempts. Last error: $lastError");
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
