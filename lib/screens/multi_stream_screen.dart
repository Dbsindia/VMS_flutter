import 'package:endroid/screens/add_camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/stream_model.dart';
import '../controllers/vlc_controller_initializer.dart';
import 'full_screen_player.dart';

class MultiStreamScreen extends StatefulWidget {
  const MultiStreamScreen({super.key});

  @override
  _MultiStreamScreenState createState() => _MultiStreamScreenState();
}

class _MultiStreamScreenState extends State<MultiStreamScreen> {
  List<StreamModel> streams = [];
  late List<VlcPlayerController> controllers = [];
  int crossAxisCount = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialStreams();
  }

  Future<void> _loadInitialStreams() async {
    streams = [
      StreamModel(name: 'Camera 1', url: 'rtsp://192.168.1.27:554/stream1'),
      StreamModel(name: 'Camera 2', url: 'rtsp://192.168.1.231/media/video1'),
    ];
    controllers = await VlcControllerInitializer.initialize(
      streams.map((stream) => stream.url).toList(),
    );
    setState(() {});
  }

  void _refreshStreams() async {
    controllers = await VlcControllerInitializer.initialize(
      streams.map((stream) => stream.url).toList(),
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Streams refreshed!")),
    );
  }

  void _changeLayout(int count) {
    setState(() {
      crossAxisCount = count;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Layout changed to $count x $count")),
    );
  }

  void _addStreamDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Stream"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Enter Stream Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: "Enter RTSP URL",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    urlController.text.isNotEmpty) {
                  setState(() {
                    streams.add(StreamModel(
                      name: nameController.text,
                      url: urlController.text,
                    ));
                    controllers.add(
                      VlcPlayerController.network(
                        urlController.text,
                        hwAcc: HwAcc.full,
                        autoPlay: true,
                      ),
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Stream added successfully!")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _openFullScreen(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPlayer(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Devices"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: "Add Camera via QR",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCameraScreen(),
              ),
            ),
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
      body: controllers.isEmpty
          ? const Center(child: Text("No streams available. Add one!"))
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 16 / 9,
              ),
              itemCount: controllers.length,
              itemBuilder: (context, index) => AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onDoubleTap: () => _openFullScreen(context, streams[index].url),
                  child: VlcPlayer(
                    controller: controllers[index],
                    aspectRatio: 16 / 9,
                    placeholder: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
    );
  }
}
