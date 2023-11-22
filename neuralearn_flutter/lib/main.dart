import 'package:flutter/material.dart';
import 'package:neuralearn_flutter/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      title: 'NeuraLearn',
      home: MainScreen(),
    );
  }
}
