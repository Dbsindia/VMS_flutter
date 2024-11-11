// import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MultiStreamScreen extends StatefulWidget {
//   const MultiStreamScreen({super.key});

//   @override
//   _MultiStreamScreenState createState() => _MultiStreamScreenState();
// }

// class _MultiStreamScreenState extends State<MultiStreamScreen> {
//   List<String> rtspUrls = [
//     'rtsp://192.168.1.27:554/stream1',
//     'rtsp://192.168.1.231/media/video1',
//     'rtsp://192.168.1.14:554/ch0_1.264',
//     'rtsp://192.168.1.233/media/video2',
//     'rtsp://192.168.1.232/media/video2',
//     'rtsp://192.168.1.232/media/video1',
//   ];

//   late List<VlcPlayerController> controllers = [];
//   int crossAxisCount = 1;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//   }

//   Future<void> _initializeControllers() async {
//     for (var controller in controllers) {
//       await controller.stop();
//       controller.dispose();
//     }

//     controllers = rtspUrls.map((url) {
//       return VlcPlayerController.network(
//         url,
//         hwAcc: HwAcc.full,
//         autoPlay: true,
//         options: VlcPlayerOptions(
//           advanced: VlcAdvancedOptions([
//             '--network-caching=200',
//             '--file-caching=200',
//             '--live-caching=200',
//             '--rtsp-timeout=10',
//           ]),
//         ),
//       );
//     }).toList();

//     setState(() {});
//   }

//   @override
//   void dispose() {
//     for (var controller in controllers) {
//       controller.stop();
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   void _addStreamDialog() {
//     TextEditingController urlController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Add Stream URL"),
//           content: TextField(
//             controller: urlController,
//             decoration: const InputDecoration(
//               hintText: "Enter RTSP URL",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (urlController.text.isNotEmpty) {
//                   setState(() {
//                     rtspUrls.add(urlController.text);
//                     controllers.add(
//                       VlcPlayerController.network(
//                         urlController.text,
//                         hwAcc: HwAcc.full,
//                         autoPlay: true,
//                       ),
//                     );
//                   });
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Stream added successfully!")),
//                   );
//                 }
//               },
//               child: const Text("Add"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _changeLayout(int count) {
//     setState(() {
//       crossAxisCount = count;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Layout changed to $count x $count")),
//     );
//   }

//   void _refreshStreams() async {
//     await _initializeControllers();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Streams refreshed!")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final childAspectRatio = screenWidth / (screenWidth / 1.5);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Devices"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             tooltip: "Refresh Streams",
//             onPressed: _refreshStreams,
//           ),
//           PopupMenuButton<int>(
//             icon: const Icon(Icons.grid_view),
//             tooltip: "Change Layout",
//             onSelected: _changeLayout,
//             itemBuilder: (context) => [
//               const PopupMenuItem(value: 1, child: Text("1x1 Layout")),
//               const PopupMenuItem(value: 2, child: Text("2x2 Layout")),
//               const PopupMenuItem(value: 3, child: Text("3x3 Layout")),
//             ],
//           ),
//           IconButton(
//             icon: const Icon(Icons.add),
//             tooltip: "Add Stream",
//             onPressed: _addStreamDialog,
//           ),
//         ],
//       ),
//       body: controllers.isEmpty
//           ? const Center(child: Text("No streams available. Add one!"))
//           : GridView.builder(
//         padding: const EdgeInsets.all(8.0),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: crossAxisCount,
//           mainAxisSpacing: 8.0,
//           crossAxisSpacing: 8.0,
//           childAspectRatio: childAspectRatio,
//         ),
//         itemCount: controllers.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onDoubleTap: () => _openFullScreen(context, rtspUrls[index]),
//             child: _buildStreamContainer(
//               context,
//               controllers[index],
//               'Stream ${index + 1}',
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStreamContainer(
//       BuildContext context, VlcPlayerController controller, String streamName) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//       elevation: 6.0,
//       child: Column(
//         children: [
//           // Title Section
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   streamName,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const Icon(Icons.settings, color: Colors.grey),
//               ],
//             ),
//           ),

//           // Stream Player Section
//           Expanded(
//             child: ClipRRect(
//               borderRadius:
//               const BorderRadius.vertical(bottom: Radius.circular(12.0)),
//               child: VlcPlayer(
//                 controller: controller,
//                 aspectRatio: 16 / 9,
//                 placeholder: const Center(child: CircularProgressIndicator()),
//               ),
//             ),
//           ),

//           // Bottom Buttons Section
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildBottomButton(Icons.message, "Message", () {
//                   // Message button functionality
//                 }),
//                 _buildBottomButton(Icons.play_arrow, "Playback", () {
//                   // Playback button functionality
//                 }),
//                 _buildBottomButton(Icons.more_horiz, "More", () {
//                   // More button functionality
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomButton(IconData icon, String label, VoidCallback onPressed) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           icon: Icon(icon, color: Colors.deepPurple),
//           onPressed: onPressed,
//         ),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }

//   void _openFullScreen(BuildContext context, String url) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FullScreenPlayer(url: url),
//       ),
//     );
//   }
// }

// class FullScreenPlayer extends StatefulWidget {
//   final String url;

//   const FullScreenPlayer({super.key, required this.url});

//   @override
//   _FullScreenPlayerState createState() => _FullScreenPlayerState();
// }

// class _FullScreenPlayerState extends State<FullScreenPlayer> {
//   late VlcPlayerController _fullscreenController;

//   @override
//   void initState() {
//     super.initState();
//     _fullscreenController = VlcPlayerController.network(
//       widget.url,
//       hwAcc: HwAcc.full,
//       autoPlay: true,
//       options: VlcPlayerOptions(
//         advanced: VlcAdvancedOptions([
//           '--network-caching=200',
//           '--file-caching=200',
//           '--live-caching=200',
//           '--rtsp-timeout=10',
//         ]),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _fullscreenController.stop();
//     _fullscreenController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Center(
//         child: VlcPlayer(
//           controller: _fullscreenController,
//           aspectRatio: MediaQuery.of(context).size.aspectRatio,
//           placeholder: const Center(child: CircularProgressIndicator()),
//         ),
//       ),
//     );
//   }
// }
