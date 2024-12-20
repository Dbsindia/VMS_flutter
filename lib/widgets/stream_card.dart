import 'package:endroid/screens/full_screen_view.dart';
import 'package:endroid/screens/mock/simple_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart'; // Import VLC Player
import '../models/stream_model.dart';

class StreamCard extends StatelessWidget {
  final StreamModel stream;
  final VoidCallback onOfflineAssistance;
  final VoidCallback onCardDoubleTap;
  final VoidCallback onDelete;

  const StreamCard({
    super.key,
    required this.stream,
    required this.onOfflineAssistance,
    required this.onCardDoubleTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onDoubleTap: () {
        if (stream.isOnline) {
          debugPrint("Navigating to Full Screen for stream: ${stream.name}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SimpleVlcPlayer(
                stream: stream,
                url: stream.url,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Stream is offline. Cannot open."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        elevation: 8.0,
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Adjust height dynamically
          children: [
            // Header Row: Stream Name, Status Dot, and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    // Status Dot
                    Icon(
                      Icons.circle,
                      color: stream.isOnline ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 5),
                    // Stream Name
                    Text(
                      stream.name,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle long names
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Edit functionality is not implemented."),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            // Stream Snapshot or Placeholder
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.grey.shade200,
                ),
                child: stream.isOnline
                    ? (stream.isValidSnapshotUrl
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              stream.snapshotUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image,
                                    size: 50, color: Colors.red),
                              ),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          )
                        : const Center(
                            child: Text("Snapshot unavailable",
                                style: TextStyle(color: Colors.black)),
                          ))
                    : const Center(
                        child: Icon(Icons.error, size: 50, color: Colors.red),
                      ),
              ),
            ),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Stream Info:\nName: ${stream.name}\nURL: ${stream.url}"),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: stream.isOnline
                      ? const Icon(Icons.play_arrow, color: Colors.green)
                      : const Icon(Icons.pause, color: Colors.grey),
                  onPressed: () {
                    if (stream.isOnline) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SimpleVlcPlayer(
                            stream: stream,
                            url: stream.url, // Pass the stream data if needed
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Stream is offline."),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("More options are not implemented."),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Offline Assistance Button
            if (!stream.isOnline)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: onOfflineAssistance,
                  icon: const Icon(Icons.help_outline),
                  label: const Text(
                    "Offline Assistance",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.6, 40),
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
