<<<<<<< HEAD
# Endroid

Camera Streaming Application for Endroid USA

## Project Overview

**Endroid** is a Flutter-based camera streaming application built to provide live streaming and playback functionality. This project leverages the `flutter_vlc_player` package for video streaming, along with other dependencies to handle UI, state management, and additional features such as screenshots and video recording.

## Features

- Live streaming and playback functionality.
- Record video streams and save them locally.
- Take screenshots during playback.
- Mute/unmute video and control audio.
- Toggle between live streaming and video playback modes.
- Adjustable caching and stream settings.
- Simple and responsive UI for camera streaming controls.

## Getting Started

To get started with the **Endroid** application, follow these steps to set up the project on your local machine.

### Prerequisites

Make sure you have the following installed on your system:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A code editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
- An Android or iOS emulator, or a physical device to run the app.

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/endroid.git

2. Navigate to the project directory:

    cd endroid

3. Install the required dependencies:

    flutter pub get

4. Run the application:

    flutter run

### VLC Player Configuration

Basic Stream Setup

VlcPlayerController _vlcController = VlcPlayerController.network(
  streamUrl,
  hwAcc: HwAcc.full,
  autoPlay: true,
  options: VlcPlayerOptions(
    advanced: VlcAdvancedOptions([
      '--network-caching=2000',
      '--live-caching=2000',
      '--rtsp-tcp',
      '--rtsp-frame-buffer-size=1000000',
    ]),
  ),
);

### Performance Optimization


Network SettingsRecommended buffer sizes:Unstable networks: 2000-3000ms

'--network-caching=2000',
'--live-caching=2000',
'--rtsp-frame-buffer-size=1000000',
'--network-synchronization=1',

### Dependencies

dependencies:
  flutter_vlc_player: ^7.4.0
  animated_toggle_switch: ^0.7.0
  path_provider: ^2.1.1
  provider: ^6.0.5
  shared_preferences: ^2.2.0



### Example Code
Below is an example of the main streaming player code that uses the flutter_vlc_player package to play camera streams.

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class SimpleVlcPlayer extends StatefulWidget {
  final String url;

  const SimpleVlcPlayer({super.key, required this.url});

  @override
  State<SimpleVlcPlayer> createState() => _SimpleVlcPlayerState();
}

class _SimpleVlcPlayerState extends State<SimpleVlcPlayer> {
  late VlcPlayerController _vlcController;
  bool isLive = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _vlcController = VlcPlayerController.network(
        widget.url,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            '--network-caching=1000',
            '--rtsp-tcp',
            '--no-audio',
            '--quiet',
          ]),
          video: VlcVideoOptions([
            '--video-filter=deinterlace',
            '--deinterlace-mode=blend',
          ]),
        ),
      );
    } catch (e) {
      debugPrint("Error initializing VLC Player: $e");
    }
  }

  @override
  void dispose() {
    _vlcController.stop();
    _vlcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Stream')),
      body: VlcPlayer(
        controller: _vlcController,
        aspectRatio: 16 / 9,
        placeholder: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

### Stream Configuration Options

VLC Player Options
--network-caching: Sets the cache size (in milliseconds) for network streams. Default is 1500ms. Lower values reduce latency, but can result in unstable playback if network is not fast enough.
--rtsp-tcp: Forces the use of TCP for RTSP streaming. This can help improve stability, especially on unreliable networks.
--no-audio: Disables audio output by default (useful for live streaming where audio is unnecessary).
--quiet: Suppresses VLC logs to reduce console clutter. Change to --verbose=2 for more detailed logging during development.

### Screenshots and Recordings

The application supports taking screenshots and recording streams:

Future<void> _takeScreenshot() async {
  try {
    final directory = await getTemporaryDirectory();
    final savedPath = await _vlcController.takeSnapshot();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Screenshot saved: $savedPath')),
      );
    }
  } catch (e) {
    debugPrint("Error taking screenshot: $e");
  }
}


## Error Handling

The _handlePlaybackError method handles errors that may occur during streaming, ensuring the player attempts to recover and restart the stream.

void _handlePlaybackError() {
  if (_vlcController.value.hasError) {
    debugPrint("VLC Player encountered an error: ${_vlcController.value.errorDescription}");
    _vlcController.stop();
    _vlcController.play(); // Attempt to restart playback
  }
}

## UI Components

Toggle Switch: Allows users to switch between live streaming and playback modes with an animated toggle.
Action Buttons: Provides various actions such as recording, taking screenshots, and controlling audio.
VLC Player Widget: Displays the video stream, and supports user actions like play, pause, and fullscreen.


Contributing
We welcome contributions to improve Endroid. Please fork this repository, create a new branch, and submit a pull request. Make sure to follow the code style and write tests for any new features or bug fixes.

License
This project is licensed under the MIT License - see the LICENSE file for details.

Resources
Lab: Write your first Flutter app
Cookbook: Useful Flutter samples
Flutter Documentation
For help getting started with Flutter development, view the online documentation, which offers tutorials, samples, guidance on mobile development, and a full API reference.

### Project Structure :

endroid/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── stream_model.dart
│   ├── screens/
│   │   └── player_screen.dart
│   ├── widgets/
│   │   └── vlc_player.dart
│   └── utils/
│       └── stream_utils.dart
├── assets/
└── test/

---

### Breakdown of the `README.md`:

1. **Project Overview**: Provides a brief description of the app and its core features.
2. **Getting Started**: Walkthrough of setting up the project locally, including prerequisites, installation steps, and running the app.
3. **Dependencies**: Lists the key dependencies used in the project (e.g., `flutter_vlc_player`, `animated_toggle_switch`).
4. **Example Code**: Shows an example of the main functionality for streaming.
5. **Stream Configuration**: Describes the important VLC options used for streaming and caching.
6. **Screenshots and Recording**: Explains how screenshots and video recordings work in the app.
7. **Error Handling**: Demonstrates how to handle playback errors in the app.
8. **UI Components**: Mentions the main UI elements like the toggle switch and action buttons.
9. **Contributing**: Encourages others to contribute to the project.
10. **License**: Provides licensing information (MIT License, which you can change based on your project's license).

---

This should give anyone working on the project a solid understanding of how it works, how to set it up, and how they can contribute or use it in their own projects. Let me know if you need any further adjustments! @github.com/shivu21
=======
# VMS_flutter
>>>>>>> dd4d9bd71783c4a0153634dd5f92c3070092e9c2
