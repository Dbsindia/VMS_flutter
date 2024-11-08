import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class MultiStreamScreen extends StatefulWidget {
  const MultiStreamScreen({super.key});

  @override
  _MultiStreamScreenState createState() => _MultiStreamScreenState();
}

class _MultiStreamScreenState extends State<MultiStreamScreen> {
  final List<String> rtspUrls = [
    'rtsp://192.168.1.27:554/stream1',
    'rtsp://192.168.1.231/media/video1',
    'rtsp://192.168.1.14:554/ch0_1.264',
    'rtsp://192.168.1.233/media/video2',
    'rtsp://192.168.1.232/media/video2',
    'rtsp://192.168.1.232/media/video1',
  ];

  List<VlcPlayerController>? controllers;
  int crossAxisCount = 1; // Default layout
  int? selectedStreamIndex;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    controllers = rtspUrls.map((url) {
      return VlcPlayerController.network(
        url,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            '--network-caching=50',
            '--file-caching=20',
            '--clock-jitter=0',
            '--live-caching=20',
          ]),
        ),
      );
    }).toList();
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in controllers!) {
      controller.stop();
      controller.dispose();
    }
    super.dispose();
  }

  void _changeLayout(int count) {
    setState(() {
      crossAxisCount = count;
      selectedStreamIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Video Streams'),
        backgroundColor: Colors.deepPurple,
        actions: [
          _buildLayoutButton("1x1", 1),
          _buildLayoutButton("2x2", 2),
          _buildLayoutButton("3x3", 3),
        ],
      ),
      body: selectedStreamIndex != null
          ? _buildFullScreenPlayer(selectedStreamIndex!)
          : (controllers == null
              ? const Center(child: CircularProgressIndicator())
              : _buildResponsiveGridLayout()),
    );
  }

  Widget _buildLayoutButton(String label, int count) {
    return TextButton(
      onPressed: () => _changeLayout(count),
      child: Text(
        label,
        style: TextStyle(
          color: crossAxisCount == count && selectedStreamIndex == null
              ? Colors.amber
              : Colors.white,
        ),
      ),
    );
  }

  Widget _buildResponsiveGridLayout() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 16 / 9,
      ),
      itemCount: controllers!.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onDoubleTap: () {
            setState(() {
              selectedStreamIndex = index;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              color: Colors.black,
              child: StreamPlayer(
                controller: controllers![index],
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullScreenPlayer(int index) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: StreamPlayer(
              controller: controllers![index],
              aspectRatio: MediaQuery.of(context).size.aspectRatio,
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () {
                setState(() {
                  selectedStreamIndex = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StreamPlayer extends StatefulWidget {
  final VlcPlayerController controller;
  final double aspectRatio;

  const StreamPlayer({super.key, required this.controller, required this.aspectRatio});

  @override
  _StreamPlayerState createState() => _StreamPlayerState();
}

class _StreamPlayerState extends State<StreamPlayer> {
  bool isPlaying = true;

  @override
  void dispose() {
    widget.controller.stop();
    widget.controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying ? widget.controller.pause() : widget.controller.play();
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VlcPlayer(
          controller: widget.controller,
          aspectRatio: widget.aspectRatio,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: _togglePlayPause,
          ),
        ),
      ],
    );
  }
}
