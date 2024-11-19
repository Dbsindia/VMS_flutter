import 'package:flutter/material.dart';
import '../models/stream_model.dart';

class StreamCard extends StatelessWidget {
  final StreamModel stream;
  final VoidCallback onOfflineAssistance;
  final VoidCallback onCardTap;
  final VoidCallback onDelete;

  const StreamCard({
    super.key,
    required this.stream,
    required this.onOfflineAssistance,
    required this.onCardTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: stream.isOnline
          ? onCardTap // Only allow tapping if the stream is online
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Stream is offline. Cannot open."),
                  backgroundColor: Colors.red,
                ),
              );
            },
      child: Card(
        elevation: 20.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26.0),
        ),
        child: Column(
          children: [
            // Snapshot or Error Placeholder
            SizedBox(
              height: 150,
              child: stream.isOnline
                  ? (stream.snapshotUrl != null &&
                          stream.snapshotUrl!.startsWith('http'))
                      ? Image.network(
                          stream.snapshotUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: Colors.red),
                          ),
                        )
                      : const Center(
                          child: Text(
                            "Snapshot unavailable",
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.error, size: 50, color: Colors.red),
                      ),
                    ),
            ),
            const SizedBox(height: 14.0),
            // Card Content with Online/Offline Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      stream.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Handle long stream names
                    ),
                  ),
                  stream.isOnline
                      ? const Chip(
                          label: Text(
                            "Online",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color.fromARGB(255, 67, 136, 68),
                        )
                      : const Chip(
                          label: Text(
                            "Offline",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Stream"),
                          content: Text(
                              "Are you sure you want to delete ${stream.name}?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onDelete(); // Trigger the delete functionality
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            // Offline Assistance Button (if offline)
            if (!stream.isOnline)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: onOfflineAssistance,
                  icon: const Icon(Icons.help_outline),
                  label: const Text("Offline Assistance"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
