import 'package:flutter/material.dart';
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
      onDoubleTap: stream.isOnline
          ? onCardDoubleTap // Open stream on double-tap if online
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Stream is offline. Cannot open."),
                  backgroundColor: Colors.red,
                ),
              );
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
                            content: Text("Edit functionality is not implemented."),
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
                height: screenHeight * 0.22, // Adjusted height for snapshot
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  color: Colors.grey.shade200,
                ),
                child: stream.isOnline
                    ? (stream.isValidSnapshotUrl
                        ? ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16.0)),
                            child: Image.network(
                              stream.snapshotUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image,
                                    size: 40, color: Colors.red),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              "Snapshot unavailable",
                              style: TextStyle(color: Colors.black),
                            ),
                          ))
                    : Container(
                        color: Colors.black,
                        child: const Center(
                          child:
                              Icon(Icons.error, size: 50, color: Colors.red),
                        ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          stream.isOnline
                              ? "Stream is live."
                              : "Stream is offline.",
                        ),
                      ),
                    );
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
