import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/pdf_doc_model.dart';
import '../providers/nexus_providers.dart';
import '../services/export_share_service.dart';
import '../services/pdf_engine_service.dart';
import '../utils/format_helpers.dart';

class PdfToImageScreen114 extends ConsumerStatefulWidget {
  final PdfDocModel114? initialDocument;

  const PdfToImageScreen114({super.key, this.initialDocument});

  @override
  ConsumerState<PdfToImageScreen114> createState() =>
      _PdfToImageScreen114State();
}

class _PdfToImageScreen114State extends ConsumerState<PdfToImageScreen114> {
  String? _selectedDocId;
  String _outputFormat = 'PNG'; // 'PNG' or 'JPG'
  bool _convertAllPages = true;
  final Set<int> _selectedPages = {1};
  bool _isConverting = false;
  List<ConvertedPageImage114> _renderedImages = [];

  @override
  void initState() {
    super.initState();
    final docs = ref.read(nexusWorkspaceProvider).documents;
    _selectedDocId = widget.initialDocument?.id ??
        (docs.isNotEmpty ? docs.first.id : null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedDocId != null) {
        _runConversion();
      }
    });
  }

  PdfDocModel114? _resolveSelectedDoc(List<PdfDocModel114> docs) {
    for (final d in docs) {
      if (d.id == _selectedDocId) return d;
    }
    return docs.isNotEmpty ? docs.first : null;
  }

  Future<void> _runConversion() async {
    final docs = ref.read(nexusWorkspaceProvider).documents;
    final doc = _resolveSelectedDoc(docs);
    if (doc == null || _isConverting) return;

    setState(() => _isConverting = true);
    try {
      final rawBytes = await PdfEngineService114.resolveDocumentBytes(doc);
      final pages = _convertAllPages
          ? List<int>.generate(doc.pageCount, (i) => i + 1)
          : (_selectedPages.toList()..sort());

      final converted = await PdfEngineService114.convertPdfPagesToImages(
        pdfBytes: rawBytes,
        pageNumbers: pages.isEmpty ? [1] : pages,
        format: _outputFormat,
      );
      if (!mounted) return;
      setState(() => _renderedImages = converted);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conversion error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = ref.watch(nexusWorkspaceProvider).documents;
    final activeDoc = _resolveSelectedDoc(docs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF-to-Image Converter (PNG / JPG)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants114.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppConstants114.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: activeDoc?.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Source PDF Document',
                      prefixIcon: Icon(Icons.picture_as_pdf_rounded),
                    ),
                    items: docs
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(
                              '${d.title} (${d.pageCount}p)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _selectedDocId = val;
                        _selectedPages
                          ..clear()
                          ..add(1);
                        _renderedImages = [];
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Image Format:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ChoiceChip(
                        label: const Text('PNG (Lossless)'),
                        selected: _outputFormat == 'PNG',
                        onSelected: (_) => setState(() => _outputFormat = 'PNG'),
                      ),
                      ChoiceChip(
                        label: const Text('JPG (Compact)'),
                        selected: _outputFormat == 'JPG',
                        onSelected: (_) => setState(() => _outputFormat = 'JPG'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Convert Entire Document',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      activeDoc == null
                          ? ''
                          : 'Renders all ${activeDoc.pageCount} pages at high DPI',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _convertAllPages,
                    activeColor: AppConstants114.accentCyan,
                    onChanged: (v) => setState(() => _convertAllPages = v),
                  ),
                  if (!_convertAllPages && activeDoc != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(activeDoc.pageCount, (idx) {
                        final p = idx + 1;
                        final sel = _selectedPages.contains(p);
                        return FilterChip(
                          label: Text('P.$p'),
                          selected: sel,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _selectedPages.add(p);
                              } else if (_selectedPages.length > 1) {
                                _selectedPages.remove(p);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isConverting ? null : _runConversion,
                      icon: _isConverting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.collections_rounded, size: 18),
                      label: Text(
                        _isConverting
                            ? 'Rasterizing Pages...'
                            : 'Render $_outputFormat Images',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_renderedImages.isNotEmpty) ...[
              Text(
                'Rendered Output (${_renderedImages.length} $_outputFormat Image(s))',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.66,
                ),
                itemCount: _renderedImages.length,
                itemBuilder: (_, idx) {
                  final item = _renderedImages[idx];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppConstants114.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppConstants114.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                item.bytes,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Page ${item.pageNumber} • ${item.format}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                        Text(
                          '${item.width}×${item.height} • ${FormatHelpers114.formatBytes(item.bytes.length)}',
                          style: const TextStyle(
                            color: AppConstants114.textSoftGrey,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final ext = item.format.toLowerCase();
                              final mime =
                                  ext == 'jpg' ? 'image/jpeg' : 'image/png';
                              ExportShareService114.shareBinaryFile(
                                bytes: item.bytes,
                                fileName:
                                    'page_${item.pageNumber}_114.$ext',
                                mimeType: mime,
                              );
                            },
                            icon: const Icon(Icons.share_rounded, size: 15),
                            label: const Text(
                              'Share / Save',
                              style: TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
