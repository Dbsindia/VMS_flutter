import 'package:easy_onvif/onvif.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

class OnvifService {
  final String host;
  final String username;
  final String password;
  Onvif? onvif;

  OnvifService({
    required this.host,
    required this.username,
    required this.password,
  });

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
      print("Failed to initialize ONVIF connection for $host: $e");
      throw Exception('Failed to initialize ONVIF connection: $e');
    }
  }

  /// Discover ONVIF devices on the network using `ping_discover_network`
  static Future<List<Map<String, String>>> discoverDevices(
      String subnet, int port) async {
    final List<Map<String, String>> discoveredDevices = [];
    final stream = NetworkAnalyzer.discover2(subnet, port);

    print("Starting discovery on subnet $subnet with port $port...");

    try {
      await for (final addr in stream) {
        if (addr.exists) {
          discoveredDevices.add({
            'ip': addr.ip,
            'name': 'Discovered Device (${addr.ip})',
          });
          print('Discovered Device: ${addr.ip}');
        }
      }
      if (discoveredDevices.isEmpty) {
        print("No devices found on subnet $subnet.");
      }
    } catch (e) {
      print("Error during device discovery: $e");
      throw Exception("Device discovery failed: $e");
    }

    return discoveredDevices;
  }

  /// Fetch RTSP URL for the ONVIF device
  Future<String?> getRtspUrl() async {
    try {
      if (onvif == null) {
        throw Exception('ONVIF is not initialized. Call initialize() first.');
      }

      final profiles = await onvif!.media.getProfiles();
      if (profiles.isEmpty) {
        print('No media profiles available for $host');
        throw Exception('No media profiles available.');
      }

      final streamUri = await onvif!.media.getStreamUri(profiles.first.token);
      print("RTSP URL for $host: $streamUri");
      return streamUri;
    } catch (e) {
      print("Error fetching RTSP URL for $host: $e");
      throw Exception('Error fetching RTSP URL: $e');
    }
  }

  /// Fetch Snapshot URL for the ONVIF device
  Future<String?> getSnapshotUri() async {
    try {
      if (onvif == null) {
        throw Exception('ONVIF is not initialized. Call initialize() first.');
      }

      final profiles = await onvif!.media.getProfiles();
      if (profiles.isEmpty) {
        print('No media profiles available for $host');
        throw Exception('No media profiles available.');
      }

      final snapshotUri =
          await onvif!.media.getSnapshotUri(profiles.first.token);
      print("Snapshot URL for $host: $snapshotUri");
      return snapshotUri;
    } catch (e) {
      print("Error fetching Snapshot URL for $host: $e");
      throw Exception('Error fetching Snapshot URL: $e');
    }
  }

  /// Fetch Device Information
  Future<Map<String, String>> getDeviceInfo() async {
    try {
      if (onvif == null) {
        throw Exception('ONVIF is not initialized. Call initialize() first.');
      }

      final deviceInfo = await onvif!.deviceManagement.getDeviceInformation();

      // Ensure all values are converted to strings
      final Map<String, String> info = {
        'Manufacturer': deviceInfo.manufacturer ?? 'Unknown',
        'Model': deviceInfo.model ?? 'Unknown',
        'Firmware Version': deviceInfo.firmwareVersion ?? 'Unknown',
        'Serial Number': deviceInfo.serialNumber ?? 'Unknown',
      };

      print("Device Information for $host: $info");
      return info;
    } catch (e) {
      print("Error fetching device information for $host: $e");
      throw Exception('Error fetching device information: $e');
    }
  }
}
