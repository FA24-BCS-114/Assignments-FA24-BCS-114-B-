import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../providers/nexus_providers.dart';
import '../services/export_share_service.dart';
import '../utils/format_helpers.dart';
import '../widgets/doc_dialogs_114.dart';

class SettingsControlScreen114 extends ConsumerWidget {
  const SettingsControlScreen114({super.key});

  Future<bool> _confirmDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String actionLabel,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppConstants114.dangerRose,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    return res == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(nexusWorkspaceProvider);
    final notifier = ref.read(nexusWorkspaceProvider.notifier);
    final prefs = ws.settings;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings, Alerts & Export Center',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),

          // 1. APPEARANCE & READING PREFERENCES
          _groupCard(
            title: 'Appearance & Default Reading Engine',
            icon: Icons.palette_outlined,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Nexus Cyber Dark Theme'),
                subtitle: const Text(
                  'Toggle between signature Deep Navy Dark UI and Light UI',
                ),
                value: prefs.darkAppTheme,
                activeColor: AppConstants114.accentCyan,
                onChanged: (v) =>
                    notifier.updateSettings(prefs.copyWith(darkAppTheme: v)),
              ),
              const Divider(height: 18),
              DropdownButtonFormField<String>(
                value: prefs.languageCode,
                decoration: const InputDecoration(
                  labelText: 'Interface Language',
                  prefixIcon: Icon(Icons.translate_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(
                    value: 'Urdu (Roman)',
                    child: Text('Urdu (Roman)'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    notifier.updateSettings(prefs.copyWith(languageCode: v));
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: prefs.defaultReadingTone,
                decoration: const InputDecoration(
                  labelText: 'Default PDF Reading Mode',
                  prefixIcon: Icon(Icons.chrome_reader_mode_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'dark', child: Text('Cyber Dark Mode')),
                  DropdownMenuItem(
                    value: 'midnight',
                    child: Text('OLED Midnight Mode'),
                  ),
                  DropdownMenuItem(value: 'paper', child: Text('Paper Light Mode')),
                  DropdownMenuItem(value: 'sepia', child: Text('Warm Sepia Mode')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    notifier.updateSettings(
                      prefs.copyWith(defaultReadingTone: v),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Default Zoom Scale',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${(prefs.defaultZoom * 100).round()}%',
                    style: const TextStyle(
                      color: AppConstants114.accentCyan,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: prefs.defaultZoom.clamp(0.75, 2.0),
                min: 0.75,
                max: 2.0,
                divisions: 5,
                activeColor: AppConstants114.accentCyan,
                onChanged: (v) =>
                    notifier.updateSettings(prefs.copyWith(defaultZoom: v)),
              ),
              DropdownButtonFormField<String>(
                value: prefs.orientationLock,
                decoration: const InputDecoration(
                  labelText: 'Screen Orientation Preference',
                  prefixIcon: Icon(Icons.screen_rotation_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'auto', child: Text('Auto-Rotate')),
                  DropdownMenuItem(
                    value: 'portrait',
                    child: Text('Portrait Preferred'),
                  ),
                  DropdownMenuItem(
                    value: 'landscape',
                    child: Text('Landscape Preferred'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    notifier.updateSettings(prefs.copyWith(orientationLock: v));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. NOTIFICATIONS & READING GOALS
          _groupCard(
            title: 'Reading Goals & Notification Sounds',
            icon: Icons.notifications_active_outlined,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Reading Goal Reminders'),
                subtitle: Text(
                  'Daily target: ${prefs.dailyGoalMinutes} min (${prefs.completedMinutesToday} min completed today)',
                ),
                value: prefs.remindersEnabled,
                activeColor: AppConstants114.accentCyan,
                onChanged: (v) =>
                    notifier.updateSettings(prefs.copyWith(remindersEnabled: v)),
              ),
              Slider(
                value: prefs.dailyGoalMinutes.clamp(10, 120).toDouble(),
                min: 10,
                max: 120,
                divisions: 11,
                label: '${prefs.dailyGoalMinutes} min',
                activeColor: AppConstants114.secondaryBlue,
                onChanged: (v) => notifier.updateSettings(
                  prefs.copyWith(dailyGoalMinutes: v.round()),
                ),
              ),
              DropdownButtonFormField<String>(
                value: AppConstants114.notificationSounds
                        .contains(prefs.notificationSound)
                    ? prefs.notificationSound
                    : AppConstants114.notificationSounds.first,
                decoration: const InputDecoration(
                  labelText: 'Notification Sound Profile',
                  prefixIcon: Icon(Icons.music_note_rounded),
                ),
                items: AppConstants114.notificationSounds
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    notifier.updateSettings(
                      prefs.copyWith(notificationSound: v),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    final alert = await notifier.triggerGoalReminderNow();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${alert.title}: ${alert.message}'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.campaign_rounded),
                  label: const Text('Test Reading Notification & Sound Now'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. EXPORT FUNCTIONALITY (CSV / PDF / EMAIL)
          _groupCard(
            title: 'Export Data & Reports (CSV • PDF • Email)',
            icon: Icons.output_rounded,
            children: [
              const Text(
                'Export document metadata, saved bookmarks, and reading session telemetry into portable formats.',
                style: TextStyle(
                  color: AppConstants114.textSoftGrey,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      final csv = ExportShareService114.buildLibraryCsv(
                        documents: ws.documents,
                        bookmarks: ws.bookmarks,
                        history: ws.history,
                      );
                      await ExportShareService114.shareCsvText(csv);
                    },
                    icon: const Icon(Icons.table_chart_rounded, size: 18),
                    label: const Text('Export CSV'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final reportBytes =
                          await ExportShareService114.buildActivityReportPdf(
                        documents: ws.documents,
                        bookmarks: ws.bookmarks,
                        history: ws.history,
                      );
                      final reportDoc = await ref
                          .read(documentRepository114Provider)
                          .importRawPdfBytes(
                            bytes: reportBytes,
                            fileName: 'Nexus_114_Telemetry_Report.pdf',
                            customTitle: 'PDF Reader 114 Analytics Report',
                            tags: 'Report, Export, Analytics',
                          );
                      await notifier.refreshAll();
                      if (!context.mounted) return;
                      DocDialogs114.openReader(context, reportDoc);
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('Generate PDF Report'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final ok =
                          await ExportShareService114.launchEmailSummary(
                        documents: ws.documents,
                        bookmarks: ws.bookmarks,
                      );
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No default mail app configured — sharing summary instead.',
                            ),
                          ),
                        );
                        final csv = ExportShareService114.buildLibraryCsv(
                          documents: ws.documents,
                          bookmarks: ws.bookmarks,
                          history: ws.history,
                        );
                        await ExportShareService114.shareCsvText(csv);
                      }
                    },
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text('Email Summary'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. STORAGE, MAINTENANCE & ABOUT
          _groupCard(
            title: 'Storage, Privacy & Application Info',
            icon: Icons.shield_outlined,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.sd_storage_outlined,
                  color: AppConstants114.accentCyan,
                ),
                title: const Text('Local SQLite Storage Footprint'),
                subtitle: Text(
                  '${ws.documents.length} PDFs • ${ws.bookmarks.length} Bookmarks • ${FormatHelpers114.formatBytes(ws.totalStorageBytes)}',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('Clear Temporary Render Cache'),
                subtitle: const Text('Frees raster tile buffers safely'),
                onTap: () {
                  PaintingBinding.instance.imageCache.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cleared rendered page image cache.'),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.history_toggle_off_rounded,
                  color: AppConstants114.warningAmber,
                ),
                title: const Text('Clear Reading History'),
                onTap: () async {
                  final ok = await _confirmDialog(
                    context,
                    title: 'Clear Reading History?',
                    body:
                        'This removes your recent session timeline while keeping all PDFs and bookmarks intact.',
                    actionLabel: 'Clear History',
                  );
                  if (ok) {
                    await notifier.clearHistory();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reading history cleared.')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.restart_alt_rounded,
                  color: AppConstants114.dangerRose,
                ),
                title: const Text('Reset All Preferences'),
                onTap: () async {
                  final ok = await _confirmDialog(
                    context,
                    title: 'Reset Reader Preferences?',
                    body:
                        'Restore theme, default zoom, orientation, and notification sound settings to factory defaults?',
                    actionLabel: 'Reset Defaults',
                  );
                  if (ok) {
                    await notifier.resetPreferences();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preferences restored to defaults.'),
                        ),
                      );
                    }
                  }
                },
              ),
              const Divider(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline_rounded),
                title: const Text('Privacy Guarantee'),
                subtitle: const Text(
                  '100% offline processing. Documents, annotations, and bookmarks remain strictly on your device.',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Send Developer Feedback'),
                onTap: () => _showFeedbackDialog(context),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.verified_rounded,
                  color: AppConstants114.accentCyan,
                ),
                title: const Text(AppConstants114.appName),
                subtitle: const Text(
                  '${AppConstants114.appVersion} • ${AppConstants114.developerName}\n${AppConstants114.courseTitle}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share Feedback • PDF Reader 114'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tell us what feature or workflow you enjoyed...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Feedback logged locally.'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _groupCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants114.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstants114.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppConstants114.accentCyan, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
