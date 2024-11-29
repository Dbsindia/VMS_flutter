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
    debugPrint("Initializing VLC controller for stream: ${widget.stream.url}");
    widget.controller.addListener(_controllerListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeStream());
  }

  /// Listener for VLC controller state changes
  void _controllerListener() {
    final controllerState = widget.controller.value;
    debugPrint("VLC Controller State: $controllerState");

    if (controllerState.hasError) {
      debugPrint("VLC Error: ${controllerState.errorDescription}");
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } else if (controllerState.isInitialized && isLoading) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = false;
        });
      }
    }
  }

  /// Initializes the VLC Player Controller
  Future<void> _initializeStream() async {
    if (!widget.stream.isValidUrl) {
      debugPrint("Invalid RTSP URL: ${widget.stream.url}");
      _showSnackBar("Invalid RTSP URL provided.");
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      if (!widget.controller.value.isInitialized) {
        debugPrint("Initializing VLC Player...");
        await widget.controller.initialize();
      }

      widget.controller.play();
      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      debugPrint("Error initializing VLC Controller: $e");
      _showSnackBar("Failed to initialize stream. Please try again.");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  /// Shows a snackbar with a custom message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint("Disposing FullScreenView...");
    widget.controller.removeListener(_controllerListener);
    widget.controller.stop();
    super.dispose();
  }

  /// Builds the error view when a stream fails to load
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
              if (mounted) {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
                _initializeStream();
              }
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "Retry",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the live/playback toggle buttons
  Widget _buildLivePlaybackToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (mounted) {
                    setState(() => isLive = true);
                    widget.controller.play();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isLive ? Colors.deepPurple : Colors.grey,
          ),
          child: const Text("Live"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (mounted) {
                    setState(() => isLive = false);
                    widget.controller.pause();
                  }
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
