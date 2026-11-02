import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/pdf_doc_model.dart';
import '../models/reader_aux_models.dart';
import '../utils/format_helpers.dart';

class ExportShareService114 {
  ExportShareService114._();

  /// Generates RFC-4180 CSV export of documents, bookmarks, and reading history
  static String buildLibraryCsv({
    required List<PdfDocModel114> documents,
    required List<BookmarkItem114> bookmarks,
    required List<HistoryEntry114> history,
  }) {
    String esc(String v) => '"${v.replaceAll('"', '""')}"';
    final buf = StringBuffer();
    buf.writeln('SECTION,ID,TITLE,DETAILS,PAGE_INFO,TIMESTAMP');

    for (final d in documents) {
      buf.writeln([
        'DOCUMENT',
        esc(d.id),
        esc(d.title),
        esc('Tags: ${d.tags} | Size: ${FormatHelpers114.formatBytes(d.fileSizeBytes)}'),
        esc('Page ${d.lastReadPage}/${d.pageCount} (${d.progressPercent}%)'),
        esc(d.lastModifiedAt.toIso8601String()),
      ].join(','));
    }

    for (final b in bookmarks) {
      buf.writeln([
        'BOOKMARK',
        esc(b.id),
        esc(b.documentTitle),
        esc('${b.label} - ${b.note}'),
        esc('Page ${b.pageNumber}'),
        esc(b.createdAt.toIso8601String()),
      ].join(','));
    }

    for (final h in history) {
      buf.writeln([
        'HISTORY',
        esc(h.id),
        esc(h.documentTitle),
        esc('Reading session recorded'),
        esc('Reached Page ${h.reachedPage}/${h.totalPages}'),
        esc(h.openedAt.toIso8601String()),
      ].join(','));
    }

    return buf.toString();
  }

  /// Generates a formatted PDF Summary Report of library metadata, bookmarks & reading history
  static Future<Uint8List> buildActivityReportPdf({
    required List<PdfDocModel114> documents,
    required List<BookmarkItem114> bookmarks,
    required List<HistoryEntry114> history,
  }) async {
    final pdf = pw.Document(
      title: 'PDF Reader 114 - Reading & Library Telemetry Report',
      author: 'Harry (FA24-BCS-114)',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF101827),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PDF READER 114 • ANALYTICS & EXPORT REPORT',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on ${FormatHelpers114.formatDateTime(DateTime.now())}',
                      style: const pw.TextStyle(
                        color: PdfColors.grey300,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  '${documents.length} Docs • ${bookmarks.length} Bookmarks',
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFF22D3EE),
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            '1. Document Metadata & Reading Progress',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Title', 'Pages', 'Progress', 'Size', 'Tags'],
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9.5,
            ),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF2563EB)),
            cellStyle: const pw.TextStyle(fontSize: 9),
            data: documents
                .map((d) => [
                      d.title,
                      '${d.lastReadPage}/${d.pageCount}',
                      '${d.progressPercent}%',
                      FormatHelpers114.formatBytes(d.fileSizeBytes),
                      d.tags,
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            '2. Saved Page Bookmarks',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (bookmarks.isEmpty)
            pw.Text('No bookmarks recorded yet.', style: const pw.TextStyle(fontSize: 10))
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Document', 'Page', 'Label', 'Note'],
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9.5,
              ),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF0891B2)),
              cellStyle: const pw.TextStyle(fontSize: 9),
              data: bookmarks
                  .map((b) => [b.documentTitle, 'P.${b.pageNumber}', b.label, b.note])
                  .toList(),
            ),
          pw.SizedBox(height: 20),
          pw.Text(
            '3. Recent Reading Sessions',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (history.isEmpty)
            pw.Text('No reading sessions logged.', style: const pw.TextStyle(fontSize: 10))
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Document', 'Reached Page', 'Opened Timestamp'],
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9.5,
              ),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF059669)),
              cellStyle: const pw.TextStyle(fontSize: 9),
              data: history
                  .take(15)
                  .map((h) => [
                        h.documentTitle,
                        '${h.reachedPage} / ${h.totalPages}',
                        FormatHelpers114.formatDateTime(h.openedAt),
                      ])
                  .toList(),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> shareBinaryFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String? subject,
  }) async {
    final xfile = XFile.fromData(bytes, name: fileName, mimeType: mimeType);
    await SharePlus.instance.share(
      ShareParams(
        files: [xfile],
        subject: subject ?? fileName,
        text: subject ?? fileName,
      ),
    );
  }

  static Future<void> shareCsvText(String csvContent) async {
    final bytes = Uint8List.fromList(utf8.encode(csvContent));
    await shareBinaryFile(
      bytes: bytes,
      fileName: 'pdf_reader_114_export.csv',
      mimeType: 'text/csv',
      subject: 'PDF Reader 114 Library & Bookmarks CSV Export',
    );
  }

  static Future<bool> launchEmailSummary({
    required List<PdfDocModel114> documents,
    required List<BookmarkItem114> bookmarks,
  }) async {
    final body = StringBuffer()
      ..writeln('PDF Reader 114 - Reading Summary')
      ..writeln('Total Documents: ${documents.length}')
      ..writeln('Saved Bookmarks: ${bookmarks.length}')
      ..writeln('')
      ..writeln('Documents:');
    for (final d in documents.take(10)) {
      body.writeln('- ${d.title} (${d.progressPercent}% read, Page ${d.lastReadPage}/${d.pageCount})');
    }

    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'PDF Reader 114 Library & Reading Progress Summary',
        'body': body.toString(),
      },
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
}
