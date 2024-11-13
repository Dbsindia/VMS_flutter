import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stream_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<StreamModel>> fetchCameraStreams() async {
    print("Fetching camera streams...");
    final snapshot = await _firestore.collection('cameraStreams').get();
    print("Fetched ${snapshot.docs.length} streams.");
    return snapshot.docs.map((doc) {
      return StreamModel.fromJson(doc.data(), doc.id);
    }).toList();
  }

  Future<void> addCameraStream(String name, String url) async {
    print("Adding camera stream: $name");
    await _firestore.collection('cameraStreams').add({
      'name': name,
      'url': url,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print("Camera stream added: $name");
  }

  Future<void> deleteCameraStream(String documentId) async {
    print("Deleting camera stream: $documentId");
    await _firestore.collection('cameraStreams').doc(documentId).delete();
    print("Camera stream deleted: $documentId");
  }
}
