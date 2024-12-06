import 'package:endroid/models/stream_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:path_provider/path_provider.dart';

class SimpleVlcPlayer extends StatefulWidget {
  final String url;
  final StreamModel stream;

  const SimpleVlcPlayer({super.key, required this.url, required this.stream});

  @override
  State<SimpleVlcPlayer> createState() => _SimpleVlcPlayerState();
}

class _SimpleVlcPlayerState extends State<SimpleVlcPlayer> {
  late VlcPlayerController _vlcController;
  bool isLive = true;
  double playbackProgress = 0.0;
  bool isMuted = true;
  bool isRecording = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
  try {
    _vlcController = VlcPlayerController.network(
      widget.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          '--network-caching=1000', // Optimize caching for low latency
          '--rtsp-tcp', // Use RTSP over TCP for better stability
          '--no-audio', // Disable audio by default
        ]),
        video: VlcVideoOptions([
          '--video-filter=deinterlace',
          '--deinterlace-mode=blend',
        ]),
      ),
    );
        _vlcController.addListener(_handlePlaybackError); // Attach error handler

    setState(() => _isInitialized = true);
  } catch (e) {
    debugPrint("Error initializing VLC Player: $e");
  }
}

void _handlePlaybackError() {
  if (_vlcController.value.hasError) {
    debugPrint("VLC Player encountered an error: ${_vlcController.value.errorDescription}");
    _vlcController.stop();
    _vlcController.play(); // Attempt to restart playback
  }
}


@override
void dispose() {
  _vlcController.stop(); // Stop playback
  _vlcController.dispose(); // Cleanup resources
  super.dispose();
}



  void _toggleAudio() async {
    if (!_isInitialized) return;

    setState(() {
      isMuted = !isMuted;
    });

    try {
      if (isMuted) {
        await _vlcController.setAudioTrack(-1); // Mute
      } else {
        await _vlcController.setAudioTrack(1); // Unmute
      }
    } catch (e) {
      debugPrint("Error toggling audio: $e");
    }
  }

  Future<void> _takeScreenshot() async {
    try {
      final savedPath = await _vlcController.takeSnapshot();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot saved: $savedPath')),
        );
      }
    } catch (e) {
      debugPrint("Error taking screenshot: $e");
    }
  }

  void _toggleRecording() async {
    if (!_isInitialized) return;

    try {
      if (isRecording) {
        await _vlcController.stopRecording();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recording stopped')),
          );
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final recordingPath =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp4';
        await _vlcController.startRecording(recordingPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recording started: $recordingPath')),
          );
        }
      }

      setState(() {
        isRecording = !isRecording;
      });
    } catch (e) {
      debugPrint("Error toggling recording: $e");
    }
  }

  Widget _buildToggleSwitch() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final switchWidth =
            constraints.maxWidth * 0.8; // 80% of available width

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: SizedBox(
            width: switchWidth,
            child: AnimatedToggleSwitch<bool>.dual(
              current: isLive,
              first: true,
              second: false,
              height: 40.0,
              borderWidth: 2.0,
              indicatorSize: const Size(40, 40),
              iconBuilder: (value) => value
                  ? const Icon(Icons.live_tv, color: Colors.white)
                  : const Icon(Icons.play_arrow, color: Colors.white),
              textBuilder: (value) => value
                  ? const Center(
                      child: Text(
                        'Live',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Playback',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
              onChanged: (value) {
                setState(() => isLive = value);
              },
              styleBuilder: (value) => ToggleStyle(
                backgroundColor: value ? Colors.green : Colors.orange,
                indicatorColor: value ? Colors.green : Colors.orange,
                borderColor: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    final liveButtons = [
      ActionButton(
          icon: Icons.videocam,
          label: isRecording ? 'Stop' : 'Record',
          onPressed: _toggleRecording),
      const ActionButton(icon: Icons.mic, label: 'Talk'),
      ActionButton(
          icon: Icons.photo_camera,
          label: 'Screenshot',
          onPressed: _takeScreenshot),
      const ActionButton(icon: Icons.settings, label: 'PTZ'),
      const ActionButton(icon: Icons.hd, label: 'Quality'),
      ActionButton(
        icon: isMuted ? Icons.volume_off : Icons.volume_up,
        label: isMuted ? 'Unmute' : 'Mute',
        onPressed: _toggleAudio,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: liveButtons,
    );
  }

  Widget _buildStreamPlayer() {
    return Stack(
      children: [
        VlcPlayer(
          controller: _vlcController,
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {
              // Full-screen logic
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stream.name),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.5,
            child: _buildStreamPlayer(),
          ),
          Expanded(
            child: Column(
              children: [
                _buildToggleSwitch(),
                Expanded(child: _buildActionButtons()),
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
  final VoidCallback? onPressed;

  const ActionButton(
      {super.key, required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.deepPurple),
          onPressed: onPressed ??
              () {
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
