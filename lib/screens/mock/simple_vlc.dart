import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class SimpleVlcPlayer extends StatefulWidget {
  final String url;

  const SimpleVlcPlayer({super.key, required this.url});

  @override
  State<SimpleVlcPlayer> createState() => _SimpleVlcPlayerState();
}

class _SimpleVlcPlayerState extends State<SimpleVlcPlayer> {
  late VlcPlayerController _vlcController;

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      widget.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
void dispose() {
  _vlcController.stop(); // Stop playback to free resources
  _vlcController.dispose(); // Ensure proper cleanup
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VLC Player Test')),
      body: Center(
        child: VlcPlayer(
          controller: _vlcController,
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
