import 'dart:convert';
import 'package:flutter/material.dart';

class BookmarkItem114 {
  final String id;
  final String documentId;
  final String documentTitle;
  final int pageNumber;
  final String label;
  final String note;
  final DateTime createdAt;

  const BookmarkItem114({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.pageNumber,
    required this.label,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'document_id': documentId,
        'document_title': documentTitle,
        'page_number': pageNumber,
        'label': label,
        'note': note,
        'created_at': createdAt.toIso8601String(),
      };

  factory BookmarkItem114.fromMap(Map<String, dynamic> map) => BookmarkItem114(
        id: map['id'] as String,
        documentId: map['document_id'] as String,
        documentTitle: (map['document_title'] as String?) ?? 'Document',
        pageNumber: (map['page_number'] as num).toInt(),
        label: map['label'] as String,
        note: (map['note'] as String?) ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

enum AnnotationKind114 { highlight, underline, strikethrough, freehand, note }

class AnnotationItem114 {
  final String id;
  final String documentId;
  final int pageNumber;
  final AnnotationKind114 kind;
  final int colorHex;
  final String comment;
  // Normalized [0..1] coordinates relative to page width & height so zoom never shifts overlays!
  final List<Offset> normalizedPoints;
  final Rect? normalizedRect;
  final DateTime createdAt;

  const AnnotationItem114({
    required this.id,
    required this.documentId,
    required this.pageNumber,
    required this.kind,
    required this.colorHex,
    this.comment = '',
    this.normalizedPoints = const [],
    this.normalizedRect,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'document_id': documentId,
        'page_number': pageNumber,
        'kind': kind.name,
        'color_hex': colorHex,
        'comment': comment,
        'points_json': jsonEncode(
          normalizedPoints.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
        ),
        'rect_json': normalizedRect == null
            ? null
            : jsonEncode({
                'l': normalizedRect!.left,
                't': normalizedRect!.top,
                'w': normalizedRect!.width,
                'h': normalizedRect!.height,
              }),
        'created_at': createdAt.toIso8601String(),
      };

  factory AnnotationItem114.fromMap(Map<String, dynamic> map) {
    final ptsRaw = map['points_json'] as String?;
    final pts = <Offset>[];
    if (ptsRaw != null && ptsRaw.isNotEmpty) {
      final decoded = jsonDecode(ptsRaw) as List<dynamic>;
      for (final item in decoded) {
        final m = item as Map<String, dynamic>;
        pts.add(Offset((m['x'] as num).toDouble(), (m['y'] as num).toDouble()));
      }
    }
    Rect? rect;
    final rectRaw = map['rect_json'] as String?;
    if (rectRaw != null && rectRaw.isNotEmpty) {
      final r = jsonDecode(rectRaw) as Map<String, dynamic>;
      rect = Rect.fromLTWH(
        (r['l'] as num).toDouble(),
        (r['t'] as num).toDouble(),
        (r['w'] as num).toDouble(),
        (r['h'] as num).toDouble(),
      );
    }
    final kindStr = map['kind'] as String? ?? 'highlight';
    final kind = AnnotationKind114.values.firstWhere(
      (e) => e.name == kindStr,
      orElse: () => AnnotationKind114.highlight,
    );
    return AnnotationItem114(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      pageNumber: (map['page_number'] as num).toInt(),
      kind: kind,
      colorHex: (map['color_hex'] as num).toInt(),
      comment: (map['comment'] as String?) ?? '',
      normalizedPoints: pts,
      normalizedRect: rect,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class FolderItem114 {
  final String id;
  final String name;
  final int colorHex;
  final DateTime createdAt;

  const FolderItem114({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'color_hex': colorHex,
        'created_at': createdAt.toIso8601String(),
      };

  factory FolderItem114.fromMap(Map<String, dynamic> map) => FolderItem114(
        id: map['id'] as String,
        name: map['name'] as String,
        colorHex: (map['color_hex'] as num).toInt(),
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class HistoryEntry114 {
  final String id;
  final String documentId;
  final String documentTitle;
  final int reachedPage;
  final int totalPages;
  final DateTime openedAt;

  const HistoryEntry114({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.reachedPage,
    required this.totalPages,
    required this.openedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'document_id': documentId,
        'document_title': documentTitle,
        'reached_page': reachedPage,
        'total_pages': totalPages,
        'opened_at': openedAt.toIso8601String(),
      };

  factory HistoryEntry114.fromMap(Map<String, dynamic> map) => HistoryEntry114(
        id: map['id'] as String,
        documentId: map['document_id'] as String,
        documentTitle: map['document_title'] as String,
        reachedPage: (map['reached_page'] as num).toInt(),
        totalPages: (map['total_pages'] as num).toInt(),
        openedAt: DateTime.tryParse(map['opened_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class ReaderSettings114 {
  final bool darkAppTheme;
  final String defaultReadingTone; // 'dark', 'paper', 'sepia', 'midnight'
  final double defaultZoom;
  final String scrollDirection; // 'vertical', 'horizontal'
  final String orientationLock; // 'auto', 'portrait', 'landscape'
  final double brightnessOverlay; // 0.0 (brightest) .. 0.6 (dimmed)
  final String languageCode; // 'English', 'Urdu (Roman)'
  final String notificationSound;
  final bool remindersEnabled;
  final int dailyGoalMinutes;
  final int completedMinutesToday;

  const ReaderSettings114({
    this.darkAppTheme = true,
    this.defaultReadingTone = 'dark',
    this.defaultZoom = 1.0,
    this.scrollDirection = 'vertical',
    this.orientationLock = 'auto',
    this.brightnessOverlay = 0.0,
    this.languageCode = 'English',
    this.notificationSound = 'Cyber Pulse',
    this.remindersEnabled = true,
    this.dailyGoalMinutes = 30,
    this.completedMinutesToday = 22,
  });

  ReaderSettings114 copyWith({
    bool? darkAppTheme,
    String? defaultReadingTone,
    double? defaultZoom,
    String? scrollDirection,
    String? orientationLock,
    double? brightnessOverlay,
    String? languageCode,
    String? notificationSound,
    bool? remindersEnabled,
    int? dailyGoalMinutes,
    int? completedMinutesToday,
  }) {
    return ReaderSettings114(
      darkAppTheme: darkAppTheme ?? this.darkAppTheme,
      defaultReadingTone: defaultReadingTone ?? this.defaultReadingTone,
      defaultZoom: defaultZoom ?? this.defaultZoom,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      orientationLock: orientationLock ?? this.orientationLock,
      brightnessOverlay: brightnessOverlay ?? this.brightnessOverlay,
      languageCode: languageCode ?? this.languageCode,
      notificationSound: notificationSound ?? this.notificationSound,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      completedMinutesToday: completedMinutesToday ?? this.completedMinutesToday,
    );
  }

  Map<String, String> toPrefEntries() => {
        'darkAppTheme': darkAppTheme.toString(),
        'defaultReadingTone': defaultReadingTone,
        'defaultZoom': defaultZoom.toString(),
        'scrollDirection': scrollDirection,
        'orientationLock': orientationLock,
        'brightnessOverlay': brightnessOverlay.toString(),
        'languageCode': languageCode,
        'notificationSound': notificationSound,
        'remindersEnabled': remindersEnabled.toString(),
        'dailyGoalMinutes': dailyGoalMinutes.toString(),
        'completedMinutesToday': completedMinutesToday.toString(),
      };

  factory ReaderSettings114.fromPrefEntries(Map<String, String> m) {
    return ReaderSettings114(
      darkAppTheme: (m['darkAppTheme'] ?? 'true') == 'true',
      defaultReadingTone: m['defaultReadingTone'] ?? 'dark',
      defaultZoom: double.tryParse(m['defaultZoom'] ?? '1.0') ?? 1.0,
      scrollDirection: m['scrollDirection'] ?? 'vertical',
      orientationLock: m['orientationLock'] ?? 'auto',
      brightnessOverlay: double.tryParse(m['brightnessOverlay'] ?? '0.0') ?? 0.0,
      languageCode: m['languageCode'] ?? 'English',
      notificationSound: m['notificationSound'] ?? 'Cyber Pulse',
      remindersEnabled: (m['remindersEnabled'] ?? 'true') == 'true',
      dailyGoalMinutes: int.tryParse(m['dailyGoalMinutes'] ?? '30') ?? 30,
      completedMinutesToday: int.tryParse(m['completedMinutesToday'] ?? '22') ?? 22,
    );
  }
}
