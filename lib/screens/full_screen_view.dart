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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStream(); // Initialize stream after widget is built
    });
    widget.controller.addListener(_controllerListener);
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
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      debugPrint("Initializing VLC Player...");
      if (!widget.controller.value.isInitialized) {
        await widget.controller.initialize();
      }
      widget.controller.play();
      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      debugPrint("Error initializing VLC Player: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  /// Refresh and retry initialization
  Future<void> _retryStream() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
      });
    }
    await _initializeStream();
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
    widget.controller.dispose(); // Dispose to free resources
    super.dispose();
  }

  /// Builds the error view when a stream fails to load
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          const Text("Failed to load stream."),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retryStream,
            child: const Text("Retry"),
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

  /// Builds the stream status header
  Widget _buildStreamStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: widget.stream.isOnline ? Colors.green : Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.stream.isOnline ? "Live" : "Offline",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
            onPressed: _retryStream,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStreamStatusHeader(),
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
