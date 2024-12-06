// import 'dart:io';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/material.dart';

// Future<void> _takeSnapshot(int index) async {
//   try {
//     // Take snapshot from the controller
//     final Uint8List snapshot = await controllers[index].takeSnapshot();

//     // Get the application documents directory
//     final directory = await getApplicationDocumentsDirectory();

//     // Generate a file path for the snapshot
//     final filePath = '${directory.path}/snapshot_${DateTime.now().millisecondsSinceEpoch}.png';

//     // Save the snapshot as a file
//     final file = File(filePath);
//     await file.writeAsBytes(snapshot);

//     // Notify the user about the saved snapshot
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Snapshot saved to $filePath'),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   } catch (e) {
//     // Handle errors gracefully
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Failed to take snapshot: $e'),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }
