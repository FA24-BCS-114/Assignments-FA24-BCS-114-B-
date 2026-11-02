import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import '../models/pdf_doc_model.dart';
import '../models/reader_aux_models.dart';
import '../utils/file_bytes_loader.dart';

class PdfCorruptedException114 implements Exception {
  final String message;
  const PdfCorruptedException114(this.message);
  @override
  String toString() => message;
}

class PdfInspectionResult114 {
  final int pageCount;
  final bool hasExtractableText;
  final String previewSnippet;

  const PdfInspectionResult114({
    required this.pageCount,
    required this.hasExtractableText,
    required this.previewSnippet,
  });
}

class ConvertedPageImage114 {
  final int pageNumber;
  final String format; // 'PNG' or 'JPG'
  final Uint8List bytes;
  final int width;
  final int height;

  const ConvertedPageImage114({
    required this.pageNumber,
    required this.format,
    required this.bytes,
    required this.width,
    required this.height,
  });
}

class PdfEngineService114 {
  PdfEngineService114._();

  /// Loads raw PDF bytes safely from either base64 memory/SQLite or native file path
  static Future<Uint8List> resolveDocumentBytes(PdfDocModel114 doc) async {
    if (doc.pdfBase64 != null && doc.pdfBase64!.isNotEmpty) {
      try {
        return Uint8List.fromList(base64Decode(doc.pdfBase64!));
      } catch (_) {
        throw const PdfCorruptedException114(
          'Stored PDF binary encoding is corrupted or unreadable.',
        );
      }
    }
    if (!kIsWeb && doc.filePath != null && doc.filePath!.isNotEmpty) {
      final loaded = await readLocalFileBytes114(doc.filePath!);
      if (loaded == null) {
        throw const PdfCorruptedException114(
          'The PDF file was moved or deleted from device storage.',
        );
      }
      return loaded;
    }
    throw const PdfCorruptedException114(
      'Document source is missing or inaccessible.',
    );
  }

  /// Validates PDF header/xref integrity, counts pages, and checks for extractable text (OCR check)
  static PdfInspectionResult114 inspectAndValidatePdf(Uint8List rawBytes) {
    if (rawBytes.length < 8) {
      throw const PdfCorruptedException114(
        'Invalid or empty file: File is too small to be a valid PDF.',
      );
    }
    sf.PdfDocument? document;
    try {
      document = sf.PdfDocument(inputBytes: rawBytes);
      final count = document.pages.count;
      if (count <= 0) {
        throw const PdfCorruptedException114('PDF contains zero readable pages.');
      }
      final extractor = sf.PdfTextExtractor(document);
      final sampleEnd = count > 3 ? 2 : count - 1;
      final extracted =
          extractor.extractText(startPageIndex: 0, endPageIndex: sampleEnd).trim();
      return PdfInspectionResult114(
        pageCount: count,
        hasExtractableText: extracted.isNotEmpty,
        previewSnippet: extracted.length > 160
            ? '${extracted.substring(0, 160)}...'
            : extracted,
      );
    } catch (e) {
      if (e is PdfCorruptedException114) rethrow;
      throw const PdfCorruptedException114(
        'Unsupported, password-locked, or corrupted PDF binary stream.',
      );
    } finally {
      document?.dispose();
    }
  }

  /// Embeds highlights, underlines, strike-throughs, notes, and freehand drawings into a NEW saved PDF copy
  static Uint8List exportAnnotatedPdfCopy({
    required Uint8List originalBytes,
    required List<AnnotationItem114> annotations,
  }) {
    final doc = sf.PdfDocument(inputBytes: Uint8List.fromList(originalBytes));
    try {
      for (final ann in annotations) {
        final pageIdx = ann.pageNumber - 1;
        if (pageIdx < 0 || pageIdx >= doc.pages.count) continue;
        final page = doc.pages[pageIdx];
        final pw = page.getClientSize().width;
        final ph = page.getClientSize().height;
        final c = Color(ann.colorHex);
        final pdfColor = sf.PdfColor(c.red, c.green, c.blue);

        switch (ann.kind) {
          case AnnotationKind114.highlight:
          case AnnotationKind114.underline:
          case AnnotationKind114.strikethrough:
            final nr = ann.normalizedRect ?? const Rect.fromLTWH(0.1, 0.2, 0.6, 0.04);
            final rect = Rect.fromLTWH(
              nr.left * pw,
              nr.top * ph,
              nr.width * pw,
              nr.height * ph,
            );
            final markupType = switch (ann.kind) {
              AnnotationKind114.highlight => sf.PdfTextMarkupAnnotationType.highlight,
              AnnotationKind114.underline => sf.PdfTextMarkupAnnotationType.underline,
              _ => sf.PdfTextMarkupAnnotationType.strikethrough,
            };
            final markup = sf.PdfTextMarkupAnnotation(
              rect,
              ann.comment.isEmpty ? ann.kind.name.toUpperCase() : ann.comment,
              pdfColor,
              author: 'PDF Reader 114',
              opacity: ann.kind == AnnotationKind114.highlight ? 0.42 : 0.9,
              textMarkupAnnotationType: markupType,
            );
            page.annotations.add(markup);
            break;

          case AnnotationKind114.note:
            final nr = ann.normalizedRect ?? const Rect.fromLTWH(0.8, 0.2, 0.06, 0.06);
            final popup = sf.PdfPopupAnnotation(
              Rect.fromLTWH(nr.left * pw, nr.top * ph, 26, 26),
              ann.comment.isEmpty ? 'Reader Note' : ann.comment,
              color: pdfColor,
              author: 'Harry (114)',
              icon: sf.PdfPopupIcon.comment,
            );
            page.annotations.add(popup);
            break;

          case AnnotationKind114.freehand:
            if (ann.normalizedPoints.length >= 2) {
              final pen = sf.PdfPen(pdfColor, width: 2.6);
              for (var i = 0; i < ann.normalizedPoints.length - 1; i++) {
                final p1 = ann.normalizedPoints[i];
                final p2 = ann.normalizedPoints[i + 1];
                page.graphics.drawLine(
                  pen,
                  Offset(p1.dx * pw, p1.dy * ph),
                  Offset(p2.dx * pw, p2.dy * ph),
                );
              }
            }
            break;
        }
      }
      final saved = doc.saveSync();
      return Uint8List.fromList(saved);
    } finally {
      doc.dispose();
    }
  }

  /// Converts selected pages of a PDF into high-resolution PNG or JPG images
  static Future<List<ConvertedPageImage114>> convertPdfPagesToImages({
    required Uint8List pdfBytes,
    required List<int> pageNumbers,
    required String format, // 'PNG' or 'JPG'
    double scale = 1.75,
  }) async {
    final doc = await pdfrx.PdfDocument.openData(Uint8List.fromList(pdfBytes));
    final results = <ConvertedPageImage114>[];
    try {
      for (final pageNum in pageNumbers) {
        if (pageNum < 1 || pageNum > doc.pages.length) continue;
        final page = doc.pages[pageNum - 1];
        final targetW = (page.width * scale).round();
        final targetH = (page.height * scale).round();
        final rendered = await page.render(
          width: targetW,
          height: targetH,
          fullWidth: targetW.toDouble(),
          fullHeight: targetH.toDouble(),
          backgroundColor: Colors.white,
        );
        if (rendered == null) continue;
        final uiImg = await rendered.createImage();
        final byteData = await uiImg.toByteData(format: ui.ImageByteFormat.png);
        rendered.dispose();
        uiImg.dispose();
        if (byteData == null) continue;

        Uint8List outBytes = byteData.buffer.asUint8List();
        if (format.toUpperCase() == 'JPG') {
          final decoded = img.decodePng(outBytes);
          if (decoded != null) {
            outBytes = Uint8List.fromList(img.encodeJpg(decoded, quality: 90));
          }
        }

        results.add(
          ConvertedPageImage114(
            pageNumber: pageNum,
            format: format.toUpperCase(),
            bytes: outBytes,
            width: targetW,
            height: targetH,
          ),
        );
      }
      return results;
    } finally {
      await doc.dispose();
    }
  }
}
