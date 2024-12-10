import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/stream_model.dart';
import 'stream_card.dart';

class CameraGridView extends StatelessWidget {
  final List<StreamModel> streams; // List of camera streams
  final int gridCount; // Number of columns for the grid
  final Function(StreamModel) onStreamSelected; // Callback for stream selection
  final Function(StreamModel) onStreamDeleted; // Callback for stream deletion
  final Function(StreamModel) onOfflineAssistance; // Callback for offline assistance

  const CameraGridView({
    super.key,
    required this.streams,
    required this.gridCount,
    required this.onStreamSelected,
    required this.onStreamDeleted,
    required this.onOfflineAssistance,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = 8.0; // Spacing between cards
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardAspectRatio = gridCount == 1
            ? 1.5 // Single-column layout (wide cards)
            : constraints.maxWidth / (constraints.maxHeight / gridCount);

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount, // Number of columns
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: cardAspectRatio,
          ),
          itemCount: streams.length,
          itemBuilder: (context, index) {
            final stream = streams[index];

            return VisibilityDetector(
              key: Key('stream-${stream.id}'),
              onVisibilityChanged: (visibilityInfo) {
                if (visibilityInfo.visibleFraction < 0.5) {
                  debugPrint("Stream ${stream.name} is less than 50% visible.");
                  // Optional: Pause or stop VLC playback if necessary
                }
              },
              child: StreamCard(
                stream: stream,
                onCardDoubleTap: () => onStreamSelected(stream),
                onDelete: () => onStreamDeleted(stream),
                onOfflineAssistance: () => onOfflineAssistance(stream),
              ),
            );
          },
        );
      },
    );
  }
}
