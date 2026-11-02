import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../models/pdf_doc_model.dart';
import '../models/reader_aux_models.dart';
import '../services/pdf_engine_service.dart';
import '../services/sample_pdf_factory.dart';
import '../services/vault_sqlite_service.dart';
import '../utils/file_bytes_loader.dart';

class ImportSummary114 {
  final List<PdfDocModel114> imported;
  final List<String> errors;

  const ImportSummary114({
    required this.imported,
    required this.errors,
  });
}

class DocumentRepository114 {
  final VaultSqliteService114 _vault;

  const DocumentRepository114(this._vault);

  Future<void> initialize() => _vault.ensureInitializedAndSeeded();

  Future<List<PdfDocModel114>> getDocuments() => _vault.fetchDocuments();
  Future<List<FolderItem114>> getFolders() => _vault.fetchFolders();
  Future<List<BookmarkItem114>> getBookmarks() => _vault.fetchBookmarks();
  Future<List<HistoryEntry114>> getHistory() => _vault.fetchHistory();
  Future<ReaderSettings114> getSettings() => _vault.loadSettings();
  Future<void> saveSettings(ReaderSettings114 s) => _vault.saveSettings(s);

  Future<List<AnnotationItem114>> getAnnotationsForDoc(String docId) =>
      _vault.fetchAnnotations(docId);

  Future<void> saveAnnotation(AnnotationItem114 item) =>
      _vault.upsertAnnotation(item);

  Future<void> removeAnnotation(String id) => _vault.deleteAnnotation(id);

  /// Imports single or multiple PDFs from device storage / Downloads via native FilePicker
  Future<ImportSummary114> pickAndImportPdfs({
    bool allowMultiple = true,
    String targetFolderId = 'all',
  }) async {
    final res = await FilePicker.pickFiles(
      dialogTitle: 'Select PDF Document(s) for PDF Reader 114',
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: allowMultiple,
      withData: true,
    );

    if (res == null || res.files.isEmpty) {
      return const ImportSummary114(imported: [], errors: []);
    }

    final imported = <PdfDocModel114>[];
    final errors = <String>[];

    for (final pf in res.files) {
      try {
        Uint8List? bytes = pf.bytes;
        if (bytes == null && pf.path != null) {
          bytes = await readLocalFileBytes114(pf.path!);
        }
        if (bytes == null || bytes.isEmpty) {
          errors.add('${pf.name}: Could not read file bytes from storage.');
          continue;
        }
        final doc = await importRawPdfBytes(
          bytes: bytes,
          fileName: pf.name,
          filePath: pf.path,
          folderId: targetFolderId,
        );
        imported.add(doc);
      } on PdfCorruptedException114 catch (e) {
        errors.add('${pf.name}: ${e.message}');
      } catch (e) {
        errors.add('${pf.name}: Unexpected import error ($e)');
      }
    }

    return ImportSummary114(imported: imported, errors: errors);
  }

  /// Validates and indexes raw PDF bytes directly into SQLite
  Future<PdfDocModel114> importRawPdfBytes({
    required Uint8List bytes,
    required String fileName,
    String? customTitle,
    String? filePath,
    String folderId = 'all',
    String tags = 'Imported, PDF',
    String description = '',
    bool isScanned = false,
  }) async {
    final inspection = PdfEngineService114.inspectAndValidatePdf(bytes);
    final now = DateTime.now();
    final cleanTitle = customTitle?.trim().isNotEmpty == true
        ? customTitle!.trim()
        : fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '').replaceAll('_', ' ');

    final doc = PdfDocModel114(
      id: 'doc_${now.microsecondsSinceEpoch}',
      title: cleanTitle,
      fileName: fileName.endsWith('.pdf') ? fileName : '$fileName.pdf',
      filePath: filePath,
      pdfBase64: base64Encode(bytes),
      fileSizeBytes: bytes.length,
      pageCount: inspection.pageCount,
      lastReadPage: 1,
      isFavorite: false,
      isScanned: isScanned,
      folderId: folderId,
      tags: tags,
      description: description.isNotEmpty ? description : inspection.previewSnippet,
      createdAt: now,
      lastModifiedAt: now,
      lastOpenedAt: now,
    );

    await _vault.upsertDocument(doc);
    return doc;
  }

  Future<PdfDocModel114> updateMetadata({
    required PdfDocModel114 doc,
    required String newTitle,
    required String newTags,
    required String newDescription,
    required String folderId,
  }) async {
    final cleanName = newTitle.trim().replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final updated = doc.copyWith(
      title: newTitle.trim().isEmpty ? doc.title : newTitle.trim(),
      fileName: '${cleanName.isEmpty ? 'Document' : cleanName}.pdf',
      tags: newTags.trim(),
      description: newDescription.trim(),
      folderId: folderId,
      lastModifiedAt: DateTime.now(),
    );
    await _vault.upsertDocument(updated);
    return updated;
  }

  Future<PdfDocModel114> duplicateDocument(PdfDocModel114 source) async {
    final now = DateTime.now();
    final copy = source.copyWith(
      id: 'doc_copy_${now.microsecondsSinceEpoch}',
      title: '${source.title} (Copy)',
      fileName: source.fileName.replaceAll('.pdf', '_copy.pdf'),
      createdAt: now,
      lastModifiedAt: now,
      isFavorite: false,
    );
    await _vault.upsertDocument(copy);
    return copy;
  }

  Future<PdfDocModel114> toggleFavorite(PdfDocModel114 doc) async {
    final updated = doc.copyWith(
      isFavorite: !doc.isFavorite,
      lastModifiedAt: DateTime.now(),
    );
    await _vault.upsertDocument(updated);
    return updated;
  }

  Future<PdfDocModel114> recordReadingProgress({
    required PdfDocModel114 doc,
    required int pageNumber,
  }) async {
    final clamped = pageNumber.clamp(1, doc.pageCount);
    final now = DateTime.now();
    final updated = doc.copyWith(
      lastReadPage: clamped,
      lastOpenedAt: now,
    );
    await _vault.upsertDocument(updated);
    await _vault.recordHistory(
      HistoryEntry114(
        id: 'hist_${doc.id}_${now.millisecondsSinceEpoch}',
        documentId: doc.id,
        documentTitle: doc.title,
        reachedPage: clamped,
        totalPages: doc.pageCount,
        openedAt: now,
      ),
    );
    return updated;
  }

  Future<void> deleteDocument(String id) => _vault.deleteDocument(id);

  Future<BookmarkItem114> addBookmark({
    required PdfDocModel114 doc,
    required int pageNumber,
    required String label,
    String note = '',
  }) async {
    final bm = BookmarkItem114(
      id: 'bm_${DateTime.now().microsecondsSinceEpoch}',
      documentId: doc.id,
      documentTitle: doc.title,
      pageNumber: pageNumber,
      label: label.trim().isEmpty ? 'Page $pageNumber Bookmark' : label.trim(),
      note: note.trim(),
      createdAt: DateTime.now(),
    );
    await _vault.upsertBookmark(bm);
    return bm;
  }

  Future<void> deleteBookmark(String id) => _vault.deleteBookmark(id);

  Future<FolderItem114> createFolder({
    required String name,
    required int colorHex,
  }) async {
    final folder = FolderItem114(
      id: 'fld_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      colorHex: colorHex,
      createdAt: DateTime.now(),
    );
    await _vault.upsertFolder(folder);
    return folder;
  }

  /// Saves an annotated PDF as a brand-new PDF document in the library (preserving original untouched!)
  Future<PdfDocModel114> saveAnnotatedCopy({
    required PdfDocModel114 originalDoc,
    required List<AnnotationItem114> annotations,
  }) async {
    final raw = await PdfEngineService114.resolveDocumentBytes(originalDoc);
    final annotatedBytes = PdfEngineService114.exportAnnotatedPdfCopy(
      originalBytes: raw,
      annotations: annotations,
    );
    return importRawPdfBytes(
      bytes: annotatedBytes,
      fileName: originalDoc.fileName.replaceAll('.pdf', '_annotated.pdf'),
      customTitle: '${originalDoc.title} (Annotated)',
      folderId: originalDoc.folderId,
      tags: '${originalDoc.tags}, Annotated',
      description:
          'Annotated copy preserving ${annotations.length} markup item(s) exported from ${originalDoc.title}.',
    );
  }

  /// Compiles enhanced camera/scanner images into a multi-page PDF and stores in SQLite
  Future<PdfDocModel114> saveScannedPdfToLibrary({
    required String title,
    required List<Uint8List> processedPages,
  }) async {
    final pdfBytes = await SamplePdfFactory114.buildPdfFromScannedImages(
      title: title,
      pageImages: processedPages,
    );
    return importRawPdfBytes(
      bytes: pdfBytes,
      fileName: '${title.replaceAll(' ', '_')}.pdf',
      customTitle: title,
      folderId: 'fld_scans',
      tags: 'Scanned, CyberScan, Camera',
      description:
          'Created with CyberScan 114 (${processedPages.length} enhanced page(s)).',
      isScanned: true,
    );
  }

  Future<void> clearReadingHistory() => _vault.clearHistory();
}
