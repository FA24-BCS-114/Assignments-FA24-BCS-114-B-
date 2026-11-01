import 'package:flutter/material.dart';
import 'digital_pass_screen.dart';

void main() {
  runApp(const HarryCampusPassApp());
}

class HarryCampusPassApp extends StatelessWidget {
  const HarryCampusPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Campus Pass - FA24-BCS-114',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const DigitalPassScreen(),
    );
  }
}
