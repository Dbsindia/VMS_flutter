import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh chat messages
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open chat settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Message List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: 10, // Placeholder for message count
              itemBuilder: (context, index) {
                final isOwnMessage = index % 2 == 0;
                return Align(
                  alignment:
                      isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isOwnMessage
                          ? Colors.blueAccent.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      isOwnMessage
                          ? "This is my message #$index"
                          : "This is a received message #$index",
                      style: TextStyle(
                        color: isOwnMessage ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Input and Action Bar
          _buildInputBar(context),
        ],
      ),
    );
  }

  /// Builds the input bar with action buttons and a text field
  Widget _buildInputBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Camera Snapshot Button
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.blue),
            onPressed: () {
              // Capture snapshot and attach
            },
          ),
          // Video Record Button
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.green),
            onPressed: () {
              // Start video recording and attach
            },
          ),
          // Text Input
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          // Send Button
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurple),
            onPressed: () {
              // Send message logic
            },
          ),
        ],
      ),
    );
  }
}
