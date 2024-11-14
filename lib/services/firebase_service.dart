import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stream_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all camera streams from Firestore
  Future<List<StreamModel>> fetchCameraStreams() async {
    try {
      final snapshot = await _firestore.collection('cameraStreams').get();
      return snapshot.docs.map((doc) {
        return StreamModel.fromJson(doc.data(), doc.id); // Use document ID
      }).toList();
    } catch (e) {
      print('Failed to fetch streams: $e'); // Debug log
      return [];
    }
  }

  /// Adds a new camera stream to Firestore
  Future<void> addCameraStream(String id, String name, String url) async {
    try {
      await _firestore.collection('cameraStreams').doc(id).set({
        'name': name,
        'url': url,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Camera added: $name'); // Debug log
    } catch (e) {
      print('Failed to add camera: $e'); // Debug log
      throw Exception('Failed to add camera');
    }
  }

  /// Deletes a camera stream from Firestore by document ID
  Future<void> deleteCameraStream(String documentId) async {
    try {
      print("Deleting camera stream: $documentId");
      await _firestore.collection('cameraStreams').doc(documentId).delete();
      print("Camera stream deleted: $documentId");
    } catch (e) {
      print("Failed to delete camera: $e"); // Debug log
      throw Exception('Failed to delete camera');
    }
  }
}
