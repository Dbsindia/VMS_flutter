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
  bool isControllerInitialized = false; // Track initialization state

  @override
  void initState() {
    super.initState();
    debugPrint("FullScreenView initialized with stream: ${widget.stream.name}");
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      debugPrint("Initializing VLC Player for URL: ${widget.stream.url}");

      _vlcController = VlcPlayerController.network(
        widget.stream.url,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            '--network-caching=500', // Cache for smoother streaming
            '--rtsp-tcp', // Use TCP for RTSP
          ]),
        ),
      );

      // Wait for the controller to fully initialize
      await _vlcController.initialize();

      setState(() {
        isControllerInitialized = true;
      });

      debugPrint("VLC Player initialized successfully.");
    } catch (e) {
      debugPrint("Error initializing VLC Player: $e");
      setState(() {
        isControllerInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    if (_vlcController.value.isPlaying) {
      _vlcController.stop();
    }
    _vlcController.dispose();
    super.dispose();
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
            onPressed: _initializeController,
          ),
        ],
      ),
      body: isControllerInitialized
          ? VlcPlayer(
              controller: _vlcController,
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator()),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
