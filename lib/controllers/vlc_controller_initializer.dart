import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcControllerInitializer {
  /// Initializes a list of VLC Player controllers for the provided URLs
  static Future<List<VlcPlayerController>> initialize(
    List<String> urls, {
    required Map<String, String> options, // VLC advanced options
    bool autoPlay = true,                // Optional: AutoPlay flag
    HwAcc hwAcc = HwAcc.full,            // Optional: Hardware acceleration
  }) async {
    return urls.map((url) {
      return VlcPlayerController.network(
        url,
        hwAcc: hwAcc,                     // Hardware acceleration
        autoPlay: autoPlay,               // Play stream immediately
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions(
            options.entries
                .map((entry) => '--${entry.key}=${entry.value}')
                .toList(), // Convert Map to VlcAdvancedOptions
          ),
        ),
      );
    }).toList();
  }

  /// Disposes all controllers gracefully to free resources
  static void disposeControllers(List<VlcPlayerController> controllers) {
    for (var controller in controllers) {
      if (controller.value.isInitialized) { // Check if the controller is initialized
        try {
          controller.dispose(); // Dispose safely
        } catch (e) {
          // Handle errors during disposal if necessary
          print("Error disposing controller: $e");
        }
      }
    }
  }
}
