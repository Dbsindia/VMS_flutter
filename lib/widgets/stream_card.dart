import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'bottom_button.dart';

class StreamCard extends StatelessWidget {
  final VlcPlayerController controller;
  final String streamName;

  const StreamCard({
    super.key,
    required this.controller,
    required this.streamName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 6.0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  streamName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.settings, color: Colors.grey),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12.0)),
              child: VlcPlayer(
                controller: controller,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomButton(icon: Icons.message, label: "Message", onPressed: () {}),
                BottomButton(icon: Icons.play_arrow, label: "Playback", onPressed: () {}),
                BottomButton(icon: Icons.more_horiz, label: "More", onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
