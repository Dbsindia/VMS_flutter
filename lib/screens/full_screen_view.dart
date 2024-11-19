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
  bool isLoading = true;
  bool hasError = false;
  bool isLive = true;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  Future<void> _initializeStream() async {
    try {
      if (!widget.controller.value.isInitialized) {
        await widget.controller.initialize();
      }
      widget.controller.play();
      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      debugPrint("Error initializing VLC Controller: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.stop();
    widget.controller.removeListener(() {});
    super.dispose();
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            "Failed to load stream.",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isLoading = true;
                hasError = false;
              });
              _initializeStream();
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePlaybackToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() => isLive = true);
            widget.controller.play();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isLive ? Colors.deepPurple : Colors.grey,
          ),
          child: const Text("Live"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            setState(() => isLive = false);
            widget.controller.pause();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: !isLive ? Colors.deepPurple : Colors.grey,
          ),
          child: const Text("Playback"),
        ),
      ],
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                    ? _buildErrorView()
                    : VlcPlayer(
                        controller: widget.controller,
                        aspectRatio: MediaQuery.of(context).size.aspectRatio,
                        placeholder: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
          ),
          const SizedBox(height: 10),
          _buildLivePlaybackToggle(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
