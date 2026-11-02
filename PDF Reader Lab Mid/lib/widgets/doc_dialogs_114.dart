import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/pdf_doc_model.dart';
import '../models/reader_aux_models.dart';
import '../providers/nexus_providers.dart';
import '../screens/pdf_reader_workspace.dart';
import '../screens/pdf_to_image_screen.dart';
import '../services/export_share_service.dart';
import '../services/pdf_engine_service.dart';
import '../utils/format_helpers.dart';

class DocDialogs114 {
  DocDialogs114._();

  static void openReader(
    BuildContext context,
    PdfDocModel114 doc, {
    int? initialPageOverride,
    bool openAnnotationBar = false,
    String? initialSearchQuery,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfReaderWorkspace114(
          doc: doc,
          initialPageOverride: initialPageOverride,
          openAnnotationToolbarInitially: openAnnotationBar,
          initialSearchQuery: initialSearchQuery,
        ),
      ),
    );
  }

  static void openPdfToImage(BuildContext context, PdfDocModel114? initialDoc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfToImageScreen114(initialDocument: initialDoc),
      ),
    );
  }

  static Future<void> shareDocument(
    BuildContext context,
    PdfDocModel114 doc,
  ) async {
    try {
      final bytes = await PdfEngineService114.resolveDocumentBytes(doc);
      await ExportShareService114.shareBinaryFile(
        bytes: bytes,
        fileName: doc.fileName,
        mimeType: 'application/pdf',
        subject: 'Shared from PDF Reader 114: ${doc.title}',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to share PDF: $e')),
      );
    }
  }

  static Future<void> showEditMetadataDialog(
    BuildContext context,
    WidgetRef ref,
    PdfDocModel114 doc,
    List<FolderItem114> folders,
  ) async {
    final titleCtrl = TextEditingController(text: doc.title);
    final tagsCtrl = TextEditingController(text: doc.tags);
    final descCtrl = TextEditingController(text: doc.description);
    var selectedFolder = doc.folderId;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Rename & Edit Metadata'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Document Title',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: folders.any((f) => f.id == selectedFolder)
                      ? selectedFolder
                      : 'all',
                  decoration: const InputDecoration(
                    labelText: 'Folder / Collection',
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('All Documents (Root)'),
                    ),
                    ...folders.map(
                      (f) => DropdownMenuItem(
                        value: f.id,
                        child: Text(f.name),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setLocal(() => selectedFolder = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Description',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await ref.read(nexusWorkspaceProvider.notifier).editDocumentMetadata(
                      doc: doc,
                      title: titleCtrl.text,
                      tags: tagsCtrl.text,
                      description: descCtrl.text,
                      folderId: selectedFolder,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document metadata saved to SQLite.')),
                  );
                }
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> confirmDeleteDocument(
    BuildContext context,
    WidgetRef ref,
    PdfDocModel114 doc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete PDF Document?'),
        content: Text(
          'Remove "${doc.title}" and its saved bookmarks/annotations from PDF Reader 114? This action cannot be undone.',
        ),
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
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(nexusWorkspaceProvider.notifier).deleteDocument(doc.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${doc.title}".')),
        );
      }
    }
  }

  static void showDocumentInfoSheet(
    BuildContext context,
    PdfDocModel114 doc,
    List<FolderItem114> folders,
  ) {
    final folderName = folders
            .where((f) => f.id == doc.folderId)
            .map((f) => f.name)
            .firstOrNull ??
        'All Documents (Root)';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppConstants114.secondaryBlue.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: AppConstants114.accentCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      doc.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _infoRow('Filename', doc.fileName),
              _infoRow('File Size', FormatHelpers114.formatBytes(doc.fileSizeBytes)),
              _infoRow('Total Pages', '${doc.pageCount} pages'),
              _infoRow(
                'Reading Progress',
                'Page ${doc.lastReadPage} of ${doc.pageCount} (${doc.progressPercent}%)',
              ),
              _infoRow('Collection / Folder', folderName),
              _infoRow('Tags', doc.tags.isEmpty ? 'None' : doc.tags),
              _infoRow('Source Type', doc.isScanned ? 'CyberScan Camera PDF' : 'Standard PDF'),
              _infoRow('Last Modified', FormatHelpers114.formatDateTime(doc.lastModifiedAt)),
              _infoRow('Last Opened', FormatHelpers114.relativeTime(doc.lastOpenedAt)),
              if (doc.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'Summary / Notes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppConstants114.accentCyan,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doc.description,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppConstants114.textSoftGrey,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
