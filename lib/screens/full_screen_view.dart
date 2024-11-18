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
  late VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _controllerListener = _onControllerUpdate;
    widget.controller.addListener(_controllerListener);
    _initializeStream();
  }

  /// Listener to monitor the VLC Player Controller state
  void _onControllerUpdate() {
    if (widget.controller.value.hasError) {
      debugPrint("VLC Error: ${widget.controller.value.errorDescription}");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    } else if (widget.controller.value.isInitialized && isLoading) {
      setState(() {
        isLoading = false;
        hasError = false;
      });
    }
  }

  /// Initialize the VLC Player Controller
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
    widget.controller.removeListener(_controllerListener);
    widget.controller.stop();
    // Do not dispose the controller here as it is reused by the provider
    super.dispose();
  }

  /// Error view to display if the VLC Player fails to load
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stream.name),
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
          _buildLivePlaybackToggle(),
        ],
      ),
    );
  }
}
