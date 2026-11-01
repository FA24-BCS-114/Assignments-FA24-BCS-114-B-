import 'dart:convert';
import 'package:flutter/material.dart';

import '../database/sqlite_manager.dart';
import '../models/person_record.dart';
import 'record_form_screen.dart';

class RosterScreen extends StatefulWidget {
  final bool showDeletePromptOnLoad;

  const RosterScreen({super.key, this.showDeletePromptOnLoad = false});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  List<PersonRecord> _records = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rows = await SqliteManager.instance.fetchRecords();
    if (!mounted) return;
    setState(() {
      _records = rows;
      _loading = false;
    });

    if (widget.showDeletePromptOnLoad && _records.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _promptDelete(_records.first);
      });
    }
  }

  List<PersonRecord> get _visibleRecords {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _records;
    return _records.where((r) {
      return r.fullName.toLowerCase().contains(q) ||
          r.email.toLowerCase().contains(q) ||
          r.roleTag.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _launchAdd() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RecordFormScreen()),
    );
    if (saved == true) await _loadData();
  }

  Future<void> _launchEdit(PersonRecord record) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecordFormScreen(existingRecord: record),
      ),
    );
    if (saved == true) await _loadData();
  }

  Future<void> _promptDelete(PersonRecord record) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Text(
              'Confirm Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Delete "${record.fullName}" (Age ${record.age}, ${record.email}) '
          'from local SQLite storage? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFFCBD5E1), height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Record',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Delete Now'),
          ),
        ],
      ),
    );

    if (remove == true && record.id != null) {
      await SqliteManager.instance.deleteRecord(record.id!);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgAge = _records.isEmpty
        ? 0
        : (_records.map((e) => e.age).reduce((a, b) => a + b) / _records.length)
            .toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Obsidian-Emerald Hero Command Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PulseRoster Studio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'SQLite Offline Engine • Harry (FA24-BCS-114)',
                            style: TextStyle(
                              color: Color(0xFF6EE7B7),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.45),
                          ),
                        ),
                        child: const Icon(
                          Icons.dns_rounded,
                          color: Color(0xFF34D399),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiTile(
                          'SAVED ENTRIES',
                          '${_records.length}',
                          Icons.people_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiTile(
                          'MEAN AGE',
                          '$avgAge Yrs',
                          Icons.analytics_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Filter SQLite entries by name, email, role...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF34D399),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.09),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Records List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _visibleRecords.isEmpty
                      ? const Center(
                          child: Text('No entries found in SQLite table.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                          itemCount: _visibleRecords.length,
                          itemBuilder: (ctx, idx) {
                            return _buildRecordTile(_visibleRecords[idx]);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        onPressed: _launchAdd,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add New Entry',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3),
        ),
      ),
    );
  }

  Widget _buildKpiTile(String title, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFBBF24), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                val,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTile(PersonRecord r) {
    final letter = r.fullName.isEmpty ? '?' : r.fullName[0].toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: Color(r.badgeColor),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(r.badgeColor),
                      backgroundImage:
                          r.photoBase64 != null && r.photoBase64!.isNotEmpty
                              ? MemoryImage(base64Decode(r.photoBase64!))
                              : null,
                      child: (r.photoBase64 == null || r.photoBase64!.isEmpty)
                          ? Text(
                              letter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.fullName,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              _miniChip(
                                '${r.age} yrs',
                                const Color(0xFFECFDF5),
                                const Color(0xFF047857),
                              ),
                              _miniChip(
                                r.gender,
                                const Color(0xFFF1F5F9),
                                const Color(0xFF334155),
                              ),
                              _miniChip(
                                r.roleTag,
                                const Color(0xFFFEF3C7),
                                const Color(0xFFB45309),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _launchEdit(r),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: Color(0xFFB45309),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _promptDelete(r),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 14,
                                  color: Color(0xFFBE123C),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Del',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFBE123C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
