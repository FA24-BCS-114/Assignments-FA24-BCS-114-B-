import 'package:flutter/material.dart';
import 'student_card_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harry Student Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)), // Slightly different darker blue
        useMaterial3: true,
      ),
      home: const StudentCardScreen(),
    );
  }
}
