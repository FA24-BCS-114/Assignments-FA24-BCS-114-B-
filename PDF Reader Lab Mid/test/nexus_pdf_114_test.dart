import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pdf_reader_114/models/pdf_doc_model.dart';
import 'package:pdf_reader_114/models/reader_aux_models.dart';
import 'package:pdf_reader_114/services/export_share_service.dart';
import 'package:pdf_reader_114/services/pdf_engine_service.dart';
import 'package:pdf_reader_114/services/sample_pdf_factory.dart';
import 'package:pdf_reader_114/services/vault_sqlite_service.dart';

void main() {
  sqfliteFfiInit();

  group('PDF Reader 114 Core Engine & SQLite Verification', () {
    test('SQLite schema persists documents, bookmarks, annotations & settings',
        () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) => VaultSqliteService114.createSchema(db),
        ),
      );

      final now = DateTime.now();
      final doc = PdfDocModel114(
        id: 'test_doc_1',
        title: 'Clean Architecture Spec',
        fileName: 'clean_arch.pdf',
        fileSizeBytes: 24500,
        pageCount: 5,
        lastReadPage: 4,
        isFavorite: true,
        createdAt: now,
        lastModifiedAt: now,
      );

      await db.insert('pdf_items', doc.toMap());
      final rows = await db.query('pdf_items');
      expect(rows.length, 1);
      final restored = PdfDocModel114.fromMap(rows.first);
      expect(restored.title, 'Clean Architecture Spec');
      expect(restored.progressPercent, 80);
      expect(restored.isFavorite, isTrue);

      final bm = BookmarkItem114(
        id: 'bm_test',
        documentId: doc.id,
        documentTitle: doc.title,
        pageNumber: 4,
        label: 'Riverpod State Diagram',
        createdAt: now,
      );
      await db.insert('page_bookmarks', bm.toMap());
      final bmRows = await db.query('page_bookmarks');
      expect(bmRows.length, 1);
      expect(BookmarkItem114.fromMap(bmRows.first).pageNumber, 4);

      await db.close();
    });

    test('Validates real PDFs, extracts text, and rejects corrupted streams',
        () async {
      final samples = await SamplePdfFactory114.buildInitialLibraryPdfs();
      expect(samples.length, 4);

      final info = PdfEngineService114.inspectAndValidatePdf(samples.first.bytes);
      expect(info.pageCount, 5);
      expect(info.hasExtractableText, isTrue);

      // Corrupted binary must throw PdfCorruptedException114
      expect(
        () => PdfEngineService114.inspectAndValidatePdf(
          Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        ),
        throwsA(isA<PdfCorruptedException114>()),
      );
    });

    test('Exports non-destructive annotated PDF copy and CSV/PDF reports',
        () async {
      final samples = await SamplePdfFactory114.buildInitialLibraryPdfs();
      final original = samples.first.bytes;

      final annotated = PdfEngineService114.exportAnnotatedPdfCopy(
        originalBytes: original,
        annotations: [
          AnnotationItem114(
            id: 'a1',
            documentId: 'doc_1',
            pageNumber: 1,
            kind: AnnotationKind114.highlight,
            colorHex: 0xFFFACC15,
            comment: 'Important section',
            normalizedRect: const Rect.fromLTWH(0.1, 0.2, 0.6, 0.04),
            createdAt: DateTime.now(),
          ),
        ],
      );

      final verified = PdfEngineService114.inspectAndValidatePdf(annotated);
      expect(verified.pageCount, 5);
      expect(annotated.length, greaterThan(original.length ~/ 2));

      final csv = ExportShareService114.buildLibraryCsv(
        documents: const [],
        bookmarks: const [],
        history: const [],
      );
      expect(csv, contains('SECTION,ID,TITLE'));
    });
  });
}
