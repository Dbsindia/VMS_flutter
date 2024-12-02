import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/stream_model.dart';

class FullScreenView extends StatefulWidget {
  final StreamModel stream;

  const FullScreenView({super.key, required this.stream});

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  late VlcPlayerController _vlcController;
  bool isLoading = true;
  bool hasError = false;
  bool isLive = true;

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      widget.stream.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
    _initializeStream();
  }

  Future<void> _initializeStream() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      await _vlcController.initialize();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void _switchToLive() {
    setState(() => isLive = true);
    _vlcController.play();
  }

  void _switchToPlayback() {
    setState(() => isLive = false);
    _vlcController.pause();
  }

  @override
  void dispose() {
    _vlcController.stop();
    _vlcController.dispose();
    super.dispose();
  }

  Widget _buildTopHalf() {
    return Expanded(
      flex: 5,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(
                  child: Text(
                    "Failed to load stream",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : VlcPlayer(
                  controller: _vlcController,
                  aspectRatio: 16 / 9,
                  placeholder: const Center(child: CircularProgressIndicator()),
                ),
    );
  }

  Widget _buildLiveButtons() {
    const buttons = [
      {'icon': Icons.fiber_manual_record, 'label': "Record"},
      {'icon': Icons.mic, 'label': "Talk"},
      {'icon': Icons.settings_remote, 'label': "PTZ"},
      {'icon': Icons.camera_alt, 'label': "Screenshot"},
      {'icon': Icons.high_quality, 'label': "Quality"},
      {'icon': Icons.volume_off, 'label': "Voice Mute"},
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: buttons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final button = buttons[index];
        return ElevatedButton.icon(
          onPressed: () {
            // Add actions for the button
          },
          icon: Icon(button['icon'] as IconData),
          label: Text(button['label'] as String),
        );
      },
    );
  }

  Widget _buildPlaybackButtons() {
    const buttons = [
      {'icon': Icons.calendar_today, 'label': "Date"},
      {'icon': Icons.fiber_manual_record, 'label': "Record"},
      {'icon': Icons.camera_alt, 'label': "Screenshot"},
      {'icon': Icons.volume_off, 'label': "Voice Mute"},
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: buttons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final button = buttons[index];
        return ElevatedButton.icon(
          onPressed: () {
            // Add actions for the button
          },
          icon: Icon(button['icon'] as IconData),
          label: Text(button['label'] as String),
        );
      },
    );
  }

  Widget _buildBottomHalf() {
    return Expanded(
      flex: 5,
      child: Column(
        children: [
          // Switch buttons for Live and Playback
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLive = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLive ? Colors.deepPurple : Colors.grey,
                ),
                child: const Text("Live"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLive = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isLive ? Colors.deepPurple : Colors.grey,
                ),
                child: const Text("Playback"),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stream.name),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeStream,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopHalf(),
          _buildBottomHalf(),
        ],
      ),
    );
  }
}
