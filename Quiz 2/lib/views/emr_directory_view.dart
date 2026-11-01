import 'dart:convert';
import 'package:flutter/material.dart';

import '../data/emr_sqlite_store.dart';
import '../models/emr_models.dart';
import 'emr_chart_vault_view.dart';
import 'emr_patient_editor_view.dart';

class EmrDirectoryView extends StatefulWidget {
  final bool triggerRemoveModalOnOpen;

  const EmrDirectoryView({super.key, this.triggerRemoveModalOnOpen = false});

  @override
  State<EmrDirectoryView> createState() => _EmrDirectoryViewState();
}

class _EmrDirectoryViewState extends State<EmrDirectoryView> {
  List<EmrPatient> _patients = [];
  int _docCount = 0;
  bool _loading = true;
  String _search = '';
  String _priorityFilter = 'All';

  final List<String> _filters = const [
    'All',
    'Urgent',
    'Observation',
    'Routine',
  ];

  @override
  void initState() {
    super.initState();
    _syncEmr();
  }

  Future<void> _syncEmr() async {
    final pts = await EmrSqliteStore.instance.fetchPatients();
    final docs = await EmrSqliteStore.instance.countAllDocs();
    if (!mounted) return;
    setState(() {
      _patients = pts;
      _docCount = docs;
      _loading = false;
    });

    if (widget.triggerRemoveModalOnOpen && _patients.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _confirmRemove(_patients.first);
      });
    }
  }

  List<EmrPatient> get _displayed {
    return _patients.where((p) {
      final byPriority =
          _priorityFilter == 'All' || p.priority == _priorityFilter;
      final q = _search.trim().toLowerCase();
      final byQuery = q.isEmpty ||
          p.fullName.toLowerCase().contains(q) ||
          p.mrnCode.toLowerCase().contains(q) ||
          p.condition.toLowerCase().contains(q);
      return byPriority && byQuery;
    }).toList();
  }

  Color _priorityAccent(String priority) {
    switch (priority) {
      case 'Urgent':
        return const Color(0xFFE11D48);
      case 'Observation':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  Future<void> _goAdmit() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EmrPatientEditorView()),
    );
    if (saved == true) await _syncEmr();
  }

  Future<void> _goEdit(EmrPatient p) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EmrPatientEditorView(existing: p)),
    );
    if (saved == true) await _syncEmr();
  }

  Future<void> _goVault(EmrPatient p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EmrChartVaultView(patient: p)),
    );
    await _syncEmr();
  }

  Future<void> _confirmRemove(EmrPatient p) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: Color(0xFFF43F5E)),
            SizedBox(width: 10),
            Text(
              'Archive & Delete Chart?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17.5,
              ),
            ),
          ],
        ),
        content: Text(
          'Permanently delete EMR chart ${p.mrnCode} for "${p.fullName}" '
          'along with attached radiology/lab files from SQLite?',
          style: const TextStyle(color: Color(0xFFCBD5E1), height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Retain Chart',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );

    if (remove == true && p.id != null) {
      await EmrSqliteStore.instance.removePatient(p.id!);
      await _syncEmr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgentCount =
        _patients.where((p) => p.priority == 'Urgent').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Executive Dark-Navy Clinical Command Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
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
                            'DocPulse EMR Suite',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Dr. Harry • Clinical SQLite Workstation (114)',
                            style: TextStyle(
                              color: Color(0xFFA5B4FC),
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
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
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
                        child: _emrStat('Active Charts', '${_patients.length}'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _emrStat('Urgent Cases', '$urgentCount'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _emrStat('Vault Files', '$_docCount'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Search by patient name, MRN code, condition...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF818CF8),
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
            const SizedBox(height: 10),

            // Priority Filter Bar
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, idx) {
                  final f = _filters[idx];
                  final selected = _priorityFilter == f;
                  return ChoiceChip(
                    label: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                    selected: selected,
                    selectedColor: const Color(0xFF4F46E5),
                    backgroundColor: Colors.white,
                    onSelected: (_) => setState(() => _priorityFilter = f),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // EMR Cards
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                      itemCount: _displayed.length,
                      itemBuilder: (ctx, i) => _buildEmrCard(_displayed[i]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        onPressed: _goAdmit,
        icon: const Icon(Icons.add_box_rounded),
        label: const Text(
          'Admit New Patient',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _emrStat(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA5B4FC),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmrCard(EmrPatient p) {
    final accent = _priorityAccent(p.priority);
    return GestureDetector(
      onTap: () => _goVault(p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFFEEF2FF),
                  backgroundImage: p.photoBase64 != null
                      ? MemoryImage(base64Decode(p.photoBase64!))
                      : null,
                  child: p.photoBase64 == null
                      ? Text(
                          p.fullName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF3730A3),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.fullName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p.mrnCode,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.age}y • ${p.gender} • Blood ${p.bloodType}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    p.priority,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              p.condition,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              p.vitals,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669),
              ),
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _goVault(p),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.folder_special_outlined,
                        size: 17,
                        color: Color(0xFF4F46E5),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Open Document & Scan Vault',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _goEdit(p),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _confirmRemove(p),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
