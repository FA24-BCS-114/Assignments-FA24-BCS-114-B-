import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pdf_doc_model.dart';
import '../models/reader_aux_models.dart';
import '../repositories/document_repository.dart';
import '../services/reminder_notification_service.dart';
import '../services/vault_sqlite_service.dart';

enum LibrarySort114 { recent, name, dateModified, fileSize }

class NexusWorkspaceState {
  final bool isLoading;
  final List<PdfDocModel114> documents;
  final List<FolderItem114> folders;
  final List<BookmarkItem114> bookmarks;
  final List<HistoryEntry114> history;
  final ReaderSettings114 settings;
  final String searchQuery;
  final String selectedFolderId; // 'all' or specific folder id
  final LibrarySort114 sortBy;
  final bool isGridView;
  final int activeNavIndex;
  final ReminderAlertPayload114? latestAlert;
  final String? lastError;

  const NexusWorkspaceState({
    this.isLoading = true,
    this.documents = const [],
    this.folders = const [],
    this.bookmarks = const [],
    this.history = const [],
    this.settings = const ReaderSettings114(),
    this.searchQuery = '',
    this.selectedFolderId = 'all',
    this.sortBy = LibrarySort114.recent,
    this.isGridView = false,
    this.activeNavIndex = 0,
    this.latestAlert,
    this.lastError,
  });

  int get totalStorageBytes =>
      documents.fold<int>(0, (sum, doc) => sum + doc.fileSizeBytes);

  List<PdfDocModel114> get favoriteDocuments =>
      documents.where((d) => d.isFavorite).toList();

  List<PdfDocModel114> get recentDocuments {
    final list = [...documents];
    list.sort((a, b) {
      final da = a.lastOpenedAt ?? a.lastModifiedAt;
      final db = b.lastOpenedAt ?? b.lastModifiedAt;
      return db.compareTo(da);
    });
    return list.take(6).toList();
  }

  List<PdfDocModel114> get filteredDocuments {
    final q = searchQuery.trim().toLowerCase();
    var list = documents.where((doc) {
      final matchesFolder =
          selectedFolderId == 'all' || doc.folderId == selectedFolderId;
      if (!matchesFolder) return false;
      if (q.isEmpty) return true;
      return doc.title.toLowerCase().contains(q) ||
          doc.fileName.toLowerCase().contains(q) ||
          doc.tags.toLowerCase().contains(q) ||
          doc.description.toLowerCase().contains(q);
    }).toList();

    switch (sortBy) {
      case LibrarySort114.recent:
        list.sort((a, b) {
          final da = a.lastOpenedAt ?? a.lastModifiedAt;
          final db = b.lastOpenedAt ?? b.lastModifiedAt;
          return db.compareTo(da);
        });
        break;
      case LibrarySort114.name:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case LibrarySort114.dateModified:
        list.sort((a, b) => b.lastModifiedAt.compareTo(a.lastModifiedAt));
        break;
      case LibrarySort114.fileSize:
        list.sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));
        break;
    }
    return list;
  }

  NexusWorkspaceState copyWith({
    bool? isLoading,
    List<PdfDocModel114>? documents,
    List<FolderItem114>? folders,
    List<BookmarkItem114>? bookmarks,
    List<HistoryEntry114>? history,
    ReaderSettings114? settings,
    String? searchQuery,
    String? selectedFolderId,
    LibrarySort114? sortBy,
    bool? isGridView,
    int? activeNavIndex,
    ReminderAlertPayload114? latestAlert,
    bool clearAlert = false,
    String? lastError,
    bool clearError = false,
  }) {
    return NexusWorkspaceState(
      isLoading: isLoading ?? this.isLoading,
      documents: documents ?? this.documents,
      folders: folders ?? this.folders,
      bookmarks: bookmarks ?? this.bookmarks,
      history: history ?? this.history,
      settings: settings ?? this.settings,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFolderId: selectedFolderId ?? this.selectedFolderId,
      sortBy: sortBy ?? this.sortBy,
      isGridView: isGridView ?? this.isGridView,
      activeNavIndex: activeNavIndex ?? this.activeNavIndex,
      latestAlert: clearAlert ? null : (latestAlert ?? this.latestAlert),
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

final documentRepository114Provider = Provider<DocumentRepository114>((ref) {
  return DocumentRepository114(VaultSqliteService114.instance);
});

class NexusWorkspaceNotifier extends StateNotifier<NexusWorkspaceState> {
  final DocumentRepository114 _repo;

  NexusWorkspaceNotifier(this._repo) : super(const NexusWorkspaceState()) {
    bootstrap();
  }

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.initialize();
      await refreshAll();
    } catch (e) {
      state = state.copyWith(isLoading: false, lastError: e.toString());
    }
  }

  Future<void> refreshAll() async {
    final docs = await _repo.getDocuments();
    final folders = await _repo.getFolders();
    final bms = await _repo.getBookmarks();
    final hist = await _repo.getHistory();
    final prefs = await _repo.getSettings();
    state = state.copyWith(
      isLoading: false,
      documents: docs,
      folders: folders,
      bookmarks: bms,
      history: hist,
      settings: prefs,
    );
  }

  void setNavIndex(int index) {
    state = state.copyWith(activeNavIndex: index);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedFolder(String folderId) {
    state = state.copyWith(selectedFolderId: folderId);
  }

  void setSortMode(LibrarySort114 sort) {
    state = state.copyWith(sortBy: sort);
  }

  void toggleGridView() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void dismissAlert() {
    state = state.copyWith(clearAlert: true);
  }

  Future<ImportSummary114> importFromDevice({bool allowMultiple = true}) async {
    final summary = await _repo.pickAndImportPdfs(
      allowMultiple: allowMultiple,
      targetFolderId: state.selectedFolderId,
    );
    await refreshAll();
    if (summary.errors.isNotEmpty) {
      state = state.copyWith(lastError: summary.errors.join('\n'));
    }
    return summary;
  }

  Future<void> editDocumentMetadata({
    required PdfDocModel114 doc,
    required String title,
    required String tags,
    required String description,
    required String folderId,
  }) async {
    await _repo.updateMetadata(
      doc: doc,
      newTitle: title,
      newTags: tags,
      newDescription: description,
      folderId: folderId,
    );
    await refreshAll();
  }

  Future<PdfDocModel114> duplicateDocument(PdfDocModel114 doc) async {
    final copy = await _repo.duplicateDocument(doc);
    await refreshAll();
    return copy;
  }

  Future<void> toggleFavorite(PdfDocModel114 doc) async {
    await _repo.toggleFavorite(doc);
    await refreshAll();
  }

  Future<void> deleteDocument(String id) async {
    await _repo.deleteDocument(id);
    await refreshAll();
  }

  Future<PdfDocModel114> updateReadingProgress(PdfDocModel114 doc, int page) async {
    final updated = await _repo.recordReadingProgress(doc: doc, pageNumber: page);
    final docs = await _repo.getDocuments();
    final hist = await _repo.getHistory();
    state = state.copyWith(documents: docs, history: hist);
    return updated;
  }

  Future<void> addPageBookmark({
    required PdfDocModel114 doc,
    required int pageNumber,
    required String label,
    String note = '',
  }) async {
    await _repo.addBookmark(
      doc: doc,
      pageNumber: pageNumber,
      label: label,
      note: note,
    );
    final bms = await _repo.getBookmarks();
    state = state.copyWith(bookmarks: bms);
  }

  Future<void> removeBookmark(String id) async {
    await _repo.deleteBookmark(id);
    final bms = await _repo.getBookmarks();
    state = state.copyWith(bookmarks: bms);
  }

  Future<void> createNewFolder(String name, int colorHex) async {
    if (name.trim().isEmpty) return;
    await _repo.createFolder(name: name, colorHex: colorHex);
    final folders = await _repo.getFolders();
    state = state.copyWith(folders: folders);
  }

  Future<PdfDocModel114> saveScannedPdf({
    required String title,
    required List<Uint8List> pages,
  }) async {
    final created = await _repo.saveScannedPdfToLibrary(
      title: title,
      processedPages: pages,
    );
    await refreshAll();
    return created;
  }

  Future<PdfDocModel114> saveAnnotatedCopy({
    required PdfDocModel114 originalDoc,
    required List<AnnotationItem114> annotations,
  }) async {
    final created = await _repo.saveAnnotatedCopy(
      originalDoc: originalDoc,
      annotations: annotations,
    );
    await refreshAll();
    return created;
  }

  Future<void> updateSettings(ReaderSettings114 updated) async {
    await _repo.saveSettings(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> resetPreferences() async {
    const defaults = ReaderSettings114();
    await _repo.saveSettings(defaults);
    state = state.copyWith(settings: defaults);
  }

  Future<void> clearHistory() async {
    await _repo.clearReadingHistory();
    state = state.copyWith(history: const []);
  }

  Future<ReminderAlertPayload114> triggerGoalReminderNow() async {
    final latestDoc = state.recentDocuments.isNotEmpty
        ? state.recentDocuments.first.title
        : null;
    final payload = await ReminderNotificationService114.triggerReadingReminder(
      soundProfile: state.settings.notificationSound,
      completedMinutes: state.settings.completedMinutesToday,
      goalMinutes: state.settings.dailyGoalMinutes,
      activeDocTitle: latestDoc,
    );
    state = state.copyWith(latestAlert: payload);
    return payload;
  }
}

final nexusWorkspaceProvider =
    StateNotifierProvider<NexusWorkspaceNotifier, NexusWorkspaceState>((ref) {
  return NexusWorkspaceNotifier(ref.watch(documentRepository114Provider));
});
