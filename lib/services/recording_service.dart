import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class RecordingService {
  Future<void> uploadStreamRecording(File recording, String fileName) async {
    final storageRef = FirebaseStorage.instance.ref().child('recordings/$fileName');
    await storageRef.putFile(recording);
  }
}
