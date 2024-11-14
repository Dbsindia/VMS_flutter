import 'package:endroid/screens/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/stream_provider.dart' as custom_stream_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => custom_stream_provider.StreamProvider(), // Use your custom StreamProvider
      child: MaterialApp(
        title: 'Endroid Streaming',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const LoginScreen(),
      ),
    );
  }
}
