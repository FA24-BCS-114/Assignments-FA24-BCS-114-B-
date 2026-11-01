import 'package:flutter/material.dart';
import 'screens/roster_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PulseRosterApp());
}

class PulseRosterApp extends StatelessWidget {
  const PulseRosterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulseRoster SQLite CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF059669),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const RosterScreen(),
    );
  }
}
