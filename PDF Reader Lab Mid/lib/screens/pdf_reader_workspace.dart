import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../constants/app_constants.dart';
import '../models/pdf_doc_model.dart';
import '../models/reader_aux_models.dart';
import '../providers/nexus_providers.dart';
import '../services/export_share_service.dart';
import '../services/pdf_engine_service.dart';
import '../widgets/annotation_canvas_overlay.dart';

class PdfReaderWorkspace114 extends ConsumerStatefulWidget {
  final PdfDocModel114 doc;
  final int? initialPageOverride;
  final bool openAnnotationToolbarInitially;
  final String? initialSearchQuery;

  const PdfReaderWorkspace114({
    super.key,
    required this.doc,
    this.initialPageOverride,
    this.openAnnotationToolbarInitially = false,
    this.initialSearchQuery,
  });

  @override
  ConsumerState<PdfReaderWorkspace114> createState() =>
      _PdfReaderWorkspace114State();
}

class _PdfReaderWorkspace114State
    extends ConsumerState<PdfReaderWorkspace114> {
  final PdfViewerController _viewerController = PdfViewerController();
  late final PdfTextSearcher _textSearcher =
      PdfTextSearcher(_viewerController)..addListener(_onSearcherChanged);
  final TextEditingController _searchInputCtrl = TextEditingController();

  late PdfDocModel114 _currentDoc;
  Uint8List? _pdfBytes;
  String? _loadError;
  bool _hasExtractableText = true;

  int _currentPage = 1;
  int _totalPages = 1;
  double _currentZoom = 1.0;

  bool _fullScreenHudHidden = false;
  bool _showSearchBar = false;
  bool _showAnnotationStudio = false;
  bool _horizontalLayout = false;

  String _readingTone = 'dark'; // 'dark', 'paper', 'sepia', 'midnight'
  double _brightnessDimmer = 0.0;

  AnnotationKind114? _activeTool;
  bool _eraserActive = false;
  int _activeColorHex = AppConstants114.annotationPalette.first;
  List<AnnotationItem114> _annotations = [];

  @override
  void initState() {
    super.initState();
    _currentDoc = widget.doc;
    _currentPage = widget.initialPageOverride ?? widget.doc.lastReadPage;
    _totalPages = max(1, widget.doc.pageCount);
    _showAnnotationStudio = widget.openAnnotationToolbarInitially;
    if (widget.openAnnotationToolbarInitially) {
      _activeTool = AnnotationKind114.highlight;
    }

    final settings = ref.read(nexusWorkspaceProvider).settings;
    _readingTone = settings.defaultReadingTone;
    _brightnessDimmer = settings.brightnessOverlay;
    _horizontalLayout = settings.scrollDirection == 'horizontal';

    _viewerController.addListener(_onControllerUpdated);
    _loadDocumentAndAnnotations();
  }

  void _onSearcherChanged() {
    if (mounted) setState(() {});
  }

  void _onControllerUpdated() {
    if (!mounted || !_viewerController.isReady) return;
    final z = _viewerController.currentZoom;
    if ((z - _currentZoom).abs() > 0.02) {
      setState(() => _currentZoom = z);
    }
  }

  Future<void> _loadDocumentAndAnnotations() async {
    try {
      final raw = await PdfEngineService114.resolveDocumentBytes(_currentDoc);
      final inspection = PdfEngineService114.inspectAndValidatePdf(raw);
      final anns = await ref
          .read(documentRepository114Provider)
          .getAnnotationsForDoc(_currentDoc.id);

      if (!mounted) return;
      setState(() {
        _pdfBytes = raw;
        _totalPages = inspection.pageCount;
        _hasExtractableText = inspection.hasExtractableText;
        _annotations = anns;
      });

      if (widget.initialSearchQuery != null &&
          widget.initialSearchQuery!.trim().isNotEmpty) {
        setState(() => _showSearchBar = true);
        _searchInputCtrl.text = widget.initialSearchQuery!;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString());
    }
  }

  @override
  void dispose() {
    _textSearcher.removeListener(_onSearcherChanged);
    _textSearcher.dispose();
    _viewerController.removeListener(_onControllerUpdated);
    _searchInputCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _persistPage(int pageNumber) async {
    if (pageNumber < 1) return;
    setState(() => _currentPage = pageNumber);
    _currentDoc = await ref
        .read(nexusWorkspaceProvider.notifier)
        .updateReadingProgress(_currentDoc, pageNumber);
  }

  void _toggleFullScreen() {
    setState(() => _fullScreenHudHidden = !_fullScreenHudHidden);
    if (_fullScreenHudHidden) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _jumpToPageDialog() async {
    final ctrl = TextEditingController(text: '$_currentPage');
    final target = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jump to Page'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Enter page (1 - $_totalPages)',
            prefixIcon: const Icon(Icons.find_in_page_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(ctrl.text.trim());
              Navigator.pop(ctx, parsed);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
    if (target != null && _viewerController.isReady) {
      final safePage = target.clamp(1, _totalPages);
      await _viewerController.goToPage(pageNumber: safePage);
      await _persistPage(safePage);
    }
  }

  Future<void> _bookmarkCurrentPageDialog() async {
    final labelCtrl =
        TextEditingController(text: 'Page $_currentPage Key Concept');
    final noteCtrl = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bookmark Page $_currentPage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Bookmark Title',
                prefixIcon: Icon(Icons.bookmark_add_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Optional Study Note',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save Bookmark'),
          ),
        ],
      ),
    );

    if (saved == true) {
      await ref.read(nexusWorkspaceProvider.notifier).addPageBookmark(
            doc: _currentDoc,
            pageNumber: _currentPage,
            label: labelCtrl.text,
            note: noteCtrl.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bookmarked Page $_currentPage in SQLite.')),
        );
      }
    }
  }

  void _openThumbnailsSheet() {
    if (_pdfBytes == null) return;
    final copyBytes = Uint8List.fromList(_pdfBytes!);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppConstants114.primaryNavy,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.62,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.grid_view_rounded,
                    color: AppConstants114.accentCyan,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Page Thumbnails ($_totalPages Pages)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PdfDocumentViewBuilder(
                documentRef: PdfDocumentRefData(
                  copyBytes,
                  sourceName: '${_currentDoc.id}_thumbs',
                ),
                builder: (context, document) {
                  if (document == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 155,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: document.pages.length,
                    itemBuilder: (context, idx) {
                      final pNum = idx + 1;
                      final active = pNum == _currentPage;
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          if (_viewerController.isReady) {
                            await _viewerController.goToPage(pageNumber: pNum);
                            await _persistPage(pNum);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppConstants114.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active
                                  ? AppConstants114.accentCyan
                                  : AppConstants114.borderSubtle,
                              width: active ? 2 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: PdfPageView(
                                    document: document,
                                    pageNumber: pNum,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Page $pNum',
                                style: TextStyle(
                                  color: active
                                      ? AppConstants114.accentCyan
                                      : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReadingCustomizationSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppConstants114.primaryNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Reading Customization & Display Controls',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Page Tone / Filter',
                  style: TextStyle(
                    color: AppConstants114.textSoftGrey,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _toneChip('dark', 'Cyber Dark', setSheet),
                    _toneChip('midnight', 'OLED Midnight', setSheet),
                    _toneChip('paper', 'Crisp Light', setSheet),
                    _toneChip('sepia', 'Warm Sepia', setSheet),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.brightness_6_rounded,
                      color: AppConstants114.accentCyan,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Eye-Comfort Brightness Dimmer',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      '${((1.0 - _brightnessDimmer) * 100).round()}%',
                      style: const TextStyle(
                        color: AppConstants114.accentCyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _brightnessDimmer,
                  min: 0.0,
                  max: 0.55,
                  activeColor: AppConstants114.accentCyan,
                  onChanged: (v) {
                    setSheet(() => _brightnessDimmer = v);
                    setState(() => _brightnessDimmer = v);
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Horizontal Page Scroll Layout',
                    style: TextStyle(color: Colors.white, fontSize: 13.5),
                  ),
                  subtitle: const Text(
                    'Switch between continuous vertical and horizontal spread',
                    style: TextStyle(
                      color: AppConstants114.textSoftGrey,
                      fontSize: 11.5,
                    ),
                  ),
                  value: _horizontalLayout,
                  activeColor: AppConstants114.accentCyan,
                  onChanged: (val) {
                    setSheet(() => _horizontalLayout = val);
                    setState(() => _horizontalLayout = val);
                    if (_viewerController.isReady) {
                      _viewerController.relayout();
                    }
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                          ]);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.stay_current_portrait_rounded, size: 17),
                        label: const Text('Portrait'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.stay_current_landscape_rounded, size: 17),
                        label: const Text('Landscape'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toneChip(String id, String label, StateSetter setSheet) {
    final selected = _readingTone == id;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppConstants114.secondaryBlue,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppConstants114.textSoftGrey,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        setSheet(() => _readingTone = id);
        setState(() => _readingTone = id);
      },
    );
  }

  Future<void> _handleCreateAnnotation(AnnotationItem114 draft) async {
    var commentText = draft.comment;
    if (draft.kind == AnnotationKind114.note) {
      final ctrl = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Add Sticky Note Comment'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write annotation comment...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Attach Note'),
            ),
          ],
        ),
      );
      if (result == null || result.isEmpty) return;
      commentText = result;
    }

    final saved = AnnotationItem114(
      id: draft.id,
      documentId: _currentDoc.id,
      pageNumber: draft.pageNumber,
      kind: draft.kind,
      colorHex: draft.colorHex,
      comment: commentText,
      normalizedPoints: draft.normalizedPoints,
      normalizedRect: draft.normalizedRect,
      createdAt: draft.createdAt,
    );

    await ref.read(documentRepository114Provider).saveAnnotation(saved);
    setState(() => _annotations = [..._annotations, saved]);
  }

  Future<void> _handleDeleteAnnotation(String id) async {
    await ref.read(documentRepository114Provider).removeAnnotation(id);
    setState(() {
      _annotations = _annotations.where((a) => a.id != id).toList();
    });
  }

  Future<void> _inspectNoteDialog(AnnotationItem114 note) async {
    final ctrl = TextEditingController(text: note.comment);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Note on Page ${note.pageNumber}'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Comment'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _handleDeleteAnnotation(note.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppConstants114.dangerRose),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final updated = AnnotationItem114(
                id: note.id,
                documentId: note.documentId,
                pageNumber: note.pageNumber,
                kind: note.kind,
                colorHex: note.colorHex,
                comment: ctrl.text.trim(),
                normalizedPoints: note.normalizedPoints,
                normalizedRect: note.normalizedRect,
                createdAt: note.createdAt,
              );
              await ref
                  .read(documentRepository114Provider)
                  .saveAnnotation(updated);
              setState(() {
                _annotations = _annotations
                    .map((a) => a.id == updated.id ? updated : a)
                    .toList();
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAnnotatedPdfCopy() async {
    if (_annotations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one highlight, note, or drawing before saving a copy.'),
        ),
      );
      return;
    }
    try {
      final copyDoc =
          await ref.read(nexusWorkspaceProvider.notifier).saveAnnotatedCopy(
                originalDoc: _currentDoc,
                annotations: _annotations,
              );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved "${copyDoc.title}" to library! Original PDF preserved untouched.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export annotated PDF: $e')),
      );
    }
  }

  Widget _wrapWithReadingTone(Widget viewer) {
    switch (_readingTone) {
      case 'dark':
        // High-contrast smart dark inversion for crisp dark-mode reading
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            -0.88, 0, 0, 0, 238,
            0, -0.88, 0, 0, 242,
            0, 0, -0.85, 0, 250,
            0, 0, 0, 1, 0,
          ]),
          child: viewer,
        );
      case 'midnight':
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            -0.94, 0, 0, 0, 230,
            0, -0.94, 0, 0, 234,
            0, 0, -0.90, 0, 245,
            0, 0, 0, 1, 0,
          ]),
          child: viewer,
        );
      case 'sepia':
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.96, 0.04, 0, 0, 8,
            0.02, 0.92, 0.02, 0, 2,
            0, 0.04, 0.80, 0, -10,
            0, 0, 0, 1, 0,
          ]),
          child: viewer,
        );
      default:
        return viewer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgCol = (_readingTone == 'paper' || _readingTone == 'sepia')
        ? const Color(0xFFCBD5E1)
        : AppConstants114.darkBackground;

    return Scaffold(
      backgroundColor: AppConstants114.darkBackground,
      appBar: _fullScreenHudHidden
          ? null
          : AppBar(
              backgroundColor: AppConstants114.primaryNavy,
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentDoc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Page $_currentPage of $_totalPages • ${(_currentZoom * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppConstants114.accentCyan,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'In-Document Search',
                  onPressed: () {
                    setState(() => _showSearchBar = !_showSearchBar);
                    if (!_showSearchBar) {
                      _textSearcher.resetTextSearch();
                    }
                  },
                  icon: Icon(
                    Icons.search_rounded,
                    color: _showSearchBar
                        ? AppConstants114.accentCyan
                        : Colors.white,
                  ),
                ),
                IconButton(
                  tooltip: 'Annotation Studio',
                  onPressed: () {
                    setState(() {
                      _showAnnotationStudio = !_showAnnotationStudio;
                      if (!_showAnnotationStudio) {
                        _activeTool = null;
                        _eraserActive = false;
                      } else {
                        _activeTool ??= AnnotationKind114.highlight;
                      }
                    });
                  },
                  icon: Icon(
                    Icons.draw_rounded,
                    color: _showAnnotationStudio
                        ? AppConstants114.accentCyan
                        : Colors.white,
                  ),
                ),
                IconButton(
                  tooltip: 'Bookmark Page',
                  onPressed: _bookmarkCurrentPageDialog,
                  icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Page Thumbnails',
                  onPressed: _openThumbnailsSheet,
                  icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Reading Mode & Brightness',
                  onPressed: _openReadingCustomizationSheet,
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onSelected: (v) async {
                    if (v == 'save_ann') {
                      await _saveAnnotatedPdfCopy();
                    } else if (v == 'share' && _pdfBytes != null) {
                      await ExportShareService114.shareBinaryFile(
                        bytes: _pdfBytes!,
                        fileName: _currentDoc.fileName,
                        mimeType: 'application/pdf',
                      );
                    } else if (v == 'fullscreen') {
                      _toggleFullScreen();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'save_ann',
                      child: Text('Save Annotated PDF Copy'),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Text('Share PDF File'),
                    ),
                    PopupMenuItem(
                      value: 'fullscreen',
                      child: Text('Full-Screen Reading Mode'),
                    ),
                  ],
                ),
              ],
            ),
      body: Column(
        children: [
          if (!_fullScreenHudHidden && _showSearchBar) _buildSearchHud(),
          if (!_fullScreenHudHidden && _showAnnotationStudio)
            _buildAnnotationToolbar(),
          Expanded(
            child: Stack(
              children: [
                if (_loadError != null)
                  _buildErrorView()
                else if (_pdfBytes == null)
                  const Center(child: CircularProgressIndicator())
                else
                  Positioned.fill(
                    child: _wrapWithReadingTone(
                      PdfViewer.data(
                        Uint8List.fromList(_pdfBytes!),
                        sourceName: _currentDoc.id,
                        controller: _viewerController,
                        initialPageNumber:
                            _currentPage.clamp(1, max(1, _totalPages)),
                        params: PdfViewerParams(
                          margin: 12,
                          backgroundColor: bgCol,
                          maxScale: 6.0,
                          minScale: 0.4,
                          panEnabled: _activeTool == null && !_eraserActive,
                          scaleEnabled: _activeTool == null && !_eraserActive,
                          layoutPages: _horizontalLayout
                              ? (pages, params) {
                                  final h = pages.fold<double>(
                                        0.0,
                                        (prev, p) => max(prev, p.height),
                                      ) +
                                      params.margin * 2;
                                  final layouts = <Rect>[];
                                  var x = params.margin;
                                  for (final p in pages) {
                                    layouts.add(
                                      Rect.fromLTWH(
                                        x,
                                        (h - p.height) / 2,
                                        p.width,
                                        p.height,
                                      ),
                                    );
                                    x += p.width + params.margin;
                                  }
                                  return PdfPageLayout(
                                    pageLayouts: layouts,
                                    documentSize: Size(x, h),
                                  );
                                }
                              : null,
                          pagePaintCallbacks: [
                            _textSearcher.pageTextMatchPaintCallback,
                          ],
                          onViewerReady: (doc, controller) {
                            if (!mounted) return;
                            setState(() => _totalPages = doc.pages.length);
                            final defaultZoom = ref
                                .read(nexusWorkspaceProvider)
                                .settings
                                .defaultZoom;
                            if ((defaultZoom - 1.0).abs() > 0.05) {
                              controller.setZoom(
                                controller.centerPosition,
                                defaultZoom,
                              );
                            }
                            if (widget.initialSearchQuery != null &&
                                widget.initialSearchQuery!.trim().isNotEmpty) {
                              _textSearcher.startTextSearch(
                                widget.initialSearchQuery!.trim(),
                                caseInsensitive: true,
                                goToFirstMatch: true,
                                searchImmediately: true,
                              );
                            }
                          },
                          onPageChanged: (page) {
                            if (page != null) {
                              _persistPage(page);
                            }
                          },
                          pageOverlaysBuilder: (ctx, pageRect, page) {
                            final pageAnns = _annotations
                                .where((a) => a.pageNumber == page.pageNumber)
                                .toList();
                            return [
                              AnnotationCanvasOverlay114(
                                pageNumber: page.pageNumber,
                                pageSize: pageRect.size,
                                pageAnnotations: pageAnns,
                                activeTool: _activeTool,
                                eraserActive: _eraserActive,
                                activeColorHex: _activeColorHex,
                                onCreateAnnotation: _handleCreateAnnotation,
                                onDeleteAnnotation: _handleDeleteAnnotation,
                                onInspectNote: _inspectNoteDialog,
                              ),
                            ];
                          },
                        ),
                      ),
                    ),
                  ),
                if (_brightnessDimmer > 0.01)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black.withOpacity(_brightnessDimmer),
                      ),
                    ),
                  ),
                if (_fullScreenHudHidden)
                  Positioned(
                    top: 18,
                    right: 18,
                    child: FloatingActionButton.small(
                      backgroundColor: AppConstants114.primaryNavy,
                      foregroundColor: AppConstants114.accentCyan,
                      onPressed: _toggleFullScreen,
                      child: const Icon(Icons.fullscreen_exit_rounded),
                    ),
                  ),
              ],
            ),
          ),
          if (!_fullScreenHudHidden && _pdfBytes != null && _loadError == null)
            _buildBottomControlDock(),
        ],
      ),
    );
  }

  Widget _buildSearchHud() {
    final matchesCount = _textSearcher.matches.length;
    final currentIdx =
        _textSearcher.currentIndex != null ? _textSearcher.currentIndex! + 1 : 0;

    return Container(
      color: AppConstants114.cardSurface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        children: [
          if (!_hasExtractableText)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants114.warningAmber.withOpacity(0.16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppConstants114.warningAmber.withOpacity(0.5),
                ),
              ),
              child: const Text(
                'Scanned / image-based PDF detected: No embedded text layer available without external OCR.',
                style: TextStyle(
                  color: AppConstants114.warningAmber,
                  fontSize: 11.5,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchInputCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Search text inside PDF...',
                    isDense: true,
                    prefixIcon: const Icon(Icons.manage_search_rounded, size: 19),
                    suffixIcon: _searchInputCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 17),
                            onPressed: () {
                              _searchInputCtrl.clear();
                              _textSearcher.resetTextSearch();
                              setState(() {});
                            },
                          ),
                  ),
                  onChanged: (q) {
                    setState(() {});
                    _textSearcher.startTextSearch(
                      q,
                      caseInsensitive: true,
                      goToFirstMatch: true,
                      searchImmediately: true,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentIdx/$matchesCount',
                style: const TextStyle(
                  color: AppConstants114.accentCyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Previous Match',
                onPressed:
                    matchesCount > 0 ? () => _textSearcher.goToPrevMatch() : null,
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Next Match',
                onPressed:
                    matchesCount > 0 ? () => _textSearcher.goToNextMatch() : null,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotationToolbar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: AppConstants114.cardSurface,
        border: Border(
          bottom: BorderSide(color: AppConstants114.borderSubtle),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _annToolBtn(
              icon: Icons.pan_tool_alt_rounded,
              label: 'Scroll',
              selected: _activeTool == null && !_eraserActive,
              onTap: () => setState(() {
                _activeTool = null;
                _eraserActive = false;
              }),
            ),
            _annToolBtn(
              icon: Icons.highlight_rounded,
              label: 'Highlight',
              selected:
                  _activeTool == AnnotationKind114.highlight && !_eraserActive,
              onTap: () => setState(() {
                _activeTool = AnnotationKind114.highlight;
                _eraserActive = false;
              }),
            ),
            _annToolBtn(
              icon: Icons.format_underlined_rounded,
              label: 'Underline',
              selected:
                  _activeTool == AnnotationKind114.underline && !_eraserActive,
              onTap: () => setState(() {
                _activeTool = AnnotationKind114.underline;
                _eraserActive = false;
              }),
            ),
            _annToolBtn(
              icon: Icons.strikethrough_s_rounded,
              label: 'Strike',
              selected: _activeTool == AnnotationKind114.strikethrough &&
                  !_eraserActive,
              onTap: () => setState(() {
                _activeTool = AnnotationKind114.strikethrough;
                _eraserActive = false;
              }),
            ),
            _annToolBtn(
              icon: Icons.gesture_rounded,
              label: 'Ink',
              selected:
                  _activeTool == AnnotationKind114.freehand && !_eraserActive,
              onTap: () => setState(() {
                _activeTool = AnnotationKind114.freehand;
                _eraserActive = false;
              }),
            ),
            _annToolBtn(
              icon: Icons.sticky_note_2_outlined,
              label: 'Note',
              selected: _activeTool == AnnotationKind114.note && !_eraserActive,
              onTap: () => setState(() {
                _activeTool = AnnotationKind114.note;
                _eraserActive = false;
              }),
            ),
            _annToolBtn(
              icon: Icons.auto_fix_off_rounded,
              label: 'Eraser',
              selected: _eraserActive,
              onTap: () => setState(() {
                _eraserActive = !_eraserActive;
                if (_eraserActive) _activeTool = null;
              }),
            ),
            const SizedBox(width: 8),
            for (final hex in AppConstants114.annotationPalette)
              GestureDetector(
                onTap: () => setState(() => _activeColorHex = hex),
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Color(hex),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _activeColorHex == hex
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 10),
            FilledButton.tonalIcon(
              onPressed: _saveAnnotatedPdfCopy,
              icon: const Icon(Icons.save_as_rounded, size: 16),
              label: const Text('Save Copy', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _annToolBtn({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppConstants114.secondaryBlue
                : AppConstants114.primaryNavy,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppConstants114.accentCyan
                  : AppConstants114.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControlDock() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      decoration: const BoxDecoration(
        color: AppConstants114.primaryNavy,
        border: Border(top: BorderSide(color: AppConstants114.borderSubtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Previous Page',
                onPressed: _currentPage > 1 && _viewerController.isReady
                    ? () =>
                        _viewerController.goToPage(pageNumber: _currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: _currentPage.clamp(1, max(1, _totalPages)).toDouble(),
                    min: 1,
                    max: max(1, _totalPages).toDouble(),
                    divisions: _totalPages > 1 ? _totalPages - 1 : null,
                    activeColor: AppConstants114.accentCyan,
                    inactiveColor: AppConstants114.borderSubtle,
                    onChanged: (v) {
                      final p = v.round();
                      setState(() => _currentPage = p);
                      if (_viewerController.isReady) {
                        _viewerController.goToPage(pageNumber: p);
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Next Page',
                onPressed:
                    _currentPage < _totalPages && _viewerController.isReady
                        ? () => _viewerController.goToPage(
                              pageNumber: _currentPage + 1,
                            )
                        : null,
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.pin_invoke_rounded, size: 15),
                  label: Text('Page $_currentPage / $_totalPages'),
                  onPressed: _jumpToPageDialog,
                ),
                const SizedBox(width: 6),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Zoom Out',
                  onPressed: _viewerController.isReady
                      ? () => _viewerController.zoomDown()
                      : null,
                  icon: const Icon(Icons.zoom_out_rounded, color: Colors.white70),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Zoom In',
                  onPressed: _viewerController.isReady
                      ? () => _viewerController.zoomUp()
                      : null,
                  icon: const Icon(Icons.zoom_in_rounded, color: Colors.white70),
                ),
                TextButton(
                  onPressed: _viewerController.isReady
                      ? () {
                          final m = _viewerController.calcMatrixFitWidthForPage(
                            pageNumber: _currentPage,
                          );
                          _viewerController.goTo(m);
                        }
                      : null,
                  child: const Text('Fit Width', style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: _viewerController.isReady
                      ? () {
                          final m = _viewerController.calcMatrixForFit(
                            pageNumber: _currentPage,
                          );
                          _viewerController.goTo(m);
                        }
                      : null,
                  child: const Text('Fit Page', style: TextStyle(fontSize: 12)),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Full Screen',
                  onPressed: _toggleFullScreen,
                  icon: const Icon(
                    Icons.fullscreen_rounded,
                    color: AppConstants114.accentCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: AppConstants114.dangerRose,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to Render PDF Document',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _loadError ?? 'Unknown document stream error.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppConstants114.textSoftGrey),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Return to Library'),
            ),
          ],
        ),
      ),
    );
  }
}
