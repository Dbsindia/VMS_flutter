import 'package:endroid/screens/loginscreen.dart';
import 'package:endroid/utils/google_play_services_util.dart';
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
      create: (_) => custom_stream_provider
          .StreamProvider(), // Use your custom StreamProvider
      child: const MyAppRoot(),
    );
  }
}

class MyAppRoot extends StatefulWidget {
  const MyAppRoot({super.key});

  @override
  State<MyAppRoot> createState() => _MyAppRootState();
}

class _MyAppRootState extends State<MyAppRoot> {
  @override
  void initState() {
    super.initState();
    _checkGooglePlayServices();
  }

  Future<void> _checkGooglePlayServices() async {
    await ensureGooglePlayServices(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Endroid Streaming',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const LoginScreen(),
    );
  }
}
