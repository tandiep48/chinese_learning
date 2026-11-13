/// Vocab module — the selection-page state machine.
///
/// Ports `useVocabSelect`: mode -> (hsk | book) -> lessons -> parts -> table,
/// plus debounced search, page size and pagination. A [ChangeNotifier] created
/// in the screen's State with the resolved repo + a passage-fetch callback and a
/// translated-strings bag (so the controller stays UI-free).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../shared/data/vocab_row.dart';
import '../data/vocab_repository.dart';
import '../data/vocab_select_logic.dart';

enum VocabTableStatus { prompt, loading, ready }

/// The translated prompt/label strings the controller raises.
class VocabStrings {
  const VocabStrings({
    required this.chooseFilters,
    required this.chooseBook,
    required this.chooseLessonAndPart,
    required this.chooseHskLessonPart,
    required this.chooseHskOnly,
    required this.chooseAPart,
    required this.noVocabFound,
    required this.loadingVocabulary,
    required this.failedLoadVocabulary,
    required this.searching,
    required this.searchFailed,
    required this.loadingLessons,
    required this.failedLoadLessons,
    required this.noLessonsFound,
    required this.noSavedBooks,
    required this.lessonPrefix,
    required this.partPrefix,
    required this.other,
    required this.noResultsFor,
  });

  final String chooseFilters;
  final String chooseBook;
  final String chooseLessonAndPart;
  final String chooseHskLessonPart;
  final String chooseHskOnly;
  final String chooseAPart;
  final String noVocabFound;
  final String loadingVocabulary;
  final String failedLoadVocabulary;
  final String searching;
  final String searchFailed;
  final String loadingLessons;
  final String failedLoadLessons;
  final String noLessonsFound;
  final String noSavedBooks;
  final String lessonPrefix;
  final String partPrefix;
  final String other;
  final String Function(String query) noResultsFor;
}

class VocabSelectController extends ChangeNotifier {
  VocabSelectController({
    required this.repo,
    required this.fetchHskPassageIds,
    required this.strings,
  }) {
    _message = strings.chooseFilters;
  }

  final VocabRepository repo;
  final Future<List<String>> Function(String hskLevelKey) fetchHskPassageIds;
  final VocabStrings strings;

  // Filters
  VocabMode _mode = VocabMode.standard;
  String _hskLevel = '';
  List<({String code, String name})> _bookOptions = const [];
  String _selectedBook = '';
  Map<String, List<PassageMeta>> _grouped = const {};
  List<VocabOption> _lessonOptions = const [];
  List<VocabOption> _partOptions = const [];
  List<String> _selectedLessons = const [];
  List<String> _selectedParts = const [];
  int _pageSize = vocabDefaultPageSize;

  // Table
  List<VocabRow> _rows = const [];
  VocabTableStatus _status = VocabTableStatus.prompt;
  String _message = '';
  int _page = 1;
  int _totalPages = 1;
  int _total = 0;

  // Search
  String _searchQuery = '';
  Timer? _debounce;
  int _requestToken = 0;

  VocabMode get mode => _mode;
  String get hskLevel => _hskLevel;
  bool get isHistory => isHistoryMode(_mode);
  bool get isBook => _mode == VocabMode.book;
  List<({String code, String name})> get bookOptions => _bookOptions;
  String get selectedBook => _selectedBook;
  List<VocabOption> get lessonOptions => _lessonOptions;
  List<VocabOption> get partOptions => _partOptions;
  List<String> get selectedLessons => _selectedLessons;
  List<String> get selectedParts => _selectedParts;
  int get pageSize => _pageSize;
  List<VocabRow> get rows => _rows;
  VocabTableStatus get status => _status;
  String get message => _message;
  int get page => _page;
  int get totalPages => _totalPages;
  int get total => _total;
  String get searchQuery => _searchQuery;
  bool get searchMode => _searchQuery.trim().isNotEmpty;

  String _lessonLabel(String lesson) =>
      lesson == 'Other' ? strings.other : '${strings.lessonPrefix} $lesson';

  int _begin() {
    _requestToken++;
    return _requestToken;
  }

  bool _isCurrent(int token) => token == _requestToken;

  void _prompt(String msg) {
    _status = VocabTableStatus.prompt;
    _message = msg;
    _rows = const [];
    notifyListeners();
  }

  void _loading(String msg) {
    _status = VocabTableStatus.loading;
    _message = msg;
    notifyListeners();
  }

  void _ready(VocabPage data) {
    _rows = data.rows;
    _page = data.page;
    _totalPages = data.totalPages;
    _total = data.total;
    _status = VocabTableStatus.ready;
    notifyListeners();
  }

  // ── Table loading ───────────────────────────────────────────────────────────
  Future<void> _loadTable(int targetPage) async {
    final selectedPassages =
        (_mode == VocabMode.standard || _mode == VocabMode.book)
        ? _selectedParts
        : const <String>[];

    if (_mode == VocabMode.book) {
      if (_selectedBook.isEmpty) return _prompt(strings.chooseBook);
      if (selectedPassages.isEmpty) return _prompt(strings.chooseLessonAndPart);
    }
    if (_mode != VocabMode.book &&
        !isHistory &&
        (_hskLevel.isEmpty ||
            (_mode == VocabMode.standard && selectedPassages.isEmpty))) {
      return _prompt(
        _mode == VocabMode.standard
            ? strings.chooseHskLessonPart
            : strings.chooseHskOnly,
      );
    }

    final token = _begin();
    _loading(strings.loadingVocabulary);
    try {
      final data = _mode == VocabMode.recent
          ? await repo.getLearnedVocab(targetPage, _pageSize)
          : await repo.getTable(
              mode: _mode,
              hskLevel: _hskLevel,
              passages: selectedPassages,
              bookCode: _selectedBook,
              page: targetPage,
              pageSize: _pageSize,
            );
      if (!_isCurrent(token)) return;
      if (data.rows.isEmpty) return _prompt(strings.noVocabFound);
      _ready(data);
    } catch (_) {
      if (!_isCurrent(token)) return;
      _prompt(strings.failedLoadVocabulary);
    }
  }

  Future<void> _loadSavedBooks() async {
    final token = _begin();
    _loading(strings.loadingVocabulary);
    final books = await repo.getSavedBooks();
    if (!_isCurrent(token)) return;
    _bookOptions = books;
    _prompt(books.isNotEmpty ? strings.chooseBook : strings.noSavedBooks);
  }

  Future<void> _runSearch(String query, int targetPage) async {
    final token = _begin();
    _loading(strings.searching);
    try {
      final data = await repo.search(query, targetPage, _pageSize);
      if (!_isCurrent(token)) return;
      if (data.rows.isEmpty) return _prompt(strings.noResultsFor(query));
      _ready(data);
    } catch (_) {
      if (!_isCurrent(token)) return;
      _prompt(strings.searchFailed);
    }
  }

  void _loadLessons(List<String> passageIds) {
    _grouped = groupPassagesByLesson(passageIds);
    _lessonOptions = buildLessonOptions(_grouped, _lessonLabel);
    _partOptions = const [];
    _selectedLessons = const [];
    _selectedParts = const [];
    _rows = const [];
    _status = VocabTableStatus.prompt;
    _message = _lessonOptions.isNotEmpty
        ? strings.chooseLessonAndPart
        : strings.noLessonsFound;
    notifyListeners();
  }

  // ── Public handlers ─────────────────────────────────────────────────────────
  void setMode(VocabMode next) {
    _mode = next;
    _hskLevel = '';
    _grouped = const {};
    _lessonOptions = const [];
    _partOptions = const [];
    _selectedLessons = const [];
    _selectedParts = const [];
    _selectedBook = '';
    _bookOptions = const [];
    _page = 1;
    _rows = const [];
    if (isHistoryMode(next)) {
      _loadTable(1);
    } else if (next == VocabMode.book) {
      _loadSavedBooks();
    } else {
      _prompt(strings.chooseFilters);
    }
  }

  Future<void> setHskLevel(String level) async {
    _hskLevel = level;
    _selectedLessons = const [];
    _selectedParts = const [];
    _partOptions = const [];
    _page = 1;
    if (level.isEmpty) return _prompt(strings.chooseFilters);
    if (_mode == VocabMode.standard) {
      final token = _begin();
      _loading(strings.loadingLessons);
      try {
        final ids = await fetchHskPassageIds(level);
        if (!_isCurrent(token)) return;
        _loadLessons(ids);
      } catch (_) {
        if (!_isCurrent(token)) return;
        _prompt(strings.failedLoadLessons);
      }
    } else {
      // free mode: load the table directly.
      _loadTable(1);
    }
  }

  Future<void> setBook(String bookCode) async {
    _selectedBook = bookCode;
    _selectedLessons = const [];
    _selectedParts = const [];
    _partOptions = const [];
    _page = 1;
    if (bookCode.isEmpty) {
      _lessonOptions = const [];
      _grouped = const {};
      return _prompt(strings.chooseBook);
    }
    final token = _begin();
    _loading(strings.loadingLessons);
    try {
      final ids = await repo.getBookPassages(bookCode);
      if (!_isCurrent(token)) return;
      _loadLessons(ids);
    } catch (_) {
      if (!_isCurrent(token)) return;
      _prompt(strings.failedLoadLessons);
    }
  }

  void changeLessons(List<String> lessons) {
    _selectedLessons = lessons;
    _selectedParts = const [];
    _page = 1;
    if (lessons.isEmpty) {
      _partOptions = const [];
      return _prompt(strings.chooseLessonAndPart);
    }
    _partOptions = buildPartOptions(
      lessons,
      _grouped,
      _lessonLabel,
      (part) => '${strings.partPrefix} $part',
    );
    _prompt(strings.chooseAPart);
  }

  void changeParts(List<String> parts) {
    _selectedParts = parts;
    _page = 1;
    if (parts.isNotEmpty) _loadTable(1);
    notifyListeners();
  }

  void setPageSize(int size) {
    _pageSize = size <= 0 ? vocabDefaultPageSize : size;
    _page = 1;
    if (searchMode) {
      _runSearch(_searchQuery.trim(), 1);
    } else if (isHistory ||
        (_mode == VocabMode.free && _hskLevel.isNotEmpty) ||
        ((_mode == VocabMode.standard || _mode == VocabMode.book) &&
            _selectedParts.isNotEmpty)) {
      _loadTable(1);
    } else {
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      // Returning from search: restore the current mode's table.
      if (isHistory ||
          (_mode == VocabMode.free && _hskLevel.isNotEmpty) ||
          ((_mode == VocabMode.standard || _mode == VocabMode.book) &&
              _selectedParts.isNotEmpty)) {
        _loadTable(1);
      } else {
        _prompt(strings.chooseFilters);
      }
      return;
    }
    notifyListeners();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _page = 1;
      _runSearch(trimmed, 1);
    });
  }

  void goToPage(int delta) {
    final next = _page + delta;
    if (next < 1 || next > _totalPages) return;
    _page = next;
    if (searchMode) {
      _runSearch(_searchQuery.trim(), next);
    } else {
      _loadTable(next);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
