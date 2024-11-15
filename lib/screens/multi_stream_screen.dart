import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stream_provider.dart' as custom_stream_provider;
import '../widgets/stream_card.dart';
import 'full_screen_view.dart';

class MultiStreamScreen extends StatelessWidget {
  const MultiStreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final streamProvider = Provider.of<custom_stream_provider.StreamProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Streams"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: streamProvider.loadStreams,
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.grid_view),
            tooltip: "Change Layout",
            onSelected: (value) {
              streamProvider.updateGridLayout(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Layout changed to $value x $value")),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("1x1 Layout")),
              const PopupMenuItem(value: 2, child: Text("2x2 Layout")),
              const PopupMenuItem(value: 3, child: Text("3x3 Layout")),
            ],
          ),
        ],
      ),
      body: streamProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : streamProvider.streams.isEmpty
              ? const Center(child: Text("No streams available. Add one!"))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: streamProvider.gridCount,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: streamProvider.gridCount == 1 ? 1.5 : 1.2,
                  ),
                  itemCount: streamProvider.streams.length,
                  itemBuilder: (context, index) {
                    final stream = streamProvider.streams[index];
                    return StreamCard(
                      stream: stream,
                      onOfflineAssistance: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Check power supply and network"),
                          ),
                        );
                      },
                      onCardTap: () async {
                        final controller =
                            await streamProvider.initializeController(stream.url);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullScreenView(stream: stream, controller: controller),
                          ),
                        );
                      },
                      onDelete: () {
                        streamProvider.deleteStream(index);
                      },
                    );
                  },
                ),
    );
  }
}
