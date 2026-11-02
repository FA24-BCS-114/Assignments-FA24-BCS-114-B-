import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pdf_doc_model.dart';
import '../models/reader_aux_models.dart';
import 'sample_pdf_factory.dart';

class VaultSqliteService114 {
  VaultSqliteService114._();
  static final VaultSqliteService114 instance = VaultSqliteService114._();

  Database? _db;
  bool _seeded = false;

  static const String _kWebDocs = 'nexus114_docs_v1';
  static const String _kWebBookmarks = 'nexus114_bookmarks_v1';
  static const String _kWebAnnotations = 'nexus114_annotations_v1';
  static const String _kWebFolders = 'nexus114_folders_v1';
  static const String _kWebHistory = 'nexus114_history_v1';
  static const String _kWebSettings = 'nexus114_settings_v1';

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbDir = await getDatabasesPath();
    final fullPath = p.join(dbDir, 'nexus_pdf_reader_114.db');
    _db = await openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        await createSchema(db);
      },
    );
    return _db!;
  }

  static Future<void> createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE pdf_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT,
        pdf_base64 TEXT,
        file_size_bytes INTEGER NOT NULL,
        page_count INTEGER NOT NULL,
        last_read_page INTEGER NOT NULL DEFAULT 1,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_scanned INTEGER NOT NULL DEFAULT 0,
        folder_id TEXT NOT NULL DEFAULT 'all',
        tags TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        last_modified_at TEXT NOT NULL,
        last_opened_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE page_bookmarks (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        document_title TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        label TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pdf_annotations (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        kind TEXT NOT NULL,
        color_hex INTEGER NOT NULL,
        comment TEXT NOT NULL DEFAULT '',
        points_json TEXT,
        rect_json TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE doc_folders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_hex INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE read_sessions (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        document_title TEXT NOT NULL,
        reached_page INTEGER NOT NULL,
        total_pages INTEGER NOT NULL,
        opened_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        pref_key TEXT PRIMARY KEY,
        pref_value TEXT NOT NULL
      )
    ''');
  }

  Future<void> ensureInitializedAndSeeded() async {
    if (_seeded) return;
    final existing = await fetchDocuments();
    if (existing.isNotEmpty) {
      _seeded = true;
      return;
    }

    final now = DateTime.now();
    final defaultFolders = [
      FolderItem114(
        id: 'fld_cs',
        name: 'Computer Science',
        colorHex: 0xFF2563EB,
        createdAt: now,
      ),
      FolderItem114(
        id: 'fld_scans',
        name: 'Scanned Sheets',
        colorHex: 0xFF22D3EE,
        createdAt: now,
      ),
      FolderItem114(
        id: 'fld_research',
        name: 'Security & Systems',
        colorHex: 0xFF10B981,
        createdAt: now,
      ),
    ];
    for (final f in defaultFolders) {
      await upsertFolder(f);
    }

    final samples = await SamplePdfFactory114.buildInitialLibraryPdfs();
    for (var i = 0; i < samples.length; i++) {
      final s = samples[i];
      final doc = PdfDocModel114(
        id: s.id,
        title: s.title,
        fileName: s.fileName,
        pdfBase64: base64Encode(s.bytes),
        fileSizeBytes: s.bytes.length,
        pageCount: s.pageCount,
        lastReadPage: s.lastReadPage,
        isFavorite: s.isFavorite,
        isScanned: s.isScanned,
        folderId: s.folderId,
        tags: s.tags,
        description: s.description,
        createdAt: now.subtract(Duration(days: 5 - i)),
        lastModifiedAt: now.subtract(Duration(hours: 6 * (i + 1))),
        lastOpenedAt: now.subtract(Duration(hours: 2 * (i + 1))),
      );
      await upsertDocument(doc);
      await recordHistory(
        HistoryEntry114(
          id: 'hist_seed_$i',
          documentId: doc.id,
          documentTitle: doc.title,
          reachedPage: doc.lastReadPage,
          totalPages: doc.pageCount,
          openedAt: doc.lastOpenedAt!,
        ),
      );
    }

    await upsertBookmark(
      BookmarkItem114(
        id: 'bm_114_1',
        documentId: 'doc_114_arch',
        documentTitle: 'Nexus Flutter Clean Architecture 114',
        pageNumber: 3,
        label: 'Riverpod StateNotifier Graph',
        note: 'Important diagram & explanation for Lab Mid viva.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    );
    await upsertBookmark(
      BookmarkItem114(
        id: 'bm_114_2',
        documentId: 'doc_114_sqlite',
        documentTitle: 'SQLite Storage & Indexing Handbook',
        pageNumber: 2,
        label: 'Composite B-Tree Index Benchmark',
        note: 'Review query latency metrics.',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    );

    await upsertAnnotation(
      AnnotationItem114(
        id: 'ann_114_1',
        documentId: 'doc_114_arch',
        pageNumber: 1,
        kind: AnnotationKind114.highlight,
        colorHex: 0xFFFACC15,
        comment: 'Core Clean Architecture definition',
        normalizedRect: const Rect.fromLTWH(0.08, 0.25, 0.78, 0.045),
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    );
    await upsertAnnotation(
      AnnotationItem114(
        id: 'ann_114_2',
        documentId: 'doc_114_arch',
        pageNumber: 1,
        kind: AnnotationKind114.note,
        colorHex: 0xFF22D3EE,
        comment: 'Demonstrate non-destructive PDF export in viva!',
        normalizedRect: const Rect.fromLTWH(0.82, 0.42, 0.08, 0.05),
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    );

    _seeded = true;
  }

  // ==================== DOCUMENTS ====================
  Future<List<PdfDocModel114>> fetchDocuments() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kWebDocs);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PdfDocModel114.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final db = await database;
    final rows = await db.query('pdf_items', orderBy: 'created_at DESC');
    return rows.map(PdfDocModel114.fromMap).toList();
  }

  Future<void> upsertDocument(PdfDocModel114 doc) async {
    if (kIsWeb) {
      final list = await fetchDocuments();
      final idx = list.indexWhere((d) => d.id == doc.id);
      if (idx >= 0) {
        list[idx] = doc;
      } else {
        list.insert(0, doc);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kWebDocs,
        jsonEncode(list.map((e) => e.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.insert(
      'pdf_items',
      doc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDocument(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = await fetchDocuments()
        ..removeWhere((d) => d.id == id);
      await prefs.setString(
        _kWebDocs,
        jsonEncode(list.map((e) => e.toMap()).toList()),
      );
      final bms = await fetchBookmarks()
        ..removeWhere((b) => b.documentId == id);
      await prefs.setString(
        _kWebBookmarks,
        jsonEncode(bms.map((e) => e.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.delete('pdf_items', where: 'id = ?', whereArgs: [id]);
    await db.delete('page_bookmarks', where: 'document_id = ?', whereArgs: [id]);
    await db.delete('pdf_annotations', where: 'document_id = ?', whereArgs: [id]);
  }

  // ==================== BOOKMARKS ====================
  Future<List<BookmarkItem114>> fetchBookmarks() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kWebBookmarks);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => BookmarkItem114.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final db = await database;
    final rows = await db.query('page_bookmarks', orderBy: 'created_at DESC');
    return rows.map(BookmarkItem114.fromMap).toList();
  }

  Future<void> upsertBookmark(BookmarkItem114 bm) async {
    if (kIsWeb) {
      final list = await fetchBookmarks();
      final idx = list.indexWhere((e) => e.id == bm.id);
      if (idx >= 0) {
        list[idx] = bm;
      } else {
        list.insert(0, bm);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kWebBookmarks,
        jsonEncode(list.map((e) => e.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.insert(
      'page_bookmarks',
      bm.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBookmark(String id) async {
    if (kIsWeb) {
      final list = await fetchBookmarks()
        ..removeWhere((e) => e.id == id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kWebBookmarks,
        jsonEncode(list.map((e) => e.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.delete('page_bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ANNOTATIONS ====================
  Future<List<AnnotationItem114>> fetchAnnotations(String documentId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kWebAnnotations);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AnnotationItem114.fromMap(Map<String, dynamic>.from(e as Map)))
          .where((a) => a.documentId == documentId)
          .toList();
    }
    final db = await database;
    final rows = await db.query(
      'pdf_annotations',
      where: 'document_id = ?',
      whereArgs: [documentId],
      orderBy: 'created_at ASC',
    );
    return rows.map(AnnotationItem114.fromMap).toList();
  }

  Future<void> upsertAnnotation(AnnotationItem114 ann) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kWebAnnotations);
      final list = raw == null
          ? <AnnotationItem114>[]
          : (jsonDecode(raw) as List<dynamic>)
              .map((e) => AnnotationItem114.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();
      final idx = list.indexWhere((e) => e.id == ann.id);
      if (idx >= 0) {
        list[idx] = ann;
      } else {
        list.add(ann);
      }
      await prefs.setString(
        _kWebAnnotations,
        jsonEncode(list.map((e) => e.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.insert(
      'pdf_annotations',
      ann.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAnnotation(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kWebAnnotations);
      if (raw == null) return;
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => AnnotationItem114.fromMap(Map<String, dynamic>.from(e as Map)))
          .where((e) => e.id != id)
          .toList();
      await prefs.setString(
        _kWebAnnotations,
        jsonEncode(list.map((e) => e.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.delete('pdf_annotations', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== FOLDERS ====================
  Future<List<FolderItem114>> fetchFolders() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kWebFolders);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FolderItem114.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final db = await database;
    final rows = await db.query('doc_folders', orderBy: 'created_at ASC');
    return rows.map(FolderItem114.fromMap).toList();
  }

  Future<void> upsertFolder(FolderItem114 folder) async {
    if (kIsWeb) {
      final list = await fetchFolders();
      final idx = list.indexWhere((f) => f.id == folder.id);
      if (idx >= 0) {
        list[idx] = folder;
      } else {
        list.add(folder);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kWebFolders,
        jsonEncode(list.map((e) => e.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.insert(
      'doc_folders',
      folder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== HISTORY ====================
  Future<List<HistoryEntry114>> fetchHistory() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kWebHistory);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => HistoryEntry114.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final db = await database;
    final rows = await db.query('read_sessions', orderBy: 'opened_at DESC', limit: 40);
    return rows.map(HistoryEntry114.fromMap).toList();
  }

  Future<void> recordHistory(HistoryEntry114 entry) async {
    if (kIsWeb) {
      final list = await fetchHistory();
      list.removeWhere((e) => e.documentId == entry.documentId);
      list.insert(0, entry);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kWebHistory,
        jsonEncode(list.take(40).map((e) => e.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.insert(
      'read_sessions',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearHistory() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kWebHistory);
      return;
    }
    final db = await database;
    await db.delete('read_sessions');
  }

  // ==================== SETTINGS ====================
  Future<ReaderSettings114> loadSettings() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kWebSettings);
      if (raw == null) return const ReaderSettings114();
      final map = Map<String, String>.from(jsonDecode(raw) as Map);
      return ReaderSettings114.fromPrefEntries(map);
    }
    final db = await database;
    final rows = await db.query('app_settings');
    if (rows.isEmpty) return const ReaderSettings114();
    final map = <String, String>{};
    for (final r in rows) {
      map[r['pref_key'] as String] = r['pref_value'] as String;
    }
    return ReaderSettings114.fromPrefEntries(map);
  }

  Future<void> saveSettings(ReaderSettings114 settings) async {
    final entries = settings.toPrefEntries();
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kWebSettings, jsonEncode(entries));
      return;
    }
    final db = await database;
    final batch = db.batch();
    entries.forEach((k, v) {
      batch.insert(
        'app_settings',
        {'pref_key': k, 'pref_value': v},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }
}
