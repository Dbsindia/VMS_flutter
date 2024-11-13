import 'dart:convert';

class StreamModel {
  final String id;
  final String name;
  final String url;

  StreamModel({required this.id, required this.name, required this.url});

  /// Creates a `StreamModel` from a JSON map and Firestore ID
  factory StreamModel.fromJson(Map<String, dynamic> json, String id) {
    return StreamModel(
      id: id, // Use the Firestore document ID
      name: json['name'] ?? 'Unnamed Stream',
      url: json['url'] ?? '',
    );
  }

  /// Converts a `StreamModel` to a JSON map (excluding Firestore ID)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
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
        final id = itemMap.remove('id') ?? ''; // Extract ID if available
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
    );
  }
}
