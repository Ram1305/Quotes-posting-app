import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kavithaiquote/firebase_options.dart';
import 'package:kavithaiquote/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: splashscreen(), // Set SplashScreen as the initial screen
    );
  }
}
