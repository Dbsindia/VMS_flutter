import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreamModel {
  String id;
  String name;
  String url; // RTSP URL
  String snapshotUrl; // Snapshot URL
  bool isOnline;
  DateTime createdAt;
  String? offlineTimestamp;

  StreamModel({
    required this.id,
    required this.name,
    required this.url,
    required this.snapshotUrl,
    required this.isOnline,
    required this.createdAt,
    this.offlineTimestamp,
  });

  /// Create an instance from JSON
  factory StreamModel.fromJson(Map<String, dynamic> json, String id) {
    return StreamModel(
      id: id,
      name: json['name'] ?? 'Unnamed Stream',
      url: json['url'] ?? '',
      snapshotUrl: json['snapshotUrl'] ?? '',
      isOnline: json['isOnline'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      offlineTimestamp: json['offlineTimestamp'],
    );
  }

  /// Convert the model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'snapshotUrl': snapshotUrl,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      if (offlineTimestamp != null) 'offlineTimestamp': offlineTimestamp,
    };
  }

  /// Encode a list of `StreamModel` objects into a JSON string
  static String encode(List<StreamModel> streams) {
    return json.encode(
      streams.map<Map<String, dynamic>>((stream) => stream.toJson()).toList(),
    );
  }

  /// Decode a JSON string into a list of `StreamModel` objects
  static List<StreamModel> decode(String jsonString) {
    try {
      final decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.map<StreamModel>((item) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);
        final id = itemMap.remove('id') ?? '';
        return StreamModel.fromJson(itemMap, id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Create an instance from Firestore data
  factory StreamModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StreamModel(
      id: id,
      name: data['name'] ?? '',
      url: data['url'] ?? '',
      snapshotUrl: data['snapshotUrl'] ?? '',
      isOnline: data['isOnline'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      offlineTimestamp: data['offlineTimestamp'],
    );
  }

  /// Validate if the RTSP URL is valid
  bool get isValidUrl => url.isNotEmpty && url.startsWith('rtsp://');

  /// Validate if the Snapshot URL is valid
  bool get isValidSnapshotUrl =>
      snapshotUrl.isNotEmpty &&
      (snapshotUrl.startsWith('http://') || snapshotUrl.startsWith('https://'));

  /// Debug-friendly string representation
  @override
  String toString() {
    return 'StreamModel{id: $id, name: $name, url: $url, snapshotUrl: $snapshotUrl, isOnline: $isOnline, offlineTimestamp: $offlineTimestamp}';
  }

  /// Create a new instance with updated fields
  StreamModel copyWith({
    String? id,
    String? name,
    String? url,
    String? snapshotUrl,
    bool? isOnline,
    DateTime? createdAt,
    String? offlineTimestamp,
  }) {
    return StreamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      snapshotUrl: snapshotUrl ?? this.snapshotUrl,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      offlineTimestamp: offlineTimestamp ?? this.offlineTimestamp,
    );
  }

  /// Update the `isOnline` status and offline timestamp dynamically
  StreamModel updateOnlineStatus(bool status, {String? timestamp}) {
    return copyWith(
      isOnline: status,
      offlineTimestamp:
          status ? null : (timestamp ?? DateTime.now().toIso8601String()),
    );
  }
}
