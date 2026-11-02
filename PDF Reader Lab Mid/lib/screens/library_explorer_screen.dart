import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../providers/nexus_providers.dart';
import '../widgets/doc_dialogs_114.dart';
import '../widgets/nexus_doc_card.dart';

class LibraryExplorerScreen114 extends ConsumerWidget {
  const LibraryExplorerScreen114({super.key});

  Future<void> _createFolderDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    int selectedColor = AppConstants114.secondaryBlue.value;

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('New Folder / Collection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  prefixIcon: Icon(Icons.create_new_folder_outlined),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Accent Badge Color',
                style: TextStyle(fontSize: 12, color: AppConstants114.textSoftGrey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final col in [
                    0xFF2563EB,
                    0xFF22D3EE,
                    0xFF10B981,
                    0xFFF59E0B,
                    0xFFF43F5E,
                  ])
                    GestureDetector(
                      onTap: () => setLocal(() => selectedColor = col),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(col),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == col
                                ? Colors.white
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Create Folder'),
            ),
          ],
        ),
      ),
    );

    if (created == true && nameCtrl.text.trim().isNotEmpty) {
      await ref
          .read(nexusWorkspaceProvider.notifier)
          .createNewFolder(nameCtrl.text.trim(), selectedColor);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(nexusWorkspaceProvider);
    final notifier = ref.read(nexusWorkspaceProvider.notifier);
    final docs = ws.filteredDocuments;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Document Library',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _createFolderDialog(context, ref),
                icon: const Icon(Icons.create_new_folder_outlined, size: 17),
                label: const Text('New Folder'),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: ws.isGridView ? 'Switch to List View' : 'Switch to Grid View',
                onPressed: notifier.toggleGridView,
                icon: Icon(
                  ws.isGridView
                      ? Icons.view_agenda_rounded
                      : Icons.grid_view_rounded,
                  color: AppConstants114.accentCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: notifier.setSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Filter library by name or tag...',
                    prefixIcon: Icon(Icons.filter_list_rounded),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<LibrarySort114>(
                tooltip: 'Sort Documents',
                onSelected: notifier.setSortMode,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: LibrarySort114.recent,
                    child: Text('Sort: Recently Opened'),
                  ),
                  PopupMenuItem(
                    value: LibrarySort114.name,
                    child: Text('Sort: Alphabetical (A-Z)'),
                  ),
                  PopupMenuItem(
                    value: LibrarySort114.dateModified,
                    child: Text('Sort: Last Modified'),
                  ),
                  PopupMenuItem(
                    value: LibrarySort114.fileSize,
                    child: Text('Sort: File Size'),
                  ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppConstants114.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppConstants114.borderSubtle),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.sort_rounded,
                        size: 18,
                        color: AppConstants114.accentCyan,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Sort',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('All (${ws.documents.length})'),
                    selected: ws.selectedFolderId == 'all',
                    onSelected: (_) => notifier.setSelectedFolder('all'),
                  ),
                ),
                for (final f in ws.folders)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: CircleAvatar(
                        backgroundColor: Color(f.colorHex),
                        radius: 5,
                      ),
                      label: Text(
                        '${f.name} (${ws.documents.where((d) => d.folderId == f.id).length})',
                      ),
                      selected: ws.selectedFolderId == f.id,
                      onSelected: (_) => notifier.setSelectedFolder(f.id),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: docs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.folder_open_rounded,
                          size: 54,
                          color: AppConstants114.textSoftGrey,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No PDFs in this folder or filter.',
                          style: TextStyle(color: AppConstants114.textSoftGrey),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => notifier.importFromDevice(),
                          icon: const Icon(Icons.upload_file_rounded),
                          label: const Text('Import PDF Files'),
                        ),
                      ],
                    ),
                  )
                : ws.isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.only(bottom: 92),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.05,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (_, idx) {
                          final doc = docs[idx];
                          return NexusDocCard114(
                            doc: doc,
                            folders: ws.folders,
                            gridMode: true,
                            onOpen: () => DocDialogs114.openReader(context, doc),
                            onToggleFavorite: () => notifier.toggleFavorite(doc),
                            onEditMetadata: () =>
                                DocDialogs114.showEditMetadataDialog(
                              context,
                              ref,
                              doc,
                              ws.folders,
                            ),
                            onDuplicate: () => notifier.duplicateDocument(doc),
                            onConvertImages: () =>
                                DocDialogs114.openPdfToImage(context, doc),
                            onShare: () =>
                                DocDialogs114.shareDocument(context, doc),
                            onShowInfo: () => DocDialogs114.showDocumentInfoSheet(
                              context,
                              doc,
                              ws.folders,
                            ),
                            onDelete: () => DocDialogs114.confirmDeleteDocument(
                              context,
                              ref,
                              doc,
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 92),
                        itemCount: docs.length,
                        itemBuilder: (_, idx) {
                          final doc = docs[idx];
                          return NexusDocCard114(
                            doc: doc,
                            folders: ws.folders,
                            gridMode: false,
                            onOpen: () => DocDialogs114.openReader(context, doc),
                            onToggleFavorite: () => notifier.toggleFavorite(doc),
                            onEditMetadata: () =>
                                DocDialogs114.showEditMetadataDialog(
                              context,
                              ref,
                              doc,
                              ws.folders,
                            ),
                            onDuplicate: () => notifier.duplicateDocument(doc),
                            onConvertImages: () =>
                                DocDialogs114.openPdfToImage(context, doc),
                            onShare: () =>
                                DocDialogs114.shareDocument(context, doc),
                            onShowInfo: () => DocDialogs114.showDocumentInfoSheet(
                              context,
                              doc,
                              ws.folders,
                            ),
                            onDelete: () => DocDialogs114.confirmDeleteDocument(
                              context,
                              ref,
                              doc,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
