import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcControllerInitializer {
  static Future<List<VlcPlayerController>> initialize(
    List<String> urls, {
    required Map<String, String> options,
  }) async {
    return urls.map((url) {
      return VlcPlayerController.network(
        url,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions(
            options.entries.map((entry) => '--${entry.key}=${entry.value}').toList(),
          ),
        ),
      );
    }).toList();
  }
}
