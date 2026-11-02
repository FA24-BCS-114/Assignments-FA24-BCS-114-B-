import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum ScanFilter114 { original, magicContrast, grayscale, crispBw }

enum ScanCropPreset114 { fullPage, a4Portrait, receiptStrip, idCard }

class SamplePdfSpec114 {
  final String id;
  final String title;
  final String fileName;
  final String folderId;
  final String tags;
  final String description;
  final int lastReadPage;
  final bool isFavorite;
  final bool isScanned;
  final Uint8List bytes;
  final int pageCount;

  const SamplePdfSpec114({
    required this.id,
    required this.title,
    required this.fileName,
    required this.folderId,
    required this.tags,
    required this.description,
    required this.lastReadPage,
    required this.isFavorite,
    required this.isScanned,
    required this.bytes,
    required this.pageCount,
  });
}

class SamplePdfFactory114 {
  SamplePdfFactory114._();

  static Future<List<SamplePdfSpec114>> buildInitialLibraryPdfs() async {
    final doc1 = await _generateTechnicalPdf(
      title: 'Nexus Flutter Clean Architecture 114',
      subtitle: 'Enterprise Mobile State Management, Riverpod & Rendering Pipelines',
      author: 'Harry (FA24-BCS-114)',
      accent: PdfColor.fromInt(0xFF2563EB),
      chapters: const [
        (
          '1. Layered Architecture Overview',
          'Modern Flutter applications separate presentation widgets, reactive state providers, domain repositories, and SQLite data sources. This decoupling ensures testability, predictable state transitions, and zero UI jank during heavy I/O.'
        ),
        (
          '2. Asynchronous PDF Rendering Pipeline',
          'High-resolution PDF pages are rasterized asynchronously on background isolates or worker threads. Viewport-aware tile caching prevents out-of-memory errors when scrolling large technical manuals exceeding hundreds of pages.'
        ),
        (
          '3. Reactive Riverpod State Graphs',
          'Using StateNotifierProvider allows granular widget rebuilds. Search queries, sort modes, bookmarks, and reading progress update instantaneously while persisting asynchronously into relational SQLite tables.'
        ),
        (
          '4. Cross-Device Adaptive Layouts',
          'LayoutBuilder breakpoints adapt navigation bars, document grids, and split-pane inspection panels seamlessly across Android phones, tablets, iOS devices, and wide desktop monitors.'
        ),
        (
          '5. Non-Destructive PDF Annotations',
          'Highlights, underlines, strike-throughs, sticky notes, and freehand vector ink strokes are stored in normalized page coordinates and exported into standalone annotated PDF copies without altering original files.'
        ),
      ],
    );

    final doc2 = await _generateTechnicalPdf(
      title: 'SQLite Storage & Indexing Handbook',
      subtitle: 'Persistent Document Metadata, Bookmarks & Reading Telemetry',
      author: 'Database Engineering Group',
      accent: PdfColor.fromInt(0xFF0891B2),
      chapters: const [
        (
          '1. Relational Schema Design',
          'Normalized SQLite schemas track document metadata, user tags, page-level bookmarks, timestamped reading sessions, and custom reader preferences with ACID durability across app restarts.'
        ),
        (
          '2. Fast Full-Library Filtering',
          'Composite indices on last_opened_at, title, and folder_id enable sub-millisecond sorting and instant search across file names, tags, and descriptions.'
        ),
        (
          '3. Export & Interoperability',
          'Structured telemetry can be exported at any time into RFC-4180 CSV spreadsheets, formatted PDF executive summaries, or shared directly via native OS share sheets and email clients.'
        ),
        (
          '4. Fault Tolerance & Integrity Validation',
          'Every imported PDF stream undergoes header and cross-reference validation prior to indexing, protecting the workspace from truncated or corrupted binary files.'
        ),
      ],
    );

    final doc3 = await _generateTechnicalPdf(
      title: 'Mobile Computer Vision & Document Scanning',
      subtitle: 'Perspective Cropping, Adaptive Thresholding & Multi-Page PDF Synthesis',
      author: 'CSC303 Lab Mid Reference',
      accent: PdfColor.fromInt(0xFF4F46E5),
      chapters: const [
        (
          '1. Camera Capture Pipeline',
          'Physical lecture handouts, receipts, and whiteboard diagrams captured via mobile sensors often suffer from uneven ambient lighting and low contrast.'
        ),
        (
          '2. Adaptive Document Enhancement',
          'Applying luminance normalization, grayscale conversion, and high-contrast binarization transforms dim camera snapshots into crisp, print-ready document pages.'
        ),
        (
          '3. Multi-Page PDF Compilation',
          'Enhanced raster frames are embedded into A4 or custom-aspect PDF containers with automatic margin calibration and instant indexing in the SQLite library.'
        ),
      ],
    );

    final doc4 = await _generateTechnicalPdf(
      title: 'Cyber Security & Sandboxed File Systems',
      subtitle: 'Scoped Storage Permissions, Checksums & Privacy Controls',
      author: 'Systems Security Lab',
      accent: PdfColor.fromInt(0xFF059669),
      chapters: const [
        (
          '1. Android Scoped Storage & Runtime Permissions',
          'Modern Android API levels enforce scoped document access via system file pickers and granular camera/notification permissions, safeguarding user privacy.'
        ),
        (
          '2. Zero-Telemetry Offline Operation',
          'All PDF rendering, text indexing, bookmark storage, and image conversions execute 100% locally on the device without transmitting sensitive documents over external networks.'
        ),
        (
          '3. Cryptographic Integrity Checks',
          'SHA-256 digests and strict parser verification detect malformed streams early and present actionable recovery messages to the reader.'
        ),
      ],
    );

    return [
      SamplePdfSpec114(
        id: 'doc_114_arch',
        title: 'Nexus Flutter Clean Architecture 114',
        fileName: 'Nexus_Flutter_Architecture_114.pdf',
        folderId: 'fld_cs',
        tags: 'Flutter, Architecture, Riverpod',
        description: 'Complete reference guide on layered Flutter architecture, PDFium rendering, and Riverpod state management.',
        lastReadPage: 3,
        isFavorite: true,
        isScanned: false,
        bytes: doc1,
        pageCount: 5,
      ),
      SamplePdfSpec114(
        id: 'doc_114_sqlite',
        title: 'SQLite Storage & Indexing Handbook',
        fileName: 'SQLite_Storage_Handbook.pdf',
        folderId: 'fld_cs',
        tags: 'SQLite, Database, Offline',
        description: 'Relational database schema patterns for document metadata, bookmarks, and reading analytics.',
        lastReadPage: 2,
        isFavorite: true,
        isScanned: false,
        bytes: doc2,
        pageCount: 4,
      ),
      SamplePdfSpec114(
        id: 'doc_114_scan',
        title: 'Scanner & Vision Pipeline Notes',
        fileName: 'Scanner_Vision_Notes_114.pdf',
        folderId: 'fld_scans',
        tags: 'Scanner, Image, Utility',
        description: 'Scanned lecture notes covering document enhancement filters and PDF-to-image raster conversion.',
        lastReadPage: 1,
        isFavorite: false,
        isScanned: true,
        bytes: doc3,
        pageCount: 3,
      ),
      SamplePdfSpec114(
        id: 'doc_114_sec',
        title: 'Cyber Security & Sandboxed File Systems',
        fileName: 'Cyber_Security_Sandboxed_IO.pdf',
        folderId: 'fld_research',
        tags: 'Security, Android, Permissions',
        description: 'Best practices for mobile permission handling, scoped file pickers, and local storage privacy.',
        lastReadPage: 3,
        isFavorite: false,
        isScanned: false,
        bytes: doc4,
        pageCount: 3,
      ),
    ];
  }

  static Future<Uint8List> _generateTechnicalPdf({
    required String title,
    required String subtitle,
    required String author,
    required PdfColor accent,
    required List<(String, String)> chapters,
  }) async {
    final pdf = pw.Document(title: title, author: author);

    for (var i = 0; i < chapters.length; i++) {
      final ch = chapters[i];
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(42),
          build: (ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(18),
                  decoration: pw.BoxDecoration(
                    color: accent,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              title.toUpperCase(),
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              subtitle,
                              style: const pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'Page ${i + 1} / ${chapters.length}',
                          style: pw.TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 26),
                pw.Text(
                  ch.$1,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF0F172A),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  ch.$2,
                  style: const pw.TextStyle(
                    fontSize: 12.5,
                    lineSpacing: 5,
                    color: PdfColor.fromInt(0xFF334155),
                  ),
                ),
                pw.SizedBox(height: 22),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF1F5F9),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColor.fromInt(0xFFCBD5E1)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Key Engineering Takeaways | Section ${i + 1}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: accent,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _pdfPoint(
                        accent,
                        'Deterministic resource disposal prevents native PDFium and Dart stream leaks.',
                      ),
                      _pdfPoint(
                        accent,
                        'SQLite persistence guarantees instant resume from Page ${i + 1} after restart.',
                      ),
                      _pdfPoint(
                        accent,
                        'Full-text search indexes every word on this page for instant highlight jumps.',
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headerDecoration: pw.BoxDecoration(color: accent),
                  headerStyle: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9.5),
                  headers: const ['Module', 'Responsibility', 'Target Latency'],
                  data: [
                    ['PDF Engine', 'Vector tile & zoom matrix', '< 16 ms / frame'],
                    ['SQLite Vault', 'Metadata, bookmarks & history', '< 5 ms / query'],
                    ['Text Searcher', 'Case-insensitive match bounds', '< 40 ms / doc'],
                  ],
                ),
                pw.Spacer(),
                pw.Divider(color: PdfColor.fromInt(0xFFE2E8F0)),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Author: $author',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'PDF Reader 114 | Verified Searchable Document',
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _pdfPoint(PdfColor color, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 4, right: 8),
            width: 5,
            height: 5,
            decoration: pw.BoxDecoration(
              color: color,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
                fontSize: 10.5,
                color: PdfColor.fromInt(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generates a realistic synthetic camera document snapshot (for testing scanner even without hardware camera)
  static Uint8List generateSampleScannedPageImage({int pageIndex = 1}) {
    final canvas = img.Image(width: 720, height: 960);
    img.fill(canvas, color: img.ColorRgb8(244, 246, 250));

    // Outer paper card border
    img.drawRect(
      canvas,
      x1: 36,
      y1: 36,
      x2: 684,
      y2: 924,
      color: img.ColorRgb8(37, 99, 235),
      thickness: 4,
    );

    // Header bar
    img.fillRect(
      canvas,
      x1: 60,
      y1: 64,
      x2: 660,
      y2: 148,
      color: img.ColorRgb8(16, 24, 39),
    );
    img.drawString(
      canvas,
      'CYBERSCAN 114 - CAPTURED LECTURE SHEET #$pageIndex',
      font: img.arial24,
      x: 82,
      y: 94,
      color: img.ColorRgb8(34, 211, 238),
    );

    img.drawString(
      canvas,
      'Course: CSC303 Mobile App Development (Lab Mid)',
      font: img.arial24,
      x: 72,
      y: 190,
      color: img.ColorRgb8(15, 23, 42),
    );
    img.drawString(
      canvas,
      'Student: Harry | Reg: FA24-BCS-114 | Sec B',
      font: img.arial24,
      x: 72,
      y: 235,
      color: img.ColorRgb8(51, 65, 85),
    );

    // Simulated paragraph lines and diagram boxes
    for (var i = 0; i < 9; i++) {
      final y = 310 + i * 44;
      final endX = (i % 3 == 2) ? 490 : 640;
      img.fillRect(
        canvas,
        x1: 72,
        y1: y,
        x2: endX,
        y2: y + 14,
        color: img.ColorRgb8(71, 85, 105),
      );
    }

    img.drawRect(
      canvas,
      x1: 72,
      y1: 730,
      x2: 648,
      y2: 875,
      color: img.ColorRgb8(16, 185, 129),
      thickness: 3,
    );
    img.drawString(
      canvas,
      'Verified Camera Scan -> Enhanced -> PDF Output',
      font: img.arial24,
      x: 96,
      y: 790,
      color: img.ColorRgb8(16, 24, 39),
    );

    return Uint8List.fromList(img.encodePng(canvas));
  }

  /// Applies real crop & document enhancement filter to a scanned image
  static Uint8List processScannedImage(
    Uint8List rawBytes, {
    required ScanFilter114 filter,
    required ScanCropPreset114 crop,
    int quarterTurns = 0,
  }) {
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) return rawBytes;

    img.Image working = decoded;
    if (quarterTurns % 4 != 0) {
      working = img.copyRotate(working, angle: (quarterTurns % 4) * 90);
    }

    // Apply crop preset
    switch (crop) {
      case ScanCropPreset114.fullPage:
        break;
      case ScanCropPreset114.a4Portrait:
        final marginX = (working.width * 0.05).round();
        final marginY = (working.height * 0.04).round();
        working = img.copyCrop(
          working,
          x: marginX,
          y: marginY,
          width: working.width - marginX * 2,
          height: working.height - marginY * 2,
        );
        break;
      case ScanCropPreset114.receiptStrip:
        final marginX = (working.width * 0.16).round();
        working = img.copyCrop(
          working,
          x: marginX,
          y: 0,
          width: working.width - marginX * 2,
          height: working.height,
        );
        break;
      case ScanCropPreset114.idCard:
        final targetH = (working.height * 0.58).round();
        final startY = ((working.height - targetH) / 2).round();
        working = img.copyCrop(
          working,
          x: (working.width * 0.06).round(),
          y: startY,
          width: (working.width * 0.88).round(),
          height: targetH,
        );
        break;
    }

    // Apply filter
    switch (filter) {
      case ScanFilter114.original:
        break;
      case ScanFilter114.magicContrast:
        working = img.adjustColor(working, contrast: 1.38, brightness: 1.06, saturation: 1.15);
        break;
      case ScanFilter114.grayscale:
        working = img.grayscale(working);
        working = img.adjustColor(working, contrast: 1.2);
        break;
      case ScanFilter114.crispBw:
        working = img.grayscale(working);
        working = img.luminanceThreshold(working, threshold: 0.56);
        break;
    }

    return Uint8List.fromList(img.encodePng(working));
  }

  /// Synthesizes multiple scanned & enhanced page images into a real multi-page PDF binary
  static Future<Uint8List> buildPdfFromScannedImages({
    required String title,
    required List<Uint8List> pageImages,
  }) async {
    final doc = pw.Document(title: title, author: 'CyberScan 114');
    for (var i = 0; i < pageImages.length; i++) {
      final memImg = pw.MemoryImage(pageImages[i]);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (_) => pw.Column(
            children: [
              pw.Expanded(
                child: pw.Center(
                  child: pw.Image(memImg, fit: pw.BoxFit.contain),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '$title • Scanned Page ${i + 1} of ${pageImages.length}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      );
    }
    return doc.save();
  }

  static String encodeBytes(Uint8List bytes) => base64Encode(bytes);
}
