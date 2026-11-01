import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/emr_models.dart';

class EmrSqliteStore {
  EmrSqliteStore._();

  static final EmrSqliteStore instance = EmrSqliteStore._();
  static Database? _db;

  static const String _patientsPrefKey = 'docpulse_emr_patients_v1';
  static const String _docsPrefKey = 'docpulse_emr_docs_v1';

  static List<EmrPatient> get seedPatients => const [
        EmrPatient(
          id: 1,
          mrnCode: 'MRN-2601',
          fullName: 'Kamran Akmal',
          age: 52,
          gender: 'Male',
          bloodType: 'A+',
          phone: '+92 300 8124490',
          condition: 'Coronary Artery Syndrome',
          priority: 'Urgent',
          vitals: 'BP 146/92 • HR 88 • SpO2 96%',
          clinicalSummary:
              'Scheduled for echocardiography & troponin-I review. Keep on low-dose aspirin & statin.',
        ),
        EmrPatient(
          id: 2,
          mrnCode: 'MRN-2602',
          fullName: 'Farah Deeba',
          age: 31,
          gender: 'Female',
          bloodType: 'O-',
          phone: '+92 334 5591023',
          condition: 'Lumbar Disc Radiculopathy',
          priority: 'Observation',
          vitals: 'BP 118/76 • HR 72 • SpO2 99%',
          clinicalSummary:
              'MRI L4-L5 reviewed. Physiotherapy sessions initiated twice weekly.',
        ),
        EmrPatient(
          id: 3,
          mrnCode: 'MRN-2603',
          fullName: 'Salman Waheed',
          age: 24,
          gender: 'Male',
          bloodType: 'B+',
          phone: '+92 312 6640911',
          condition: 'Post-Viral Fatigue Checkup',
          priority: 'Routine',
          vitals: 'BP 120/78 • HR 70 • SpO2 99%',
          clinicalSummary:
              'Complete blood count within normal limits. Vitamin D supplementation advised.',
        ),
      ];

  static List<EmrDocument> get seedDocuments => const [
        EmrDocument(
          id: 1,
          patientId: 1,
          title: 'Thoracic_CT_Angiogram_Slice.png',
          docFormat: 'IMG',
          tag: 'Radiology',
          fileSize: '1.9 MB',
          dateAdded: '31 Oct 2026',
        ),
        EmrDocument(
          id: 2,
          patientId: 1,
          title: 'Cardiac_Enzyme_Panel_Report.pdf',
          docFormat: 'PDF/DOC',
          tag: 'Pathology',
          fileSize: '390 KB',
          dateAdded: '31 Oct 2026',
        ),
        EmrDocument(
          id: 3,
          patientId: 1,
          title: 'Discharge_Medication_Chart.pdf',
          docFormat: 'PDF/DOC',
          tag: 'Rx Sheet',
          fileSize: '215 KB',
          dateAdded: '30 Oct 2026',
        ),
        EmrDocument(
          id: 4,
          patientId: 2,
          title: 'Lumbar_Spine_MRI_Scan.png',
          docFormat: 'IMG',
          tag: 'Radiology',
          fileSize: '2.2 MB',
          dateAdded: '29 Oct 2026',
        ),
      ];

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getDatabasesPath();
    final path = join(dir, 'docpulse_emr_114.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE emr_patients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mrnCode TEXT NOT NULL,
            fullName TEXT NOT NULL,
            age INTEGER NOT NULL,
            gender TEXT NOT NULL,
            bloodType TEXT NOT NULL,
            phone TEXT NOT NULL,
            condition TEXT NOT NULL,
            priority TEXT NOT NULL,
            vitals TEXT NOT NULL,
            clinicalSummary TEXT NOT NULL,
            photoBase64 TEXT
          )
        ''');

        await database.execute('''
          CREATE TABLE emr_documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patientId INTEGER NOT NULL,
            title TEXT NOT NULL,
            docFormat TEXT NOT NULL,
            tag TEXT NOT NULL,
            fileSize TEXT NOT NULL,
            dateAdded TEXT NOT NULL,
            encodedBytes TEXT
          )
        ''');

        for (final p in seedPatients) {
          final m = p.toMap()..remove('id');
          await database.insert('emr_patients', m);
        }
        for (final d in seedDocuments) {
          final m = d.toMap()..remove('id');
          await database.insert('emr_documents', m);
        }
      },
    );
  }

  Future<List<EmrPatient>> _webPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_patientsPrefKey);
    if (raw == null) {
      await _saveWebPatients(seedPatients);
      await _saveWebDocs(seedDocuments);
      return List<EmrPatient>.from(seedPatients);
    }
    final arr = jsonDecode(raw) as List<dynamic>;
    return arr
        .map((e) => EmrPatient.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveWebPatients(List<EmrPatient> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _patientsPrefKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  Future<List<EmrDocument>> _webDocs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_docsPrefKey);
    if (raw == null) {
      await _saveWebDocs(seedDocuments);
      return List<EmrDocument>.from(seedDocuments);
    }
    final arr = jsonDecode(raw) as List<dynamic>;
    return arr
        .map((e) => EmrDocument.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveWebDocs(List<EmrDocument> docs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _docsPrefKey,
      jsonEncode(docs.map((e) => e.toMap()).toList()),
    );
  }

  Future<int> createPatient(EmrPatient patient) async {
    if (kIsWeb) {
      final list = await _webPatients();
      final nextId = list.isEmpty
          ? 1
          : list.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      list.insert(
        0,
        patient.copyWith(
          id: nextId,
          mrnCode: 'MRN-${2600 + nextId}',
        ),
      );
      await _saveWebPatients(list);
      return nextId;
    }
    final database = await db;
    final map = patient.toMap()..remove('id');
    return database.insert('emr_patients', map);
  }

  Future<List<EmrPatient>> fetchPatients() async {
    if (kIsWeb) return _webPatients();
    final database = await db;
    final rows = await database.query('emr_patients', orderBy: 'id DESC');
    return rows.map(EmrPatient.fromMap).toList();
  }

  Future<int> updatePatient(EmrPatient patient) async {
    if (kIsWeb) {
      final list = await _webPatients();
      final idx = list.indexWhere((e) => e.id == patient.id);
      if (idx == -1) return 0;
      list[idx] = patient;
      await _saveWebPatients(list);
      return 1;
    }
    final database = await db;
    return database.update(
      'emr_patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> removePatient(int id) async {
    if (kIsWeb) {
      final list = await _webPatients();
      list.removeWhere((e) => e.id == id);
      await _saveWebPatients(list);
      final docs = await _webDocs();
      docs.removeWhere((d) => d.patientId == id);
      await _saveWebDocs(docs);
      return 1;
    }
    final database = await db;
    await database.delete(
      'emr_documents',
      where: 'patientId = ?',
      whereArgs: [id],
    );
    return database.delete('emr_patients', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<EmrDocument>> fetchPatientDocs(int patientId) async {
    if (kIsWeb) {
      final docs = await _webDocs();
      return docs.where((d) => d.patientId == patientId).toList();
    }
    final database = await db;
    final rows = await database.query(
      'emr_documents',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'id DESC',
    );
    return rows.map(EmrDocument.fromMap).toList();
  }

  Future<int> countAllDocs() async {
    if (kIsWeb) {
      final docs = await _webDocs();
      return docs.length;
    }
    final database = await db;
    final res = await database.rawQuery('SELECT COUNT(*) as c FROM emr_documents');
    return (res.first['c'] as int?) ?? 0;
  }

  Future<int> attachDocument(EmrDocument doc) async {
    if (kIsWeb) {
      final docs = await _webDocs();
      final nextId = docs.isEmpty
          ? 1
          : docs.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      docs.insert(
        0,
        EmrDocument(
          id: nextId,
          patientId: doc.patientId,
          title: doc.title,
          docFormat: doc.docFormat,
          tag: doc.tag,
          fileSize: doc.fileSize,
          dateAdded: doc.dateAdded,
          encodedBytes: doc.encodedBytes,
        ),
      );
      await _saveWebDocs(docs);
      return nextId;
    }
    final database = await db;
    final map = doc.toMap()..remove('id');
    return database.insert('emr_documents', map);
  }

  Future<int> deleteDocument(int id) async {
    if (kIsWeb) {
      final docs = await _webDocs();
      docs.removeWhere((d) => d.id == id);
      await _saveWebDocs(docs);
      return 1;
    }
    final database = await db;
    return database.delete('emr_documents', where: 'id = ?', whereArgs: [id]);
  }
}
