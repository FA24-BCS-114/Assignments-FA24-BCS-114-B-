import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/pdf_doc_model.dart';
import '../providers/nexus_providers.dart';
import '../services/export_share_service.dart';
import '../utils/format_helpers.dart';
import '../widgets/doc_dialogs_114.dart';
import '../widgets/nexus_doc_card.dart';
import 'cyber_scanner_screen.dart';

class HomeDashboardScreen114 extends ConsumerWidget {
  const HomeDashboardScreen114({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(nexusWorkspaceProvider);
    final notifier = ref.read(nexusWorkspaceProvider.notifier);

    final query = ws.searchQuery.trim().toLowerCase();
    final matchedDocs = query.isEmpty
        ? ws.documents
        : ws.documents
            .where(
              (d) =>
                  d.title.toLowerCase().contains(query) ||
                  d.fileName.toLowerCase().contains(query) ||
                  d.tags.toLowerCase().contains(query),
            )
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(context, ws),
          const SizedBox(height: 16),
          _buildSearchField(context, notifier, ws.searchQuery),
          const SizedBox(height: 18),
          _buildStorageAndGoalTelemetry(context, ws),
          const SizedBox(height: 18),
          _buildQuickAccessRow(context, ref, ws),
          const SizedBox(height: 22),
          if (query.isEmpty && ws.recentDocuments.isNotEmpty) ...[
            _sectionHeader(
              'Recently Opened PDFs',
              trailing: '${ws.recentDocuments.length} recent',
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ws.recentDocuments.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, idx) =>
                    _buildRecentCard(context, ws.recentDocuments[idx]),
              ),
            ),
            const SizedBox(height: 22),
          ],
          if (query.isEmpty && ws.favoriteDocuments.isNotEmpty) ...[
            _sectionHeader(
              'Favorites',
              trailing: '${ws.favoriteDocuments.length} starred',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ws.favoriteDocuments
                  .map((doc) => _buildFavoriteChipCard(context, doc))
                  .toList(),
            ),
            const SizedBox(height: 22),
          ],
          _sectionHeader(
            query.isEmpty ? 'All Documents' : 'Search Results',
            trailing: '${matchedDocs.length} PDF(s)',
            onAction: () => notifier.setNavIndex(1),
            actionLabel: 'Open Library',
          ),
          const SizedBox(height: 10),
          if (matchedDocs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppConstants114.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppConstants114.borderSubtle),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.folder_off_rounded,
                    size: 42,
                    color: AppConstants114.textSoftGrey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No matching PDF documents found.',
                    style: TextStyle(color: AppConstants114.textSoftGrey),
                  ),
                ],
              ),
            )
          else
            ...matchedDocs.map(
              (doc) => NexusDocCard114(
                doc: doc,
                folders: ws.folders,
                onOpen: () => DocDialogs114.openReader(context, doc),
                onToggleFavorite: () => notifier.toggleFavorite(doc),
                onEditMetadata: () => DocDialogs114.showEditMetadataDialog(
                  context,
                  ref,
                  doc,
                  ws.folders,
                ),
                onDuplicate: () async {
                  final copy = await notifier.duplicateDocument(doc);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Created "${copy.title}".')),
                    );
                  }
                },
                onConvertImages: () => DocDialogs114.openPdfToImage(context, doc),
                onShare: () => DocDialogs114.shareDocument(context, doc),
                onShowInfo: () =>
                    DocDialogs114.showDocumentInfoSheet(context, doc, ws.folders),
                onDelete: () =>
                    DocDialogs114.confirmDeleteDocument(context, ref, doc),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, NexusWorkspaceState ws) {
    final isRoman = ws.settings.languageCode.startsWith('Urdu');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants114.primaryNavy,
            Color(0xFF162544),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppConstants114.borderSubtle),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppConstants114.secondaryBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        AppConstants114.appName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants114.accentCyan.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppConstants114.accentCyan.withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        'PRO 114',
                        style: TextStyle(
                          color: AppConstants114.accentCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isRoman
                      ? 'Khush Aamdeed Harry • Dark PDF Workstation Ready'
                      : 'Welcome back, Harry • Modern Dark PDF Workstation',
                  style: const TextStyle(
                    color: AppConstants114.textSoftGrey,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    NexusWorkspaceNotifier notifier,
    String query,
  ) {
    return TextField(
      onChanged: notifier.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search PDFs by filename, title, or tag...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppConstants114.accentCyan,
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                onPressed: () => notifier.setSearchQuery(''),
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
      ),
    );
  }

  Widget _buildStorageAndGoalTelemetry(
    BuildContext context,
    NexusWorkspaceState ws,
  ) {
    final usedBytes = ws.totalStorageBytes;
    const quotaBytes = 50 * 1024 * 1024; // 50 MB local vault benchmark
    final storageRatio = (usedBytes / quotaBytes).clamp(0.03, 1.0);
    final goalRatio = (ws.settings.completedMinutesToday /
            (ws.settings.dailyGoalMinutes <= 0
                ? 30
                : ws.settings.dailyGoalMinutes))
        .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants114.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstants114.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.storage_rounded,
                color: AppConstants114.accentCyan,
                size: 19,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SQLite Vault Storage',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
              Text(
                '${FormatHelpers114.formatBytes(usedBytes)} / 50 MB (${ws.documents.length} PDFs)',
                style: const TextStyle(
                  color: AppConstants114.textSoftGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: storageRatio,
              minHeight: 6,
              backgroundColor: AppConstants114.primaryNavy,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppConstants114.secondaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: AppConstants114.successEmerald,
                size: 19,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Daily Reading Goal',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
              Text(
                '${ws.settings.completedMinutesToday} / ${ws.settings.dailyGoalMinutes} min',
                style: const TextStyle(
                  color: AppConstants114.accentCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goalRatio,
              minHeight: 6,
              backgroundColor: AppConstants114.primaryNavy,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppConstants114.successEmerald,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessRow(
    BuildContext context,
    WidgetRef ref,
    NexusWorkspaceState ws,
  ) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width >= 680 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.35,
      children: [
        _quickBtn(
          icon: Icons.upload_file_rounded,
          title: 'Import PDFs',
          subtitle: 'Device / Downloads',
          accent: AppConstants114.secondaryBlue,
          onTap: () async {
            final res = await ref
                .read(nexusWorkspaceProvider.notifier)
                .importFromDevice(allowMultiple: true);
            if (!context.mounted) return;
            if (res.imported.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Imported ${res.imported.length} PDF(s).'),
                ),
              );
            }
          },
        ),
        _quickBtn(
          icon: Icons.document_scanner_rounded,
          title: 'CyberScan',
          subtitle: 'Camera to PDF',
          accent: AppConstants114.accentCyan,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CyberScannerScreen114(),
              ),
            );
          },
        ),
        _quickBtn(
          icon: Icons.collections_rounded,
          title: 'PDF → Image',
          subtitle: 'PNG / JPG Export',
          accent: AppConstants114.successEmerald,
          onTap: () => DocDialogs114.openPdfToImage(
            context,
            ws.documents.isNotEmpty ? ws.documents.first : null,
          ),
        ),
        _quickBtn(
          icon: Icons.ios_share_rounded,
          title: 'Export Report',
          subtitle: 'CSV / PDF / Email',
          accent: AppConstants114.warningAmber,
          onTap: () async {
            final csv = ExportShareService114.buildLibraryCsv(
              documents: ws.documents,
              bookmarks: ws.bookmarks,
              history: ws.history,
            );
            await ExportShareService114.shareCsvText(csv);
          },
        ),
      ],
    );
  }

  Widget _quickBtn({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppConstants114.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants114.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppConstants114.textSoftGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard(BuildContext context, PdfDocModel114 doc) {
    return InkWell(
      onTap: () => DocDialogs114.openReader(context, doc),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 225,
        padding: const EdgeInsets.all(14),
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
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppConstants114.accentCyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    FormatHelpers114.relativeTime(doc.lastOpenedAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppConstants114.textSoftGrey,
                      fontSize: 11,
                    ),
                  ),
                ),
                Text(
                  '${doc.progressPercent}%',
                  style: const TextStyle(
                    color: AppConstants114.accentCyan,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              doc.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                height: 1.25,
              ),
            ),
            const Spacer(),
            Text(
              'Resume Page ${doc.lastReadPage} of ${doc.pageCount}',
              style: const TextStyle(
                color: AppConstants114.textSoftGrey,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: doc.readingProgress,
                minHeight: 4,
                backgroundColor: AppConstants114.primaryNavy,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppConstants114.secondaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteChipCard(BuildContext context, PdfDocModel114 doc) {
    return ActionChip(
      avatar: const Icon(
        Icons.star_rounded,
        color: AppConstants114.warningAmber,
        size: 17,
      ),
      label: Text(
        doc.title,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () => DocDialogs114.openReader(context, doc),
    );
  }

  Widget _sectionHeader(
    String title, {
    String? trailing,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              color: AppConstants114.textSoftGrey,
              fontSize: 12,
            ),
          ),
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ],
    );
  }
}
