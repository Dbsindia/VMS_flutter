import 'package:endroid/models/stream_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class SimpleVlcPlayer extends StatefulWidget {
  final String url;
  final StreamModel stream;

  const SimpleVlcPlayer({super.key, required this.url, required this.stream});

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
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          '--network-caching=500', // Reduce latency for live streams
          '--rtsp-tcp', // Ensure RTSP over TCP
        ]),
      ),
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
      appBar: AppBar(
        title: Text(widget.stream.name), // Show the stream name
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Top Half: VLC Player
          Expanded(
            flex: 1,
            child: VlcPlayer(
              controller: _vlcController,
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          // Bottom Half: Action Buttons
          Expanded(
            flex: 1,
            child: GridView.count(
              crossAxisCount: 3,
              children: const [
                ActionButton(icon: Icons.videocam, label: 'Record'),
                ActionButton(icon: Icons.mic, label: 'Talk'),
                ActionButton(icon: Icons.photo_camera, label: 'Screenshot'),
                ActionButton(icon: Icons.settings, label: 'PTZ'),
                ActionButton(icon: Icons.hd, label: 'Quality'),
                ActionButton(icon: Icons.volume_off, label: 'Mute'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.deepPurple),
          onPressed: () {
            // Handle button press
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Clicked $label')),
            );
          },
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
