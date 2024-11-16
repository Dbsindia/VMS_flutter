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
      onTap: onCardTap,
      child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: stream.isOnline
                  ? Image.network(
                      stream.snapshotUrl ??
                          stream.url, // Use snapshot if available
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.red),
                      ),
                    )
                  : Container(
                      color: Colors.grey,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off,
                                size: 50, color: Colors.white),
                            Text(
                              "Offline since ${stream.offlineTimestamp ?? 'unknown'}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            ElevatedButton(
                              onPressed: onOfflineAssistance,
                              child: const Text("Offline Assistance"),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 8.0,
              left: 8.0,
              right: 8.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stream.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
