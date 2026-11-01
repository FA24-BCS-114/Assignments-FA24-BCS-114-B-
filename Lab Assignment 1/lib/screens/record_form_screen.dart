import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../database/sqlite_manager.dart';
import '../models/person_record.dart';

class RecordFormScreen extends StatefulWidget {
  final PersonRecord? existingRecord;
  final bool prefillDemoNew;

  const RecordFormScreen({
    super.key,
    this.existingRecord,
    this.prefillDemoNew = false,
  });

  bool get isEditMode => existingRecord != null;

  @override
  State<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends State<RecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _ageController;

  String _gender = 'Male';
  String _roleTag = 'Lead Developer';
  String? _photoBase64;
  int _badgeColor = 0xFF059669;
  bool _submitting = false;

  final List<String> _roles = const [
    'Lead Developer',
    'Systems Analyst',
    'UI Architect',
    'Data Engineer',
    'CS Scholar',
  ];

  final List<int> _colors = const [
    0xFF059669,
    0xFFD97706,
    0xFF0284C7,
    0xFF7C3AED,
    0xFFE11D48,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      final r = widget.existingRecord!;
      _nameController = TextEditingController(text: r.fullName);
      _emailController = TextEditingController(text: r.email);
      _ageController = TextEditingController(text: '${r.age}');
      _gender = r.gender;
      _roleTag = _roles.contains(r.roleTag) ? r.roleTag : _roles.first;
      _photoBase64 = r.photoBase64;
      _badgeColor = r.badgeColor;
    } else if (widget.prefillDemoNew) {
      _nameController = TextEditingController(text: 'Hamza Tariq');
      _emailController = TextEditingController(text: 'hamza.tariq@cuivehari.edu.pk');
      _ageController = TextEditingController(text: '21');
      _gender = 'Male';
      _roleTag = 'Data Engineer';
      _badgeColor = 0xFF0284C7;
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _ageController = TextEditingController(text: '20');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 480,
      imageQuality: 82,
    );
    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      setState(() => _photoBase64 = base64Encode(bytes));
    }
  }

  void _stepAge(int delta) {
    final current = int.tryParse(_ageController.text) ?? 20;
    final next = (current + delta).clamp(12, 95);
    setState(() => _ageController.text = '$next');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final entry = PersonRecord(
      id: widget.existingRecord?.id,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      gender: _gender,
      roleTag: _roleTag,
      photoBase64: _photoBase64,
      badgeColor: _badgeColor,
    );

    if (widget.isEditMode) {
      await SqliteManager.instance.updateRecord(entry);
    } else {
      await SqliteManager.instance.addRecord(entry);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEditMode;
    final letter = _nameController.text.trim().isEmpty
        ? 'H'
        : _nameController.text.trim()[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          isEdit ? 'Modify & Update Entry' : 'Create New SQLite Entry',
          style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dark Obsidian Avatar Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _selectImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(_badgeColor),
                            backgroundImage: _photoBase64 != null
                                ? MemoryImage(base64Decode(_photoBase64!))
                                : null,
                            child: _photoBase64 == null
                                ? Text(
                                    letter,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0F172A),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_a_photo_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit
                                ? 'Editing Record ID #${widget.existingRecord!.id}'
                                : 'Profile Photo & Badge',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap avatar to upload image or pick an accent color below',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: _colors.map((c) {
                              final chosen = _badgeColor == c;
                              return GestureDetector(
                                onTap: () => setState(() => _badgeColor = c),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color(c),
                                    shape: BoxShape.circle,
                                    border: chosen
                                        ? Border.all(color: Colors.white, width: 2.5)
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Bento Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter valid email'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              prefixIcon: const Icon(Icons.timelapse_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) => int.tryParse(v ?? '') == null
                                ? 'Invalid age'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          onPressed: () => _stepAge(-1),
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filledTonal(
                          onPressed: () => _stepAge(1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _roleTag,
                      decoration: InputDecoration(
                        labelText: 'Role / Track',
                        prefixIcon: const Icon(Icons.work_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: _roles
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => _roleTag = v!),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Gender Selection',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'Male',
                          label: Text('Male'),
                          icon: Icon(Icons.male_rounded, size: 18),
                        ),
                        ButtonSegment(
                          value: 'Female',
                          label: Text('Female'),
                          icon: Icon(Icons.female_rounded, size: 18),
                        ),
                      ],
                      selected: {_gender},
                      onSelectionChanged: (s) => setState(() => _gender = s.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Submit Action Button (Add or Update)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isEdit ? const Color(0xFFD97706) : const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _submitting ? null : _submitForm,
                  icon: Icon(
                    isEdit ? Icons.save_as_rounded : Icons.add_circle_outline_rounded,
                  ),
                  label: Text(
                    isEdit ? 'Update Entry in SQLite' : 'Add Entry to SQLite',
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
