import 'package:intl/intl.dart';

class FormatHelpers114 {
  FormatHelpers114._();

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 KB';
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024.0;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024.0;
    return '${mb.toStringAsFixed(2)} MB';
  }

  static String formatShortDate(DateTime dt) {
    return DateFormat('dd MMM yyyy').format(dt);
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
  }

  static String relativeTime(DateTime? dt) {
    if (dt == null) return 'Never opened';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatShortDate(dt);
  }
}
