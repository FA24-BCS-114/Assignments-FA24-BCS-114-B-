import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/pdf_doc_model.dart';
import '../models/reader_aux_models.dart';
import '../utils/format_helpers.dart';

class NexusDocCard114 extends StatelessWidget {
  final PdfDocModel114 doc;
  final List<FolderItem114> folders;
  final bool gridMode;
  final VoidCallback onOpen;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEditMetadata;
  final VoidCallback onDuplicate;
  final VoidCallback onConvertImages;
  final VoidCallback onShare;
  final VoidCallback onShowInfo;
  final VoidCallback onDelete;

  const NexusDocCard114({
    super.key,
    required this.doc,
    required this.folders,
    this.gridMode = false,
    required this.onOpen,
    required this.onToggleFavorite,
    required this.onEditMetadata,
    required this.onDuplicate,
    required this.onConvertImages,
    required this.onShare,
    required this.onShowInfo,
    required this.onDelete,
  });

  String _resolveFolderName() {
    for (final f in folders) {
      if (f.id == doc.folderId) return f.name;
    }
    return 'All Documents';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppConstants114.cardSurface : Colors.white;
    final borderCol = isDark ? AppConstants114.borderSubtle : const Color(0xFFE2E8F0);
    final textMain = isDark ? AppConstants114.textPrimary : const Color(0xFF0F172A);
    final textSub = isDark ? AppConstants114.textSoftGrey : const Color(0xFF64748B);

    if (gridMode) {
      return InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppConstants114.secondaryBlue,
                          Color(0xFF1D4ED8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      doc.isScanned
                          ? Icons.document_scanner_rounded
                          : Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      doc.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: doc.isFavorite
                          ? AppConstants114.warningAmber
                          : textSub,
                      size: 20,
                    ),
                  ),
                  _buildPopupMenu(context, textSub),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                doc.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${doc.pageCount} pages • ${FormatHelpers114.formatBytes(doc.fileSizeBytes)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textSub, fontSize: 11.5),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${doc.lastReadPage}/${doc.pageCount}',
                    style: const TextStyle(
                      color: AppConstants114.accentCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${doc.progressPercent}%',
                    style: TextStyle(color: textSub, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: doc.readingProgress,
                  minHeight: 5,
                  backgroundColor: borderCol,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppConstants114.accentCyan,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: doc.isScanned
                      ? const [Color(0xFF0891B2), Color(0xFF155E75)]
                      : const [AppConstants114.secondaryBlue, Color(0xFF1E3A8A)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    doc.isScanned
                        ? Icons.document_scanner_rounded
                        : Icons.picture_as_pdf_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doc.isScanned ? 'SCAN' : 'PDF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doc.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textMain,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (doc.isFavorite)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.star_rounded,
                            color: AppConstants114.warningAmber,
                            size: 17,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${FormatHelpers114.formatBytes(doc.fileSizeBytes)} • ${doc.pageCount} pages • ${FormatHelpers114.formatShortDate(doc.lastModifiedAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textSub, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants114.secondaryBlue.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _resolveFolderName(),
                          style: const TextStyle(
                            color: AppConstants114.accentCyan,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: doc.readingProgress,
                            minHeight: 5,
                            backgroundColor: borderCol,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppConstants114.accentCyan,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'P.${doc.lastReadPage}/${doc.pageCount}',
                        style: TextStyle(
                          color: textSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            _buildPopupMenu(context, textSub),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, Color iconColor) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: iconColor, size: 20),
      tooltip: 'Document Actions',
      onSelected: (val) {
        switch (val) {
          case 'open':
            onOpen();
            break;
          case 'fav':
            onToggleFavorite();
            break;
          case 'edit':
            onEditMetadata();
            break;
          case 'dup':
            onDuplicate();
            break;
          case 'img':
            onConvertImages();
            break;
          case 'share':
            onShare();
            break;
          case 'info':
            onShowInfo();
            break;
          case 'del':
            onDelete();
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'open',
          child: Row(
            children: [
              const Icon(Icons.menu_book_rounded, size: 18),
              const SizedBox(width: 10),
              Text('Resume (Page ${doc.lastReadPage})'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'fav',
          child: Row(
            children: [
              Icon(
                doc.isFavorite ? Icons.star_outline_rounded : Icons.star_rounded,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(doc.isFavorite ? 'Remove Favorite' : 'Add to Favorites'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 18),
              SizedBox(width: 10),
              Text('Rename & Edit Metadata'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'dup',
          child: Row(
            children: [
              Icon(Icons.copy_all_rounded, size: 18),
              SizedBox(width: 10),
              Text('Save Copy in Library'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'img',
          child: Row(
            children: [
              Icon(Icons.image_outlined, size: 18),
              SizedBox(width: 10),
              Text('Convert Pages to PNG/JPG'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share_rounded, size: 18),
              SizedBox(width: 10),
              Text('Share PDF Document'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18),
              SizedBox(width: 10),
              Text('Document Properties'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'del',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: AppConstants114.dangerRose, size: 18),
              SizedBox(width: 10),
              Text(
                'Delete Document',
                style: TextStyle(color: AppConstants114.dangerRose),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
