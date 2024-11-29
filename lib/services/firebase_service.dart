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
  Future<void> addCameraStream(
    String id,
    String name,
    String rtspUrl, {
    String? snapshotUrl,
    bool isOnline = true, // Default to true for new cameras
  }) async {
    try {
      await _firestore.collection('cameraStreams').doc(id).set({
        'name': name,
        'rtspUrl': rtspUrl,
        'snapshotUrl': snapshotUrl,
        'isOnline': isOnline,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Camera added: $name');
    } catch (e) {
      print('Failed to add camera: $e');
      throw Exception('Failed to add camera');
    }
  }

  /// Updates an existing camera stream in Firestore
  Future<void> updateCameraStream(
    String documentId, {
    String? name,
    String? rtspUrl,
    String? snapshotUrl,
    bool? isOnline,
  }) async {
    try {
      final Map<String, dynamic> updatedData = {};

      if (name != null) updatedData['name'] = name;
      if (rtspUrl != null) updatedData['rtspUrl'] = rtspUrl;
      if (snapshotUrl != null) updatedData['snapshotUrl'] = snapshotUrl;
      if (isOnline != null) updatedData['isOnline'] = isOnline;

      if (updatedData.isNotEmpty) {
        await _firestore.collection('cameraStreams').doc(documentId).update(updatedData);
        print('Camera updated: $documentId'); // Debug log
      } else {
        print('No fields to update for $documentId'); // Debug log
      }
    } catch (e) {
      print('Failed to update camera: $e'); // Debug log
      throw Exception('Failed to update camera');
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

  /// Fetches a single camera stream by its document ID
  Future<StreamModel?> fetchCameraStreamById(String documentId) async {
    try {
      final doc = await _firestore.collection('cameraStreams').doc(documentId).get();
      if (doc.exists) {
        return StreamModel.fromJson(doc.data()!, doc.id);
      } else {
        print('Camera stream not found: $documentId'); // Debug log
        return null;
      }
    } catch (e) {
      print('Failed to fetch camera stream: $e'); // Debug log
      return null;
    }
  }

  /// Marks a camera stream as offline
  Future<void> markCameraAsOffline(String documentId) async {
    try {
      await _firestore.collection('cameraStreams').doc(documentId).update({
        'isOnline': false,
        'offlineTimestamp': FieldValue.serverTimestamp(),
      });
      print("Camera marked as offline: $documentId");
    } catch (e) {
      print("Failed to mark camera as offline: $e"); // Debug log
      throw Exception('Failed to mark camera as offline');
    }
  }

  /// Restores a camera stream to online
  Future<void> markCameraAsOnline(String documentId) async {
    try {
      await _firestore.collection('cameraStreams').doc(documentId).update({
        'isOnline': true,
        'offlineTimestamp': null,
      });
      print("Camera marked as online: $documentId");
    } catch (e) {
      print("Failed to mark camera as online: $e"); // Debug log
      throw Exception('Failed to mark camera as online');
    }
  }
}
