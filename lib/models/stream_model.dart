import 'dart:convert';

class StreamModel {
  final String name;
  final String url;

  StreamModel({required this.name, required this.url});

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(name: json['name'], url: json['url']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }

  static String encode(List<StreamModel> streams) => json.encode(
        streams.map<Map<String, dynamic>>((stream) => stream.toJson()).toList(),
      );

  static List<StreamModel> decode(String jsonString) =>
      (json.decode(jsonString) as List<dynamic>)
          .map<StreamModel>((item) => StreamModel.fromJson(item))
          .toList();
}
