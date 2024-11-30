import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stream_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches all camera streams from Firestore
  Future<List<StreamModel>> fetchCameraStreams() async {
    try {
      final snapshot = await _firestore.collection('cameraStreams').get();
      final streams = snapshot.docs.map((doc) {
        return StreamModel.fromJson(doc.data(), doc.id);
      }).toList();
      print('Fetched ${streams.length} camera streams.');
      return streams;
    } catch (e) {
      print('Failed to fetch streams: $e');
      return [];
    }
  }

  /// Adds a new camera stream to Firestore
  Future<void> addCameraStream(
    String id,
    String name,
    String rtspUrl, {
    String? snapshotUrl,
    bool isOnline = true,
  }) async {
    try {
      final data = {
        'name': name,
        'rtspUrl': rtspUrl,
        'snapshotUrl': snapshotUrl,
        'isOnline': isOnline,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('cameraStreams').doc(id).set(data);
      print('Camera added: $name with ID $id');
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
        print('Camera updated: $documentId with data: $updatedData');
      } else {
        print('No fields provided for update on $documentId');
      }
    } catch (e) {
      print('Failed to update camera: $e');
      throw Exception('Failed to update camera');
    }
  }

  /// Deletes a camera stream from Firestore by document ID
  Future<void> deleteCameraStream(String documentId) async {
    try {
      print("Attempting to delete camera stream: $documentId");
      await _firestore.collection('cameraStreams').doc(documentId).delete();
      print("Camera stream deleted: $documentId");
    } catch (e) {
      print("Failed to delete camera stream: $e");
      throw Exception('Failed to delete camera stream');
    }
  }

  /// Fetches a single camera stream by its document ID
  Future<StreamModel?> fetchCameraStreamById(String documentId) async {
    try {
      final doc = await _firestore.collection('cameraStreams').doc(documentId).get();
      if (doc.exists) {
        final stream = StreamModel.fromJson(doc.data()!, doc.id);
        print('Fetched camera stream: $documentId');
        return stream;
      } else {
        print('Camera stream not found: $documentId');
        return null;
      }
    } catch (e) {
      print('Failed to fetch camera stream: $e');
      return null;
    }
  }

  /// Marks a camera stream as offline
  Future<void> markCameraAsOffline(String documentId) async {
    try {
      final data = {
        'isOnline': false,
        'offlineTimestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('cameraStreams').doc(documentId).update(data);
      print("Camera marked as offline: $documentId");
    } catch (e) {
      print("Failed to mark camera as offline: $e");
      throw Exception('Failed to mark camera as offline');
    }
  }

  /// Marks a camera stream as online
  Future<void> markCameraAsOnline(String documentId) async {
    try {
      final data = {
        'isOnline': true,
        'offlineTimestamp': null,
      };
      await _firestore.collection('cameraStreams').doc(documentId).update(data);
      print("Camera marked as online: $documentId");
    } catch (e) {
      print("Failed to mark camera as online: $e");
      throw Exception('Failed to mark camera as online');
    }
  }

  /// Validates if a given RTSP URL is valid and updates the `isOnline` status
  Future<void> validateAndUpdateCameraStatus(String documentId, bool isOnline) async {
    try {
      final data = {
        'isOnline': isOnline,
        'offlineTimestamp': isOnline ? null : FieldValue.serverTimestamp(),
      };

      await _firestore.collection('cameraStreams').doc(documentId).update(data);
      print("Camera $documentId validation updated: isOnline=$isOnline");
    } catch (e) {
      print("Failed to validate and update camera status: $e");
      throw Exception('Failed to validate camera status');
    }
  }
}
