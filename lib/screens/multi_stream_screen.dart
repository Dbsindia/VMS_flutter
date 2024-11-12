import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stream_model.dart';
import '../controllers/vlc_controller_initializer.dart';
import 'add_camera_screen.dart';
import 'full_screen_player.dart';

class MultiStreamScreen extends StatefulWidget {
  const MultiStreamScreen({super.key});

  @override
  State<MultiStreamScreen> createState() => _MultiStreamScreenState();
}

class _MultiStreamScreenState extends State<MultiStreamScreen> {
  List<StreamModel> streams = [];
  late List<VlcPlayerController> controllers = [];
  int crossAxisCount = 2; // Default grid layout
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadStoredStreams();
    _scrollController.addListener(_manageVisibility);
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  /// Load streams from SharedPreferences
  Future<void> _loadStoredStreams() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final savedStreams = prefs.getStringList('savedCameras') ?? [];

    streams = savedStreams.map((camera) {
      final parts = camera.split('|');
      return StreamModel(name: parts[0], url: parts[1]);
    }).toList();

    controllers = await VlcControllerInitializer.initialize(
      streams.map((stream) => stream.url).toList(),
      options: {
        'network-caching': '200',
        'file-caching': '200',
        'live-caching': '200',
      },
    );

    setState(() {
      isLoading = false;
    });
  }

  /// Save streams to SharedPreferences
  Future<void> _saveStreams() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedStreams = json.encode(streams.map((stream) => stream.toJson()).toList());
    await prefs.setString('savedCameras', encodedStreams);
  }

  /// Manage visibility of streams during scrolling
  void _manageVisibility() {
    for (int i = 0; i < controllers.length; i++) {
      final double position = _getWidgetPosition(i);
      if (position > 0 && position < MediaQuery.of(context).size.height) {
        controllers[i].play();
      } else {
        controllers[i].pause();
      }
    }
  }

  /// Get position of a stream widget
  double _getWidgetPosition(int index) {
    try {
      final RenderBox? box = _scrollController.position.context.storageContext
          .findRenderObject() as RenderBox?;
      if (box == null) return -1;
      final Offset position = box.localToGlobal(Offset.zero);
      return position.dy;
    } catch (e) {
      return -1;
    }
  }

  /// Open Full-Screen Player
  void _openFullScreen(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPlayer(url: url),
      ),
    );
  }

  /// Open Add Camera Screen
  void _openAddCameraScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCameraScreen(),
      ),
    ).then((_) => _loadStoredStreams()); // Reload streams when returning
  }

  /// Refresh Streams
  void _refreshStreams() async {
    for (var controller in controllers) {
      controller.dispose();
    }

    controllers = await VlcControllerInitializer.initialize(
      streams.map((stream) => stream.url).toList(),
      options: {
        'network-caching': '200',
        'file-caching': '200',
        'live-caching': '200',
      },
    );

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Streams refreshed!")),
    );
  }

  /// Change Layout of the Grid
  void _changeLayout(int count) {
    setState(() {
      crossAxisCount = count;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Layout changed to $count x $count")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Streams"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Camera",
            onPressed: _openAddCameraScreen,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Streams",
            onPressed: _refreshStreams,
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.grid_view),
            tooltip: "Change Layout",
            onSelected: _changeLayout,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("1x1 Layout")),
              const PopupMenuItem(value: 2, child: Text("2x2 Layout")),
              const PopupMenuItem(value: 3, child: Text("3x3 Layout")),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : controllers.isEmpty
              ? const Center(child: Text("No streams available. Add one!"))
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: controllers.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 6.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Stack(
                        children: [
                          // Stream Player
                          Positioned.fill(
                            child: GestureDetector(
                              onDoubleTap: () =>
                                  _openFullScreen(context, streams[index].url),
                              child: VlcPlayer(
                                controller: controllers[index],
                                aspectRatio: 16 / 9,
                                placeholder: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                          // Top Overlay
                          Positioned(
                            top: 8.0,
                            left: 8.0,
                            right: 8.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  streams[index].name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings, color: Colors.white),
                                  onPressed: () {
                                    // Handle settings here
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Play/Pause Button
                          Center(
                            child: IconButton(
                              icon: Icon(
                                controllers[index].value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                              onPressed: () {
                                if (controllers[index].value.isPlaying) {
                                  controllers[index].pause();
                                } else {
                                  controllers[index].play();
                                }
                              },
                            ),
                          ),
                          // Bottom Overlay
                          Positioned(
                            bottom: 8.0,
                            left: 8.0,
                            right: 8.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.message, color: Colors.deepPurple),
                                  onPressed: () {
                                    // Handle message action
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info, color: Colors.deepPurple),
                                  onPressed: () {
                                    // Handle info action
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () async {
                                    setState(() {
                                      controllers[index].dispose();
                                      controllers.removeAt(index);
                                      streams.removeAt(index);
                                    });
                                    await _saveStreams();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
