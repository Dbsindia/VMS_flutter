import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/stream_model.dart';

class FullScreenView extends StatefulWidget {
  final StreamModel stream;
  final VlcPlayerController controller;

  const FullScreenView(
      {super.key, required this.stream, required this.controller});

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  bool isLive = true;

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.stream.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: VlcPlayer(
              controller: widget.controller,
              aspectRatio: MediaQuery.of(context).size.aspectRatio,
              placeholder: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => setState(() => isLive = true),
                child: const Text("Live"),
              ),
              TextButton(
                onPressed: () => setState(() => isLive = false),
                child: const Text("Playback"),
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: isLive ? 6 : 5, // Live or Playback buttons
              itemBuilder: (context, index) {
                final icons = isLive
                    ? [
                        Icons.videocam,
                        Icons.mic,
                        Icons.photo_camera,
                        Icons.hd,
                        Icons.volume_up
                      ]
                    : [
                        Icons.calendar_today,
                        Icons.video_library,
                        Icons.download
                      ];
                return IconButton(
                  icon: Icon(icons[index]),
                  onPressed: () {
                    // Add respective functionality here
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
