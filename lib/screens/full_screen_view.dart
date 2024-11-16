import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/stream_model.dart';

class FullScreenView extends StatefulWidget {
  final StreamModel stream;
  final VlcPlayerController controller;

  const FullScreenView({
    super.key,
    required this.stream,
    required this.controller,
  });

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

  void handleIconAction(int index) {
    if (isLive) {
      switch (index) {
        case 0:
          // Start/Stop video recording
          showFeedback("Recording started");
          break;
        case 1:
          // Enable/Disable mic
          showFeedback("Mic enabled");
          break;
        case 2:
          // Take a snapshot
          showFeedback("Snapshot taken");
          break;
        case 3:
          // Change resolution
          showFeedback("Resolution changed to HD");
          break;
        case 4:
          // Adjust volume
          showFeedback("Volume adjusted");
          break;
        default:
          break;
      }
    } else {
      switch (index) {
        case 0:
          // Show calendar for selecting date
          showFeedback("Calendar opened");
          break;
        case 1:
          // Open video library
          showFeedback("Video library opened");
          break;
        case 2:
          // Download playback
          showFeedback("Download started");
          break;
        default:
          break;
      }
    }
  }

  void showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveIcons = [
      Icons.videocam,
      Icons.mic,
      Icons.photo_camera,
      Icons.hd,
      Icons.volume_up,
    ];
    final playbackIcons = [
      Icons.calendar_today,
      Icons.video_library,
      Icons.download,
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.stream.name),
      ),
      body: Column(
        children: [
          // VLC Player for streaming video
          Expanded(
            child: widget.controller.value.isInitialized
                ? VlcPlayer(
                    controller: widget.controller,
                    aspectRatio: MediaQuery.of(context).size.aspectRatio,
                    placeholder:
                        const Center(child: CircularProgressIndicator()),
                  )
                : const Center(
                    child: Text(
                      "Stream failed to load.",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
          ),

          // Live/Playback toggle buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => isLive = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLive ? Colors.deepPurple : Colors.grey,
                ),
                child: const Text("Live"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => setState(() => isLive = false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isLive ? Colors.deepPurple : Colors.grey,
                ),
                child: const Text("Playback"),
              ),
            ],
          ),
          // Action icons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: isLive ? liveIcons.length : playbackIcons.length,
              itemBuilder: (context, index) {
                final icons = isLive ? liveIcons : playbackIcons;
                return IconButton(
                  icon: Icon(icons[index], color: Colors.deepPurple),
                  onPressed: () => handleIconAction(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
