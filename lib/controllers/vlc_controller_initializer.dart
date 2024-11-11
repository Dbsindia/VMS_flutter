import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcControllerInitializer {
  static Future<List<VlcPlayerController>> initialize(List<String> urls) async {
    return urls.map((url) {
      return VlcPlayerController.network(
        url,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            '--network-caching=200',
            '--file-caching=200',
            '--live-caching=200',
            '--rtsp-timeout=10',
          ]),
        ),
      );
    }).toList();
  }
}
