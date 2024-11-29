import 'package:easy_onvif/onvif.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class OnvifService {
  final String host;
  final String username;
  final String password;
  Onvif? onvif;

  OnvifService({required this.host, required this.username, required this.password});

  /// Initialize the ONVIF instance
  Future<void> initialize() async {
    try {
      onvif = await Onvif.connect(
        host: host,
        username: username,
        password: password,
      );
      print("ONVIF connection initialized for host: $host");
    } catch (e) {
      throw Exception('Failed to initialize ONVIF connection: $e');
    }
  }

  /// Discover ONVIF devices on the network using ping_discover_network
  static Future<List<String>> discoverDevices(String subnet, int port) async {
    final List<String> discoveredDevices = [];
    final stream = NetworkAnalyzer.discover2(subnet, port);

    await for (final addr in stream) {
      if (addr.exists) {
        discoveredDevices.add(addr.ip);
        print('Discovered Device: ${addr.ip}');
      }
    }

    return discoveredDevices;
  }

  /// Get RTSP URL for a given device
  Future<String?> getRtspUrl() async {
    try {
      if (onvif == null) {
        throw Exception('ONVIF is not initialized. Call initialize() first.');
      }

      final profiles = await onvif!.media.getProfiles();
      if (profiles.isEmpty) {
        throw Exception('No media profiles available.');
      }

      final streamUri = await onvif!.media.getStreamUri(profiles.first.token);
      print("RTSP URL: $streamUri");
      return streamUri;
    } catch (e) {
      throw Exception('Error fetching RTSP URL: $e');
    }
  }

  /// Get Snapshot URL
  Future<String?> getSnapshotUri() async {
    try {
      if (onvif == null) {
        throw Exception('ONVIF is not initialized. Call initialize() first.');
      }

      final profiles = await onvif!.media.getProfiles();
      if (profiles.isEmpty) {
        throw Exception('No media profiles available.');
      }

      final snapshotUri = await onvif!.media.getSnapshotUri(profiles.first.token);
      print("Snapshot URL: $snapshotUri");
      return snapshotUri;
    } catch (e) {
      throw Exception('Error fetching Snapshot URL: $e');
    }
  }
}
