import 'dart:convert';

class StreamModel {
  final String id;
  final String name;
  final String url;
  final bool isOnline;
  final String? offlineTimestamp;
  final String? snapshotUrl; // Add this property


  StreamModel({
    required this.id,
    required this.name,
    required this.url,
    required this.isOnline,
    this.offlineTimestamp,
    this.snapshotUrl,

  });

  /// Creates a `StreamModel` from a JSON map and Firestore ID
  factory StreamModel.fromJson(Map<String, dynamic> json, String id) {
    return StreamModel(
      id: id,
      name: json['name'] ?? 'Unnamed Stream',
      url: json['url'] ?? '',
      isOnline: json['isOnline'] ?? true, // Default to online
      offlineTimestamp: json['offlineTimestamp'], // Nullable
      snapshotUrl: json['snapshotUrl'], // Fetch from the database

    );
  }

  /// Converts a `StreamModel` to a JSON map (excluding Firestore ID)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'isOnline': isOnline,
      'offlineTimestamp': offlineTimestamp,
    };
  }

  /// Encodes a list of `StreamModel` objects into a JSON string
  static String encode(List<StreamModel> streams) {
    return json.encode(
      streams.map<Map<String, dynamic>>((stream) => stream.toJson()).toList(),
    );
  }

  /// Decodes a JSON string into a list of `StreamModel` objects
  static List<StreamModel> decode(String jsonString) {
    try {
      final decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.map<StreamModel>((item) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);
        final id = itemMap.remove('id') ?? '';
        return StreamModel.fromJson(itemMap, id);
      }).toList();
    } catch (e) {
      // Log or handle error if necessary
      return [];
    }
  }

  /// Converts a Firestore document snapshot to a `StreamModel`
  static StreamModel fromFirestore(Map<String, dynamic> data, String id) {
    return StreamModel(
      id: id,
      name: data['name'] ?? 'Unnamed Stream',
      url: data['url'] ?? '',
      isOnline: data['isOnline'] ?? true, // Default to online
      offlineTimestamp: data['offlineTimestamp'], // Nullable
    );
  }

  /// Validate if the stream URL is valid
  bool get isValidUrl => url.isNotEmpty && (url.startsWith('rtsp://') || url.startsWith('http://'));

  /// Debug-friendly string representation
  @override
  String toString() {
    return 'StreamModel{id: $id, name: $name, url: $url, isOnline: $isOnline, offlineTimestamp: $offlineTimestamp}';
  }

  /// Create a new instance with updated fields
  StreamModel copyWith({
    String? id,
    String? name,
    String? url,
    bool? isOnline,
    String? offlineTimestamp,
  }) {
    return StreamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      isOnline: isOnline ?? this.isOnline,
      offlineTimestamp: offlineTimestamp ?? this.offlineTimestamp,
    );
  }

  /// Update the `isOnline` status and offline timestamp dynamically
  StreamModel updateOnlineStatus(bool status, {String? timestamp}) {
    return copyWith(
      isOnline: status,
      offlineTimestamp: status ? null : (timestamp ?? DateTime.now().toIso8601String()),
    );
  }
}
