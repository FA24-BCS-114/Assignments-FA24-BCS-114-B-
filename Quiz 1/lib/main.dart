import 'package:flutter/material.dart';

void main() {
  runApp(const HarryWidgetsQuizApp());
}

class HarryWidgetsQuizApp extends StatelessWidget {
  final int previewMode;

  const HarryWidgetsQuizApp({super.key, this.previewMode = 0});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz 1 - Basic Flutter Widgets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3730A3),
          brightness: Brightness.light,
        ),
      ),
      home: StudentBasicFormPage(previewMode: previewMode),
    );
  }
}

class StudentBasicFormPage extends StatefulWidget {
  final int previewMode;

  const StudentBasicFormPage({super.key, this.previewMode = 0});

  @override
  State<StudentBasicFormPage> createState() => _StudentBasicFormPageState();
}

class _StudentBasicFormPageState extends State<StudentBasicFormPage> {
  final TextEditingController _studentNameInput = TextEditingController();
  final TextEditingController _regNumberInput = TextEditingController();

  String _genderValue = 'Male';
  bool _readingChecked = false;
  bool _sportsChecked = false;

  // 6. Option List (2-3 options)
  final List<String> _programModes = ['Regular', 'Self-Support', 'Scholarship'];
  String _chosenMode = 'Regular';

  // 7. Selection List (2-3 selectable items)
  final List<String> _labTracks = ['Flutter Lab', 'SQLite Track', 'REST APIs'];
  final Set<String> _pickedTracks = {};

  // 8. Dropdown List (CS/IT/SE/AI)
  final List<String> _deptChoices = ['CS', 'IT', 'SE', 'AI'];
  String _chosenDept = 'CS';

  String? _outputRecord;

  @override
  void initState() {
    super.initState();
    if (widget.previewMode >= 1) {
      _studentNameInput.text = 'Harry';
      _regNumberInput.text = 'FA24-BCS-114';
      _genderValue = 'Male';
      _readingChecked = true;
      _sportsChecked = true;
      _chosenMode = 'Regular';
      _pickedTracks.addAll(['Flutter Lab', 'SQLite Track']);
      _chosenDept = 'CS';
    }
    if (widget.previewMode == 2) {
      _handleSubmit();
    }
  }

  @override
  void dispose() {
    _studentNameInput.dispose();
    _regNumberInput.dispose();
    super.dispose();
  }

  void _handleClear() {
    setState(() {
      _studentNameInput.clear();
      _regNumberInput.clear();
      _genderValue = 'Male';
      _readingChecked = false;
      _sportsChecked = false;
      _chosenMode = 'Regular';
      _pickedTracks.clear();
      _chosenDept = 'CS';
      _outputRecord = null;
    });
  }

  void _handleSubmit() {
    final sName = _studentNameInput.text.trim().isEmpty
        ? 'Unnamed'
        : _studentNameInput.text.trim();
    final sReg = _regNumberInput.text.trim().isEmpty
        ? 'Unassigned'
        : _regNumberInput.text.trim();
    final hobbyItems = <String>[
      if (_readingChecked) 'Reading',
      if (_sportsChecked) 'Sports',
    ];
    final hobbyText = hobbyItems.isEmpty ? 'None' : hobbyItems.join(' & ');
    final trackText =
        _pickedTracks.isEmpty ? 'None' : _pickedTracks.join(', ');

    setState(() {
      _outputRecord =
          'Student: $sName ($sReg)\n'
          'Gender: $_genderValue | Department: $_chosenDept\n'
          'Hobbies: $hobbyText | Mode: $_chosenMode\n'
          'Lab Selection: $trackText';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF312E81),
        foregroundColor: Colors.white,
        title: const Text(
          'Quiz 1: Basic Flutter UI Widgets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Heading Text
                const Text(
                  'Student Registration Form',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF312E81),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'COMSATS Student Portal - Basic Widgets Demo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                // 2. TextField - Student Name
                TextField(
                  controller: _studentNameInput,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    hintText: 'Enter Student Name (e.g. Harry)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),

                // 3. TextField - Registration Number
                TextField(
                  controller: _regNumberInput,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number',
                    hintText: 'Enter Reg No (e.g. FA24-BCS-114)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),

                // 4. Radio Button - Gender
                const Text(
                  'Gender (Radio Button)',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: 'Male',
                      groupValue: _genderValue,
                      onChanged: (v) => setState(() => _genderValue = v!),
                    ),
                    const Text('Male'),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'Female',
                      groupValue: _genderValue,
                      onChanged: (v) => setState(() => _genderValue = v!),
                    ),
                    const Text('Female'),
                  ],
                ),

                // 5. Checkbox - Hobbies
                const Text(
                  'Hobbies (Checkbox)',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _readingChecked,
                      onChanged: (v) =>
                          setState(() => _readingChecked = v ?? false),
                    ),
                    const Text('Reading'),
                    const SizedBox(width: 20),
                    Checkbox(
                      value: _sportsChecked,
                      onChanged: (v) =>
                          setState(() => _sportsChecked = v ?? false),
                    ),
                    const Text('Sports'),
                  ],
                ),
                const SizedBox(height: 8),

                // 6. Option List (2-3 options)
                const Text(
                  'Admission Category (Option List)',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _programModes.map((mode) {
                    final active = _chosenMode == mode;
                    return GestureDetector(
                      onTap: () => setState(() => _chosenMode = mode),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              active
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 18,
                              color: active
                                  ? const Color(0xFF3730A3)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(mode, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // 7. Selection List (2-3 selectable items)
                const Text(
                  'Practical Labs (Selection List)',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: _labTracks.map((track) {
                    final picked = _pickedTracks.contains(track);
                    return FilterChip(
                      label: Text(track, style: const TextStyle(fontSize: 12)),
                      selected: picked,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _pickedTracks.add(track);
                          } else {
                            _pickedTracks.remove(track);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // 8. Dropdown List (CS/IT/SE/AI)
                const Text(
                  'Department (Dropdown List)',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                DropdownButton<String>(
                  value: _chosenDept,
                  alignment: Alignment.center,
                  items: _deptChoices.map((d) {
                    return DropdownMenuItem<String>(
                      value: d,
                      alignment: Alignment.center,
                      child: Text('$d Department'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _chosenDept = v);
                  },
                ),
                const SizedBox(height: 14),

                // 9. Simple Button + 10. Submit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3730A3)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: _handleClear,
                      child: const Text('Clear Fields'),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF312E81),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onPressed: _handleSubmit,
                      child: const Text('Submit Form'),
                    ),
                  ],
                ),

                if (_outputRecord != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      border: Border.all(color: const Color(0xFF6366F1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _outputRecord!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
