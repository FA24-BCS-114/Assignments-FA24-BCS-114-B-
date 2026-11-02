class PdfDocModel114 {
  final String id;
  final String title;
  final String fileName;
  final String? filePath;
  final String? pdfBase64;
  final int fileSizeBytes;
  final int pageCount;
  final int lastReadPage;
  final bool isFavorite;
  final bool isScanned;
  final String folderId;
  final String tags;
  final String description;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final DateTime? lastOpenedAt;

  const PdfDocModel114({
    required this.id,
    required this.title,
    required this.fileName,
    this.filePath,
    this.pdfBase64,
    required this.fileSizeBytes,
    required this.pageCount,
    this.lastReadPage = 1,
    this.isFavorite = false,
    this.isScanned = false,
    this.folderId = 'all',
    this.tags = 'Academic, PDF',
    this.description = '',
    required this.createdAt,
    required this.lastModifiedAt,
    this.lastOpenedAt,
  });

  double get readingProgress {
    if (pageCount <= 0) return 0.0;
    return (lastReadPage.clamp(0, pageCount)) / pageCount;
  }

  int get progressPercent => (readingProgress * 100).round();

  List<String> get tagList => tags
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  PdfDocModel114 copyWith({
    String? id,
    String? title,
    String? fileName,
    String? filePath,
    String? pdfBase64,
    int? fileSizeBytes,
    int? pageCount,
    int? lastReadPage,
    bool? isFavorite,
    bool? isScanned,
    String? folderId,
    String? tags,
    String? description,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    DateTime? lastOpenedAt,
  }) {
    return PdfDocModel114(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      pdfBase64: pdfBase64 ?? this.pdfBase64,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      pageCount: pageCount ?? this.pageCount,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      isFavorite: isFavorite ?? this.isFavorite,
      isScanned: isScanned ?? this.isScanned,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_name': fileName,
      'file_path': filePath,
      'pdf_base64': pdfBase64,
      'file_size_bytes': fileSizeBytes,
      'page_count': pageCount,
      'last_read_page': lastReadPage,
      'is_favorite': isFavorite ? 1 : 0,
      'is_scanned': isScanned ? 1 : 0,
      'folder_id': folderId,
      'tags': tags,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'last_modified_at': lastModifiedAt.toIso8601String(),
      'last_opened_at': lastOpenedAt?.toIso8601String(),
    };
  }

  factory PdfDocModel114.fromMap(Map<String, dynamic> map) {
    return PdfDocModel114(
      id: map['id'] as String,
      title: map['title'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String?,
      pdfBase64: map['pdf_base64'] as String?,
      fileSizeBytes: (map['file_size_bytes'] as num).toInt(),
      pageCount: (map['page_count'] as num).toInt(),
      lastReadPage: (map['last_read_page'] as num?)?.toInt() ?? 1,
      isFavorite: (map['is_favorite'] as num?)?.toInt() == 1,
      isScanned: (map['is_scanned'] as num?)?.toInt() == 1,
      folderId: (map['folder_id'] as String?) ?? 'all',
      tags: (map['tags'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      lastModifiedAt:
          DateTime.tryParse(map['last_modified_at'] as String? ?? '') ?? DateTime.now(),
      lastOpenedAt: map['last_opened_at'] != null
          ? DateTime.tryParse(map['last_opened_at'] as String)
          : null,
    );
  }
}
