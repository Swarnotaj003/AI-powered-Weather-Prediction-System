import 'package:ai_weather_app/screens/my_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Ensure that .env file is loaded
  await dotenv.load();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI-powered Weather Prediction App',
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}
