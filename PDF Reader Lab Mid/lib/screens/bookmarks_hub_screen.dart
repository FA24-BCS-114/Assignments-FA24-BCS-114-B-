import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../providers/nexus_providers.dart';
import '../utils/format_helpers.dart';
import '../widgets/doc_dialogs_114.dart';

class BookmarksHubScreen114 extends ConsumerStatefulWidget {
  const BookmarksHubScreen114({super.key});

  @override
  ConsumerState<BookmarksHubScreen114> createState() =>
      _BookmarksHubScreen114State();
}

class _BookmarksHubScreen114State extends ConsumerState<BookmarksHubScreen114> {
  int _segment = 0; // 0: Page Bookmarks, 1: Favorites, 2: History

  @override
  Widget build(BuildContext context) {
    final ws = ref.watch(nexusWorkspaceProvider);
    final notifier = ref.read(nexusWorkspaceProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bookmarks, Favorites & History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  avatar: const Icon(Icons.bookmark_rounded, size: 16),
                  label: Text('Page Bookmarks (${ws.bookmarks.length})'),
                  selected: _segment == 0,
                  onSelected: (_) => setState(() => _segment = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.star_rounded, size: 16),
                  label: Text('Favorites (${ws.favoriteDocuments.length})'),
                  selected: _segment == 1,
                  onSelected: (_) => setState(() => _segment = 1),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.history_rounded, size: 16),
                  label: Text('Reading History (${ws.history.length})'),
                  selected: _segment == 2,
                  onSelected: (_) => setState(() => _segment = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _segment == 0
                ? _buildBookmarksList(context, ws, notifier)
                : _segment == 1
                    ? _buildFavoritesList(context, ws, notifier)
                    : _buildHistoryList(context, ws, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList(
    BuildContext context,
    NexusWorkspaceState ws,
    NexusWorkspaceNotifier notifier,
  ) {
    if (ws.bookmarks.isEmpty) {
      return const Center(
        child: Text(
          'No page bookmarks saved yet. Tap the bookmark icon inside any PDF!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppConstants114.textSoftGrey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 92),
      itemCount: ws.bookmarks.length,
      itemBuilder: (_, idx) {
        final bm = ws.bookmarks[idx];
        final targetDoc =
            ws.documents.where((d) => d.id == bm.documentId).firstOrNull;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppConstants114.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppConstants114.borderSubtle),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants114.secondaryBlue.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'P.${bm.pageNumber}',
                style: const TextStyle(
                  color: AppConstants114.accentCyan,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              bm.label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${bm.documentTitle}${bm.note.isNotEmpty ? '\n${bm.note}' : ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppConstants114.textSoftGrey,
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              tooltip: 'Remove Bookmark',
              onPressed: () => notifier.removeBookmark(bm.id),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppConstants114.dangerRose,
              ),
            ),
            onTap: targetDoc == null
                ? null
                : () => DocDialogs114.openReader(
                      context,
                      targetDoc,
                      initialPageOverride: bm.pageNumber,
                    ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesList(
    BuildContext context,
    NexusWorkspaceState ws,
    NexusWorkspaceNotifier notifier,
  ) {
    final favs = ws.favoriteDocuments;
    if (favs.isEmpty) {
      return const Center(
        child: Text(
          'No starred documents yet.',
          style: TextStyle(color: AppConstants114.textSoftGrey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 92),
      itemCount: favs.length,
      itemBuilder: (_, idx) {
        final doc = favs[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppConstants114.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppConstants114.borderSubtle),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.star_rounded,
              color: AppConstants114.warningAmber,
            ),
            title: Text(
              doc.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'Page ${doc.lastReadPage}/${doc.pageCount} (${doc.progressPercent}%) • ${FormatHelpers114.formatBytes(doc.fileSizeBytes)}',
              style: const TextStyle(
                color: AppConstants114.textSoftGrey,
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              onPressed: () => notifier.toggleFavorite(doc),
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
            onTap: () => DocDialogs114.openReader(context, doc),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    NexusWorkspaceState ws,
    NexusWorkspaceNotifier notifier,
  ) {
    if (ws.history.isEmpty) {
      return const Center(
        child: Text(
          'Reading session log is empty.',
          style: TextStyle(color: AppConstants114.textSoftGrey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 92),
      itemCount: ws.history.length,
      itemBuilder: (_, idx) {
        final h = ws.history[idx];
        final targetDoc =
            ws.documents.where((d) => d.id == h.documentId).firstOrNull;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppConstants114.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppConstants114.borderSubtle),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.history_edu_rounded,
              color: AppConstants114.accentCyan,
            ),
            title: Text(
              h.documentTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'Reached Page ${h.reachedPage} of ${h.totalPages} • ${FormatHelpers114.formatDateTime(h.openedAt)}',
              style: const TextStyle(
                color: AppConstants114.textSoftGrey,
                fontSize: 12,
              ),
            ),
            onTap: targetDoc == null
                ? null
                : () => DocDialogs114.openReader(
                      context,
                      targetDoc,
                      initialPageOverride: h.reachedPage,
                    ),
          ),
        );
      },
    );
  }
}
