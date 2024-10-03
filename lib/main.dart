import 'package:detect_gpt/screen/homescreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Detect GPT',
      home: Homescreen(),
      debugShowCheckedModeBanner: false,
    );
  }
  
}