import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/emr_sqlite_store.dart';
import '../models/emr_models.dart';

class EmrPatientEditorView extends StatefulWidget {
  final EmrPatient? existing;
  final bool prefillSample;

  const EmrPatientEditorView({
    super.key,
    this.existing,
    this.prefillSample = false,
  });

  bool get isUpdate => existing != null;

  @override
  State<EmrPatientEditorView> createState() => _EmrPatientEditorViewState();
}

class _EmrPatientEditorViewState extends State<EmrPatientEditorView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameInput;
  late final TextEditingController _ageInput;
  late final TextEditingController _phoneInput;
  late final TextEditingController _conditionInput;
  late final TextEditingController _vitalsInput;
  late final TextEditingController _summaryInput;

  String _gender = 'Male';
  String _bloodType = 'O+';
  String _priority = 'Routine';
  String? _photoBase64;
  bool _busy = false;

  final List<String> _bloodTypes = const [
    'O+',
    'O-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
  ];
  final List<String> _priorities = const ['Routine', 'Observation', 'Urgent'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final p = widget.existing!;
      _nameInput = TextEditingController(text: p.fullName);
      _ageInput = TextEditingController(text: '${p.age}');
      _phoneInput = TextEditingController(text: p.phone);
      _conditionInput = TextEditingController(text: p.condition);
      _vitalsInput = TextEditingController(text: p.vitals);
      _summaryInput = TextEditingController(text: p.clinicalSummary);
      _gender = p.gender;
      _bloodType = p.bloodType;
      _priority = p.priority;
      _photoBase64 = p.photoBase64;
    } else if (widget.prefillSample) {
      _nameInput = TextEditingController(text: 'Dr. Adeel Qureshi (Pt)');
      _ageInput = TextEditingController(text: '39');
      _phoneInput = TextEditingController(text: '+92 322 4901182');
      _conditionInput = TextEditingController(text: 'Acute Bronchospasm');
      _vitalsInput =
          TextEditingController(text: 'BP 132/84 • HR 86 • SpO2 95%');
      _summaryInput = TextEditingController(
        text: 'Nebulization administered. Chest X-ray & spirometry report queued.',
      );
      _gender = 'Male';
      _bloodType = 'B+';
      _priority = 'Observation';
    } else {
      _nameInput = TextEditingController();
      _ageInput = TextEditingController();
      _phoneInput = TextEditingController();
      _conditionInput = TextEditingController();
      _vitalsInput =
          TextEditingController(text: 'BP 120/80 • HR 74 • SpO2 98%');
      _summaryInput = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameInput.dispose();
    _ageInput.dispose();
    _phoneInput.dispose();
    _conditionInput.dispose();
    _vitalsInput.dispose();
    _summaryInput.dispose();
    super.dispose();
  }

  Future<void> _chooseAvatar() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 480,
      imageQuality: 80,
    );
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() => _photoBase64 = base64Encode(bytes));
    }
  }

  Future<void> _saveChart() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    final entry = EmrPatient(
      id: widget.existing?.id,
      mrnCode: widget.existing?.mrnCode ??
          'MRN-${2604 + DateTime.now().second}',
      fullName: _nameInput.text.trim(),
      age: int.parse(_ageInput.text.trim()),
      gender: _gender,
      bloodType: _bloodType,
      phone: _phoneInput.text.trim(),
      condition: _conditionInput.text.trim(),
      priority: _priority,
      vitals: _vitalsInput.text.trim(),
      clinicalSummary: _summaryInput.text.trim(),
      photoBase64: _photoBase64,
    );

    if (widget.isUpdate) {
      await EmrSqliteStore.instance.updatePatient(entry);
    } else {
      await EmrSqliteStore.instance.createPatient(entry);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.isUpdate;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          isUpdate ? 'Update EMR Patient Chart' : 'Admit / Register Patient',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Navy Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _chooseAvatar,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF4F46E5),
                        backgroundImage: _photoBase64 != null
                            ? MemoryImage(base64Decode(_photoBase64!))
                            : null,
                        child: _photoBase64 == null
                            ? const Icon(
                                Icons.camera_enhance_rounded,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUpdate
                                ? 'Chart Code: ${widget.existing!.mrnCode}'
                                : 'Electronic Medical Record Intake',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Tap camera badge to attach patient ID snapshot',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameInput,
                      decoration: InputDecoration(
                        labelText: 'Patient Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageInput,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (v) => int.tryParse(v ?? '') == null
                                ? 'Invalid'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _bloodType,
                            decoration: InputDecoration(
                              labelText: 'Blood Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            items: _bloodTypes
                                .map((b) =>
                                    DropdownMenuItem(value: b, child: Text(b)))
                                .toList(),
                            onChanged: (v) => setState(() => _bloodType = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: InputDecoration(
                              labelText: 'Sex',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            items: const ['Male', 'Female']
                                .map((g) =>
                                    DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setState(() => _gender = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _priority,
                            decoration: InputDecoration(
                              labelText: 'Clinical Priority',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            items: _priorities
                                .map((p) =>
                                    DropdownMenuItem(value: p, child: Text(p)))
                                .toList(),
                            onChanged: (v) => setState(() => _priority = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneInput,
                      decoration: InputDecoration(
                        labelText: 'Emergency Contact',
                        prefixIcon: const Icon(Icons.call_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _conditionInput,
                      decoration: InputDecoration(
                        labelText: 'Primary Condition / Diagnosis',
                        prefixIcon: const Icon(Icons.local_hospital_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vitalsInput,
                      decoration: InputDecoration(
                        labelText: 'Recorded Vitals (BP • HR • SpO2)',
                        prefixIcon: const Icon(Icons.monitor_heart_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _summaryInput,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Physician Clinical Assessment',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUpdate
                        ? const Color(0xFF10B981)
                        : const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _busy ? null : _saveChart,
                  icon: Icon(
                    isUpdate ? Icons.save_rounded : Icons.how_to_reg_rounded,
                  ),
                  label: Text(
                    isUpdate
                        ? 'Commit Chart Updates to SQLite'
                        : 'Admit Patient to EMR Database',
                    style: const TextStyle(
                      fontSize: 15,
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
