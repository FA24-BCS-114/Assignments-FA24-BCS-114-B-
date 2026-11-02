import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_constants.dart';
import '../providers/nexus_providers.dart';
import '../services/reminder_notification_service.dart';
import '../services/sample_pdf_factory.dart';
import '../widgets/doc_dialogs_114.dart';

class CyberScannerScreen114 extends ConsumerStatefulWidget {
  const CyberScannerScreen114({super.key});

  @override
  ConsumerState<CyberScannerScreen114> createState() =>
      _CyberScannerScreen114State();
}

class _CyberScannerScreen114State extends ConsumerState<CyberScannerScreen114> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleCtrl = TextEditingController(
    text: 'CyberScan Lecture Notes 114',
  );

  final List<Uint8List> _rawCapturedPages = [];
  int _selectedIndex = 0;
  ScanFilter114 _filter = ScanFilter114.magicContrast;
  ScanCropPreset114 _crop = ScanCropPreset114.a4Portrait;
  int _quarterTurns = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-stage one realistic camera scan page so users can immediately preview filters & save
    _rawCapturedPages.add(
      SamplePdfFactory114.generateSampleScannedPageImage(pageIndex: 1),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureFromSource(ImageSource source) async {
    if (source == ImageSource.camera) {
      await ReminderNotificationService114.ensureCameraPermission();
    }
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 92);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _rawCapturedPages.add(bytes);
        _selectedIndex = _rawCapturedPages.length - 1;
      });
    } catch (e) {
      // Fallback to synthetic camera sheet when hardware camera is absent (e.g. desktop/headless)
      if (!mounted) return;
      setState(() {
        _rawCapturedPages.add(
          SamplePdfFactory114.generateSampleScannedPageImage(
            pageIndex: _rawCapturedPages.length + 1,
          ),
        );
        _selectedIndex = _rawCapturedPages.length - 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hardware camera unavailable — captured test sheet.'),
        ),
      );
    }
  }

  void _addSyntheticSheet() {
    setState(() {
      _rawCapturedPages.add(
        SamplePdfFactory114.generateSampleScannedPageImage(
          pageIndex: _rawCapturedPages.length + 1,
        ),
      );
      _selectedIndex = _rawCapturedPages.length - 1;
    });
  }

  Uint8List _renderActivePreview() {
    if (_rawCapturedPages.isEmpty) return Uint8List(0);
    final raw = _rawCapturedPages[_selectedIndex.clamp(0, _rawCapturedPages.length - 1)];
    return SamplePdfFactory114.processScannedImage(
      raw,
      filter: _filter,
      crop: _crop,
      quarterTurns: _quarterTurns,
    );
  }

  Future<void> _compileAndSavePdf() async {
    if (_rawCapturedPages.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final processed = _rawCapturedPages
          .map(
            (raw) => SamplePdfFactory114.processScannedImage(
              raw,
              filter: _filter,
              crop: _crop,
              quarterTurns: _quarterTurns,
            ),
          )
          .toList();

      final savedDoc =
          await ref.read(nexusWorkspaceProvider.notifier).saveScannedPdf(
                title: _titleCtrl.text.trim().isEmpty
                    ? 'CyberScan Document'
                    : _titleCtrl.text.trim(),
                pages: processed,
              );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved "${savedDoc.title}" (${processed.length} pages) into SQLite Library!',
          ),
        ),
      );
      Navigator.of(context).pop();
      DocDialogs114.openReader(context, savedDoc);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan export error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewBytes = _renderActivePreview();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CyberScan 114 • Document Scanner'),
        actions: [
          IconButton(
            tooltip: 'Rotate 90°',
            onPressed: () => setState(() => _quarterTurns = (_quarterTurns + 1) % 4),
            icon: const Icon(Icons.rotate_right_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Output PDF Title',
                prefixIcon: Icon(Icons.picture_as_pdf_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => _captureFromSource(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Camera Scan'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _captureFromSource(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Import Photo'),
                ),
                OutlinedButton.icon(
                  onPressed: _addSyntheticSheet,
                  icon: const Icon(Icons.note_add_outlined, size: 18),
                  label: const Text('Add Sample Sheet'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 310,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants114.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppConstants114.borderSubtle),
              ),
              child: previewBytes.isEmpty
                  ? const Center(child: Text('No pages captured yet'))
                  : Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              previewBytes,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Page ${_selectedIndex + 1} of ${_rawCapturedPages.length} • Filter: ${_filter.name.toUpperCase()}',
                          style: const TextStyle(
                            color: AppConstants114.accentCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
            if (_rawCapturedPages.length > 1) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _rawCapturedPages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, idx) => ChoiceChip(
                    label: Text('Page ${idx + 1}'),
                    selected: idx == _selectedIndex,
                    onSelected: (_) => setState(() => _selectedIndex = idx),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Crop Framing Preset',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _cropChip(ScanCropPreset114.fullPage, 'Full Sensor'),
                _cropChip(ScanCropPreset114.a4Portrait, 'A4 Auto-Trim'),
                _cropChip(ScanCropPreset114.receiptStrip, 'Receipt Strip'),
                _cropChip(ScanCropPreset114.idCard, 'ID / Card'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Document Enhancement Filter',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip(ScanFilter114.original, 'Original'),
                _filterChip(ScanFilter114.magicContrast, 'Magic Contrast'),
                _filterChip(ScanFilter114.grayscale, 'Grayscale'),
                _filterChip(ScanFilter114.crispBw, 'Crisp B&W'),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: AppConstants114.secondaryBlue,
                ),
                onPressed: _isSaving ? null : _compileAndSavePdf,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt_rounded),
                label: Text(
                  _isSaving
                      ? 'Synthesizing Multi-Page PDF...'
                      : 'Compile ${_rawCapturedPages.length} Page(s) & Save PDF',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cropChip(ScanCropPreset114 preset, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _crop == preset,
      onSelected: (_) => setState(() => _crop = preset),
    );
  }

  Widget _filterChip(ScanFilter114 filter, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == filter,
      onSelected: (_) => setState(() => _filter = filter),
    );
  }
}
