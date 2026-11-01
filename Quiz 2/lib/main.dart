import 'package:flutter/material.dart';
import 'views/emr_directory_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DocPulseEmrApp());
}

class DocPulseEmrApp extends StatelessWidget {
  const DocPulseEmrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocPulse EMR Suite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const EmrDirectoryView(),
    );
  }
}
