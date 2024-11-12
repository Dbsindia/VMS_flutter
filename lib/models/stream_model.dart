import 'dart:convert';

class StreamModel {
  final String name;
  final String url;

  StreamModel({required this.name, required this.url});

  /// Creates a `StreamModel` from a JSON map
  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      name: json['name'] ?? 'Unnamed Stream',
      url: json['url'] ?? '',
    );
  }

  /// Converts a `StreamModel` to a JSON map
  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
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
      return decoded
          .map<StreamModel>((item) => StreamModel.fromJson(item))
          .toList();
    } catch (e) {
      // In case of an error, return an empty list
      return [];
    }
  }
}
