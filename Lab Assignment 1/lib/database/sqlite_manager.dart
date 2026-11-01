import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/person_record.dart';

class SqliteManager {
  SqliteManager._();

  static final SqliteManager instance = SqliteManager._();
  static Database? _db;
  static const String _webKey = 'pulse_roster_entries_v1';

  static List<PersonRecord> get starterRecords => const [
        PersonRecord(
          id: 1,
          fullName: 'Harry',
          email: 'harry114@gmail.com',
          age: 20,
          gender: 'Male',
          roleTag: 'Lead Developer',
          badgeColor: 0xFF059669,
        ),
        PersonRecord(
          id: 2,
          fullName: 'Usman Raza',
          email: 'usman.raza@cuivehari.edu.pk',
          age: 22,
          gender: 'Male',
          roleTag: 'Systems Analyst',
          badgeColor: 0xFFD97706,
        ),
        PersonRecord(
          id: 3,
          fullName: 'Zara Noor',
          email: 'zara.noor@gmail.com',
          age: 21,
          gender: 'Female',
          roleTag: 'UI Architect',
          badgeColor: 0xFF0284C7,
        ),
      ];

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final folder = await getDatabasesPath();
    final fullPath = join(folder, 'pulse_roster_114.db');

    return openDatabase(
      fullPath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE person_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT NOT NULL,
            email TEXT NOT NULL,
            age INTEGER NOT NULL,
            gender TEXT NOT NULL,
            roleTag TEXT NOT NULL,
            photoBase64 TEXT,
            badgeColor INTEGER NOT NULL
          )
        ''');

        for (final entry in starterRecords) {
          final row = entry.toMap()..remove('id');
          await database.insert('person_records', row);
        }
      },
    );
  }

  Future<List<PersonRecord>> _readWebStore() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonText = prefs.getString(_webKey);
    if (jsonText == null) {
      await _writeWebStore(starterRecords);
      return List<PersonRecord>.from(starterRecords.reversed);
    }
    final rawList = jsonDecode(jsonText) as List<dynamic>;
    final mapped = rawList
        .map((e) => PersonRecord.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    mapped.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return mapped;
  }

  Future<void> _writeWebStore(List<PersonRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _webKey,
      jsonEncode(records.map((r) => r.toMap()).toList()),
    );
  }

  Future<int> addRecord(PersonRecord record) async {
    if (kIsWeb) {
      final current = await _readWebStore();
      final nextId = current.isEmpty
          ? 1
          : current.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      current.add(record.copyWith(id: nextId));
      await _writeWebStore(current);
      return nextId;
    }
    final database = await db;
    final data = record.toMap()..remove('id');
    return database.insert('person_records', data);
  }

  Future<List<PersonRecord>> fetchRecords() async {
    if (kIsWeb) return _readWebStore();
    final database = await db;
    final rows = await database.query('person_records', orderBy: 'id DESC');
    return rows.map(PersonRecord.fromMap).toList();
  }

  Future<int> updateRecord(PersonRecord record) async {
    if (kIsWeb) {
      final current = await _readWebStore();
      final index = current.indexWhere((e) => e.id == record.id);
      if (index == -1) return 0;
      current[index] = record;
      await _writeWebStore(current);
      return 1;
    }
    final database = await db;
    return database.update(
      'person_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    if (kIsWeb) {
      final current = await _readWebStore();
      current.removeWhere((e) => e.id == id);
      await _writeWebStore(current);
      return 1;
    }
    final database = await db;
    return database.delete('person_records', where: 'id = ?', whereArgs: [id]);
  }
}
