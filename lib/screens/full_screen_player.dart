import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String url;

  const FullScreenPlayer({super.key, required this.url});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  late VlcPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VlcPlayerController.network(
      widget.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: VlcPlayer(
          controller: _controller,
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
