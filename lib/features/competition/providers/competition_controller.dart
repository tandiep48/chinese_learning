/// Competition — the Learn Together state machine + setup form controller.
///
/// One [ChangeNotifier] porting three web hooks: `useCompetitionRoom` (the socket
/// connection and the five screens — setup / lobby / section / waiting / ranking —
/// plus every room action), `useCompetitionSetup` (mode / skill types / capacity /
/// timeout) and `useCompetitionSources` (the HSK-level or Book source picker and
/// the Lesson -> Part cascade both feed). Screen-scoped: created in the page's
/// State with the resolved bearer token + repos and disposed with it, so the
/// socket never outlives the screen.
library;

import 'package:flutter/foundation.dart';

import '../data/competition_repository.dart';
import '../data/competition_socket.dart';
import '../data/models/competition_models.dart';
import '../data/room_logic.dart';

enum CompetitionScreen { setup, lobby, section, waiting, ranking }

/// Translatable error strings the controller raises (passed in from l10n so the
/// controller stays UI-free).
class CompetitionStrings {
  const CompetitionStrings({
    required this.serverConnectFailed,
    required this.errorFallback,
    required this.couldNotCreateRoom,
    required this.selectHskLessonPart,
    required this.failedLoadLessons,
    required this.noLessonsFound,
    required this.noSavedBooks,
  });

  final String serverConnectFailed;
  final String errorFallback;
  final String couldNotCreateRoom;
  final String selectHskLessonPart;
  final String failedLoadLessons;
  final String noLessonsFound;
  final String noSavedBooks;
}

const int _defaultMaxUsers = 8;
const int _defaultTimeout = 15;
const List<int> timeoutOptions = [5, 10, 15, 20];

class CompetitionController extends ChangeNotifier {
  CompetitionController({
    required this.baseUrl,
    required this.token,
    required this.userId,
    required this.repo,
    required this.fetchHskPassageIds,
    required this.labels,
    required this.strings,
  }) {
    _types = [for (final o in typeOptions[_mode]!) o.value];
    _connect();
  }

  final String baseUrl;
  final String token;
  final int userId;
  final CompetitionRepository repo;

  /// Passage ids for an HSK level key (e.g. "HSK1"), from the lessons repository.
  final Future<List<String>> Function(String hskLevelKey) fetchHskPassageIds;
  final OptionLabels labels;
  final CompetitionStrings strings;

  // ── Room-machine state (useCompetitionRoom) ────────────────────────────────
  CompetitionScreen _screen = CompetitionScreen.setup;
  CompetitionRoom? _room;
  CompetitionSession? _session;
  List<CompetitionScore> _scores = const [];
  List<CompetitionChatMessage> _chat = const [];
  List<String> _waitingUsers = const [];
  bool _editing = false;
  String _error = '';
  List<OpenRoomSummary> _openRooms = const [];
  String? _roomCode;

  CompetitionScreen get screen => _screen;
  CompetitionRoom? get room => _room;
  CompetitionSession? get session => _session;
  List<CompetitionScore> get scores => _scores;
  List<CompetitionChatMessage> get chat => _chat;
  List<String> get waitingUsers => _waitingUsers;
  bool get editing => _editing;
  String get error => _error;
  List<OpenRoomSummary> get openRooms => _openRooms;

  // ── Setup-form state (useCompetitionSetup) ──────────────────────────────────
  CompetitionCategory _mode = CompetitionCategory.vocab;
  late List<String> _types;
  int _maxUsers = _defaultMaxUsers;
  int _timeoutMinutes = _defaultTimeout;

  CompetitionCategory get mode => _mode;
  bool get isBook => _mode == CompetitionCategory.book;
  List<String> get types => _types;
  int get maxUsers => _maxUsers;
  int get timeoutMinutes => _timeoutMinutes;
  List<TypeOption> get typeOptionsForMode => typeOptions[_mode]!;

  // ── Source-picker state (useCompetitionSources) ─────────────────────────────
  List<String> _levels = const [];
  List<String> _books = const [];
  List<SavedBook> _bookOptions = const [];
  List<String> _lessonKeys = const [];
  List<String> _partIds = const [];
  Map<String, List<PassageInfo>> _grouped = const {};

  final Map<int, List<PassageInfo>> _levelCache = {};
  final Map<String, List<PassageInfo>> _bookCache = {};

  List<String> get levels => _levels;
  List<String> get books => _books;
  List<SavedBook> get bookOptions => _bookOptions;
  List<String> get lessonKeys => _lessonKeys;
  List<String> get partIds => _partIds;

  int get _sourceCount => isBook ? _books.length : _levels.length;
  List<PickerOption> get lessonOptions =>
      buildLessonOptions(_grouped, _sourceCount, labels);
  List<PickerOption> get partOptions =>
      buildPartOptions(_lessonKeys, _grouped, labels);

  CompetitionSocket? _socket;

  // ── Socket wiring (useCompetitionRoom's mount effect) ───────────────────────
  void _connect() {
    final socket = CompetitionSocket(baseUrl: baseUrl, token: token);
    _socket = socket;
    socket.connect(
      onConnect: () {
        _error = '';
        if (_roomCode == null) socket.emit('browse_open_rooms');
        notifyListeners();
      },
      onConnectError: () {
        _error = strings.serverConnectFailed;
        notifyListeners();
      },
      handlers: {
        'open_rooms': (d) {
          _openRooms = [
            for (final r in (d['rooms'] as List? ?? const []))
              if (r is Map) OpenRoomSummary.fromJson(r.cast<String, dynamic>()),
          ];
          notifyListeners();
        },
        'competition_error': (d) {
          final msg = d['error'];
          _error = (msg is String && msg.isNotEmpty)
              ? msg
              : strings.errorFallback;
          notifyListeners();
        },
        'joined_room': (d) {
          final joined = CompetitionRoom.fromJson(
            (d['room'] as Map).cast<String, dynamic>(),
          );
          _room = joined;
          _roomCode = joined.roomCode;
          _chat = joined.chat;
          _screen = CompetitionScreen.lobby;
          socket.emit('stop_browse_open_rooms');
          _openRooms = const [];
          notifyListeners();
        },
        'room_state': (d) {
          if (d['room'] is! Map) return;
          final state = CompetitionRoom.fromJson(
            (d['room'] as Map).cast<String, dynamic>(),
          );
          _room = state;
          _roomCode = state.roomCode;
          _chat = state.chat;
          notifyListeners();
        },
        'room_settings_saved': (d) {
          if (d['room'] is Map) {
            _room = CompetitionRoom.fromJson(
              (d['room'] as Map).cast<String, dynamic>(),
            );
          }
          _editing = false;
          _screen = CompetitionScreen.lobby;
          notifyListeners();
        },
        'chat_message': (d) {
          _chat = [..._chat, CompetitionChatMessage.fromJson(d)];
          notifyListeners();
        },
        'session_started': (d) {
          _session = CompetitionSession.fromJson(
            (d['session'] as Map).cast<String, dynamic>(),
          );
          _waitingUsers = const [];
          _scores = _session!.scores;
          _screen = CompetitionScreen.section;
          notifyListeners();
        },
        'score_update': (d) {
          _scores = _parseScores(d['scores']);
          notifyListeners();
        },
        'participant_waiting': (d) {
          final name = d['username'];
          if (name is String &&
              name.isNotEmpty &&
              !_waitingUsers.contains(name)) {
            _waitingUsers = [..._waitingUsers, name];
            notifyListeners();
          }
        },
        'session_finished': (d) {
          final scores = d['scores'];
          if (scores is List && scores.isNotEmpty) {
            _scores = _parseScores(scores);
          } else if (d['session'] is Map) {
            _scores = _parseScores((d['session'] as Map)['scores']);
          }
          _screen = CompetitionScreen.ranking;
          notifyListeners();
        },
        'ranking_update': (d) {
          _scores = _parseScores(d['scores']);
          notifyListeners();
        },
        'return_to_lobby': (_) {
          _screen = CompetitionScreen.lobby;
          notifyListeners();
        },
      },
    );
  }

  List<CompetitionScore> _parseScores(Object? raw) => [
    for (final s in (raw as List? ?? const []))
      if (s is Map) CompetitionScore.fromJson(s.cast<String, dynamic>()),
  ];

  // ── Room actions ────────────────────────────────────────────────────────────
  Future<void> createRoom(CompetitionRoomSettings settings) async {
    try {
      final created = await repo.createRoom(settings);
      _socket?.emit('join_room', {'room_code': created.roomCode});
    } catch (e) {
      _error = e.toString().isNotEmpty
          ? _message(e)
          : strings.couldNotCreateRoom;
      notifyListeners();
    }
  }

  String _message(Object e) {
    final s = e.toString();
    return s.startsWith('Exception: ') ? s.substring('Exception: '.length) : s;
  }

  void joinRoom(String code) {
    final roomCode = code.trim().toUpperCase();
    if (roomCode.isEmpty) return;
    _socket?.emit('join_room', {'room_code': roomCode});
  }

  void leaveRoom() {
    final roomCode = _roomCode;
    if (roomCode == null) return;
    _socket?.emit('leave_room', {'room_code': roomCode});
    _roomCode = null;
    _room = null;
    _session = null;
    _chat = const [];
    _editing = false;
    _screen = CompetitionScreen.setup;
    _socket?.emit('browse_open_rooms');
    notifyListeners();
  }

  void sendChat(String message) {
    final roomCode = _roomCode;
    final text = message.trim();
    if (text.isEmpty || roomCode == null) return;
    _socket?.emit('chat_message', {'room_code': roomCode, 'message': text});
  }

  void startSession() {
    final roomCode = _roomCode;
    if (roomCode == null) return;
    _socket?.emit('host_start_session', {'room_code': roomCode});
  }

  void saveSettings(CompetitionRoomSettings settings) {
    final roomCode = _roomCode;
    if (roomCode == null) return;
    _socket?.emit('host_edit_room', {
      'room_code': roomCode,
      ...settings.toJson(),
    });
  }

  void beginEdit() {
    _editing = true;
    _error = '';
    _screen = CompetitionScreen.setup;
    notifyListeners();
  }

  void cancelEdit() {
    _editing = false;
    _screen = CompetitionScreen.lobby;
    notifyListeners();
  }

  void finishTrainer() {
    final roomCode = _roomCode;
    final session = _session;
    if (roomCode != null && session != null) {
      _socket?.emit('participant_finished', {
        'room_code': roomCode,
        'session_id': session.id,
      });
    }
    _screen = CompetitionScreen.waiting;
    notifyListeners();
  }

  void returnToLobby() {
    final roomCode = _roomCode;
    if (roomCode == null) return;
    _socket?.emit('return_to_lobby', {'room_code': roomCode});
    _screen = CompetitionScreen.lobby;
    notifyListeners();
  }

  void sendVocabAnswer(
    String word,
    String activityType,
    bool isCorrect,
    int responseMs,
    int wrongAttempts,
  ) {
    final roomCode = _roomCode;
    final session = _session;
    if (roomCode == null || session == null) return;
    _socket?.emit('vocab_answer', {
      'room_code': roomCode,
      'session_id': session.id,
      'word': word,
      'activity_type': activityType,
      'is_correct': isCorrect,
      'response_time_ms': responseMs,
      'wrong_attempts': wrongAttempts,
    });
  }

  void sendLessonAnswer(
    String itemKey,
    String taskType,
    bool isCorrect,
    int responseMs,
  ) {
    final roomCode = _roomCode;
    final session = _session;
    if (roomCode == null || session == null) return;
    _socket?.emit('lesson_answer', {
      'room_code': roomCode,
      'session_id': session.id,
      'item_key': itemKey,
      'task_type': taskType,
      'is_correct': isCorrect,
      'response_time_ms': responseMs,
    });
  }

  // ── Setup form ──────────────────────────────────────────────────────────────
  Future<void> setMode(CompetitionCategory next) async {
    _mode = next;
    _types = [for (final o in typeOptions[next]!) o.value];
    await _resetForMode(next == CompetitionCategory.book);
  }

  void setTypes(List<String> next) {
    _types = next;
    notifyListeners();
  }

  void setMaxUsers(int n) {
    _maxUsers = n;
    notifyListeners();
  }

  void setTimeoutMinutes(int n) {
    _timeoutMinutes = n;
    notifyListeners();
  }

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  CompetitionRoomSettings? buildSettings() {
    final settings = collectRoomSettings(
      mode: _mode,
      types: _types,
      passageIds: _partIds,
      maxUsers: _maxUsers,
      sectionTimeoutMinutes: _timeoutMinutes,
    );
    if (settings == null) {
      _error = strings.selectHskLessonPart;
      notifyListeners();
      return null;
    }
    _error = '';
    notifyListeners();
    return settings;
  }

  /// Create a room, or save the edited one (CompetitionPage.submitRoom).
  Future<void> submitRoom() async {
    final settings = buildSettings();
    if (settings == null) return;
    if (_editing) {
      saveSettings(settings);
    } else {
      await createRoom(settings);
    }
  }

  void editRoomSettings() {
    final room = _room;
    if (room == null) return;
    beginEdit();
    _prefillFromRoom(room);
  }

  // ── Source picker + cascade ─────────────────────────────────────────────────
  void _clearCascade() {
    _grouped = const {};
    _lessonKeys = const [];
    _partIds = const [];
  }

  void _applyGrouped(
    Map<String, List<PassageInfo>> next,
    KeepPicks? keep,
    String emptyError,
  ) {
    _grouped = next;
    if (next.isEmpty) {
      _error = emptyError;
      notifyListeners();
      return;
    }
    final keptLessons = keep?.lessonKeys ?? _lessonKeys;
    final validLessons = keptLessons.where(next.containsKey).toList();
    _lessonKeys = validLessons;
    final validIds = <String>{
      for (final key in validLessons)
        for (final p in (next[key] ?? const [])) p.passageId,
    };
    final keptParts = keep?.partIds ?? _partIds;
    _partIds = keptParts.where(validIds.contains).toList();
    notifyListeners();
  }

  Future<void> setLevels(List<String> next, {KeepPicks? keep}) async {
    _levels = next;
    final nums = next
        .map(int.tryParse)
        .whereType<int>()
        .where((n) => n != 0)
        .toList();
    if (nums.isEmpty) {
      _clearCascade();
      notifyListeners();
      return;
    }
    _error = '';
    try {
      await Future.wait(
        nums.where((n) => !_levelCache.containsKey(n)).map((n) async {
          final ids = await fetchHskPassageIds('HSK$n');
          _levelCache[n] = ids.map(parsePassageId).toList();
        }),
      );
    } catch (_) {
      _error = strings.failedLoadLessons;
      notifyListeners();
      return;
    }
    _applyGrouped(
      groupPassagesByLesson(
        [for (final n in nums) '$n'],
        {for (final n in nums) '$n': _levelCache[n] ?? const []},
      ),
      keep,
      strings.noLessonsFound,
    );
  }

  Future<void> setBooks(List<String> next, {KeepPicks? keep}) async {
    _books = next;
    if (next.isEmpty) {
      _clearCascade();
      notifyListeners();
      return;
    }
    _error = '';
    try {
      await Future.wait(
        next.where((c) => !_bookCache.containsKey(c)).map((code) async {
          final ids = await repo.getBookPassages(code);
          _bookCache[code] = ids.map(parsePassageId).toList();
        }),
      );
    } catch (_) {
      _error = strings.failedLoadLessons;
      notifyListeners();
      return;
    }
    _applyGrouped(
      groupPassagesByLesson(next, {
        for (final c in next) c: _bookCache[c] ?? const [],
      }),
      keep,
      strings.noSavedBooks,
    );
  }

  void setLevelsSelection(List<String> next) => setLevels(next);
  void setBooksSelection(List<String> next) => setBooks(next);

  void setLessonKeys(List<String> next) {
    _lessonKeys = next;
    final validIds = <String>{
      for (final key in next)
        for (final p in (_grouped[key] ?? const [])) p.passageId,
    };
    _partIds = _partIds.where(validIds.contains).toList();
    notifyListeners();
  }

  void setPartIds(List<String> next) {
    _partIds = next;
    notifyListeners();
  }

  Future<void> _loadBookOptions() async {
    final saved = await repo.getSavedBooks();
    _bookOptions = saved;
    if (saved.isEmpty) _error = strings.noSavedBooks;
    notifyListeners();
  }

  Future<void> _resetForMode(bool nextIsBook) async {
    _levels = const [];
    _books = const [];
    _clearCascade();
    _error = '';
    if (nextIsBook) {
      await _loadBookOptions();
    } else {
      _bookOptions = const [];
    }
    notifyListeners();
  }

  Future<void> _prefillFromRoom(CompetitionRoom room) async {
    final roomMode = room.category;
    _mode = roomMode;
    _types = parseTypeValues(room.activityType, roomMode);
    _maxUsers = room.maxUsers == 0 ? _defaultMaxUsers : room.maxUsers;
    _timeoutMinutes = room.sectionTimeoutMinutes == 0
        ? _defaultTimeout
        : room.sectionTimeoutMinutes;
    final infos = room.passageIds.map(parsePassageId).toList();
    final keep = KeepPicks(
      lessonKeys: infos.map((i) => i.lessonKey).toSet().toList(),
      partIds: room.passageIds,
    );
    if (roomMode == CompetitionCategory.book) {
      _levels = const [];
      await _loadBookOptions();
      await setBooks(
        infos.map((i) => i.hsk).where((h) => h.isNotEmpty).toSet().toList(),
        keep: keep,
      );
    } else {
      _books = const [];
      _bookOptions = const [];
      await setLevels(
        infos.map((i) => '${i.level}').where((v) => v != '0').toSet().toList(),
        keep: keep,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _socket?.dispose();
    _socket = null;
    super.dispose();
  }
}

class KeepPicks {
  const KeepPicks({this.lessonKeys, this.partIds});
  final List<String>? lessonKeys;
  final List<String>? partIds;
}
