import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/emr_sqlite_store.dart';
import '../models/emr_models.dart';
import 'emr_patient_editor_view.dart';

class EmrChartVaultView extends StatefulWidget {
  final EmrPatient patient;

  const EmrChartVaultView({super.key, required this.patient});

  @override
  State<EmrChartVaultView> createState() => _EmrChartVaultViewState();
}

class _EmrChartVaultViewState extends State<EmrChartVaultView> {
  late EmrPatient _patient;
  List<EmrDocument> _docs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
    _fetchDocs();
  }

  Future<void> _fetchDocs() async {
    final rows =
        await EmrSqliteStore.instance.fetchPatientDocs(_patient.id ?? 1);
    if (!mounted) return;
    setState(() {
      _docs = rows;
      _loading = false;
    });
  }

  Future<void> _attachMedicalScan() async {
    final picker = ImagePicker();
    final scan = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      imageQuality: 85,
    );
    if (scan == null) return;
    final bytes = await scan.readAsBytes();
    final kb = (bytes.length / 1024).toStringAsFixed(0);

    await EmrSqliteStore.instance.attachDocument(
      EmrDocument(
        patientId: _patient.id ?? 1,
        title: scan.name,
        docFormat: 'IMG',
        tag: 'Radiology',
        fileSize: '$kb KB',
        dateAdded: 'Just now',
        encodedBytes: base64Encode(bytes),
      ),
    );
    await _fetchDocs();
  }

  Future<void> _attachClinicalPdf() async {
    final picked = await FilePicker.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );
    if (picked == null || picked.files.isEmpty) return;
    final f = picked.files.first;
    final isImg =
        ['png', 'jpg', 'jpeg'].contains((f.extension ?? '').toLowerCase());
    final kb = (f.size / 1024).toStringAsFixed(0);

    await EmrSqliteStore.instance.attachDocument(
      EmrDocument(
        patientId: _patient.id ?? 1,
        title: f.name,
        docFormat: isImg ? 'IMG' : 'PDF/DOC',
        tag: isImg ? 'Radiology' : 'Pathology',
        fileSize: '$kb KB',
        dateAdded: 'Just now',
        encodedBytes: f.bytes != null ? base64Encode(f.bytes!) : null,
      ),
    );
    await _fetchDocs();
  }

  Future<void> _deleteDoc(EmrDocument doc) async {
    if (doc.id == null) return;
    await EmrSqliteStore.instance.deleteDocument(doc.id!);
    await _fetchDocs();
  }

  Future<void> _editChart() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EmrPatientEditorView(existing: _patient),
      ),
    );
    if (changed == true) {
      final all = await EmrSqliteStore.instance.fetchPatients();
      final latest = all.firstWhere(
        (e) => e.id == _patient.id,
        orElse: () => _patient,
      );
      setState(() => _patient = latest);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          'EMR Chart • ${_patient.mrnCode}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          IconButton(
            onPressed: _editChart,
            icon: const Icon(Icons.edit_note_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Navy EMR Summary Block
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: const Color(0xFF4F46E5),
                        child: Text(
                          _patient.fullName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _patient.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_patient.mrnCode} • ${_patient.age}y ${_patient.gender} • Blood ${_patient.bloodType}',
                              style: const TextStyle(
                                color: Color(0xFFA5B4FC),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.monitor_heart_rounded,
                          color: Color(0xFF34D399),
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _patient.vitals,
                            style: const TextStyle(
                              color: Color(0xFFD1FAE5),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Condition: ${_patient.condition}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _patient.clinicalSummary,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Simulated Radiology Imaging Slice Viewer
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: CustomPaint(painter: _ScanCrosshairPainter()),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Digital Medical File & Scan Vault',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Upload patient radiology images, prescriptions, and PDF lab reports directly to local SQLite.',
                          style: TextStyle(
                            fontSize: 11.8,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Upload Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _attachClinicalPdf,
                    icon: const Icon(Icons.attach_file_rounded, size: 18),
                    label: const Text(
                      'Attach PDF/Doc',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _attachMedicalScan,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text(
                      'Upload Scan Image',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Stored Clinical Files (${_docs.length})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ..._docs.map(_buildDocCard),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(EmrDocument doc) {
    final isImg = doc.docFormat == 'IMG';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isImg ? const Color(0xFFECFDF5) : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              image: (doc.encodedBytes != null && isImg)
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(doc.encodedBytes!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (doc.encodedBytes == null || !isImg)
                ? Icon(
                    isImg ? Icons.image_search_rounded : Icons.description_outlined,
                    color: isImg
                        ? const Color(0xFF059669)
                        : const Color(0xFF4F46E5),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${doc.tag} • ${doc.docFormat} • ${doc.fileSize} • ${doc.dateAdded}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteDoc(doc),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFE11D48),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanCrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final ring = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(c, 22, ring);
    canvas.drawCircle(c, 12, ring..color = const Color(0xFF34D399));
    final axis = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(Offset(c.dx, 8), Offset(c.dx, size.height - 8), axis);
    canvas.drawLine(Offset(8, c.dy), Offset(size.width - 8, c.dy), axis);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
