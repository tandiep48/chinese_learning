/// Competition (Learn Together) — the JSON shapes carried over REST + socket.
///
/// Ported 1:1 from `yi-chinese-manage/lib/types/competition.ts`, which mirrors
/// `Learning/web_app/entity/competition/service.py`. A room is created over REST
/// (`POST /api/competition/rooms`); everything after flows over socket.io
/// (`service/competition_socket.py`). Socket payloads arrive as untyped maps, so
/// every `fromJson` tolerates missing/!-typed fields rather than throwing.
library;

import '../../../lesson_trainer/data/models/lesson_task.dart';

int _asInt(Object? v) =>
    v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0);
String _asStr(Object? v) => v == null ? '' : v.toString();
String? _asStrOrNull(Object? v) => v?.toString();

List<Map<String, dynamic>> _mapList(Object? v) => v is List
    ? [
        for (final e in v)
          if (e is Map) e.cast<String, dynamic>(),
      ]
    : const [];

/// A book room's word pool is the deduped union of every participant's saved
/// vocabulary in the picked parts, resolved server-side at session start.
enum CompetitionCategory {
  vocab('vocab'),
  lesson('lesson'),
  book('book');

  const CompetitionCategory(this.wire);
  final String wire;

  static CompetitionCategory fromWire(Object? v) {
    final s = _asStr(v);
    return CompetitionCategory.values.firstWhere(
      (c) => c.wire == s,
      orElse: () => CompetitionCategory.vocab,
    );
  }
}

class CompetitionMember {
  const CompetitionMember({
    required this.userId,
    required this.username,
    required this.role,
    required this.status,
    this.joinedAt,
  });

  final int userId;
  final String username;
  final String role; // "host" | "member"
  final String status;
  final String? joinedAt;

  factory CompetitionMember.fromJson(Map<String, dynamic> j) =>
      CompetitionMember(
        userId: _asInt(j['user_id']),
        username: _asStr(j['username']),
        role: _asStr(j['role']),
        status: _asStr(j['status']),
        joinedAt: _asStrOrNull(j['joined_at']),
      );
}

class CompetitionChatMessage {
  const CompetitionChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.message,
    this.createdAt,
  });

  final int id;
  final int userId;
  final String username;
  final String message;
  final String? createdAt;

  factory CompetitionChatMessage.fromJson(Map<String, dynamic> j) =>
      CompetitionChatMessage(
        id: _asInt(j['id']),
        userId: _asInt(j['user_id']),
        username: _asStr(j['username']),
        message: _asStr(j['message']),
        createdAt: _asStrOrNull(j['created_at']),
      );
}

/// The session summary embedded in a room state (no tasks / scores).
class CompetitionRoomSession {
  const CompetitionRoomSession({
    required this.id,
    required this.status,
    required this.currentSection,
    this.sectionStartedAt,
    this.sectionEndsAt,
    this.startedAt,
    this.finishedAt,
  });

  final int id;
  final String status; // "running" | "ranked"
  final int currentSection;
  final String? sectionStartedAt;
  final String? sectionEndsAt;
  final String? startedAt;
  final String? finishedAt;

  factory CompetitionRoomSession.fromJson(Map<String, dynamic> j) =>
      CompetitionRoomSession(
        id: _asInt(j['id']),
        status: _asStr(j['status']),
        currentSection: _asInt(j['current_section']),
        sectionStartedAt: _asStrOrNull(j['section_started_at']),
        sectionEndsAt: _asStrOrNull(j['section_ends_at']),
        startedAt: _asStrOrNull(j['started_at']),
        finishedAt: _asStrOrNull(j['finished_at']),
      );
}

class CompetitionRoom {
  const CompetitionRoom({
    required this.id,
    required this.roomCode,
    required this.hostUserId,
    required this.level,
    required this.passageIds,
    required this.wordCount,
    required this.maxUsers,
    required this.sectionTimeoutMinutes,
    required this.status,
    required this.category,
    required this.activityType,
    required this.members,
    required this.chat,
    this.session,
  });

  final int id;
  final String roomCode;
  final int hostUserId;
  final int level;
  final List<String> passageIds;
  final int wordCount;
  final int maxUsers;
  final int sectionTimeoutMinutes;
  final String status; // "waiting" | "running" | ...
  final CompetitionCategory category;
  final String activityType; // "all" or a CSV of the room's skill types
  final List<CompetitionMember> members;
  final List<CompetitionChatMessage> chat;
  final CompetitionRoomSession? session;

  factory CompetitionRoom.fromJson(Map<String, dynamic> j) => CompetitionRoom(
    id: _asInt(j['id']),
    roomCode: _asStr(j['room_code']),
    hostUserId: _asInt(j['host_user_id']),
    level: _asInt(j['level']),
    passageIds: [
      for (final p in (j['passage_ids'] as List? ?? const [])) _asStr(p),
    ],
    wordCount: _asInt(j['word_count']),
    maxUsers: _asInt(j['max_users']),
    sectionTimeoutMinutes: _asInt(j['section_timeout_minutes']),
    status: _asStr(j['status']),
    category: CompetitionCategory.fromWire(j['category']),
    activityType: j['activity_type'] == null
        ? 'all'
        : _asStr(j['activity_type']),
    members: [
      for (final m in _mapList(j['members'])) CompetitionMember.fromJson(m),
    ],
    chat: [
      for (final c in _mapList(j['chat'])) CompetitionChatMessage.fromJson(c),
    ],
    session: j['session'] is Map
        ? CompetitionRoomSession.fromJson(
            (j['session'] as Map).cast<String, dynamic>(),
          )
        : null,
  );
}

/// One row of the open-room browse list, pushed over the socket's `open_rooms`.
class OpenRoomSummary {
  const OpenRoomSummary({
    required this.roomCode,
    required this.ownerUsername,
    required this.maxUsers,
    required this.category,
    required this.level,
    required this.memberCount,
    this.createdAt,
  });

  final String roomCode;
  final String ownerUsername;
  final int maxUsers;
  final CompetitionCategory category;
  final int level;
  final int memberCount;
  final String? createdAt;

  bool get isFull => memberCount >= maxUsers;

  factory OpenRoomSummary.fromJson(Map<String, dynamic> j) => OpenRoomSummary(
    roomCode: _asStr(j['room_code']),
    ownerUsername: _asStr(j['owner_username']),
    maxUsers: _asInt(j['max_users']),
    category: CompetitionCategory.fromWire(j['category']),
    level: _asInt(j['level']),
    memberCount: _asInt(j['member_count']),
    createdAt: _asStrOrNull(j['created_at']),
  );
}

class CompetitionScore {
  const CompetitionScore({
    required this.userId,
    required this.username,
    required this.listeningPoints,
    required this.readingPoints,
    required this.totalPoints,
    required this.totalResponseTimeMs,
    required this.rank,
    this.finishedAt,
  });

  final int userId;
  final String username;
  final int listeningPoints;
  final int readingPoints;
  final int totalPoints;
  final int totalResponseTimeMs;
  final int rank;
  final String? finishedAt;

  factory CompetitionScore.fromJson(Map<String, dynamic> j) => CompetitionScore(
    userId: _asInt(j['user_id']),
    username: _asStr(j['username']),
    listeningPoints: _asInt(j['listening_points']),
    readingPoints: _asInt(j['reading_points']),
    totalPoints: _asInt(j['total_points']),
    totalResponseTimeMs: _asInt(j['total_response_time_ms']),
    rank: _asInt(j['rank']),
    finishedAt: _asStrOrNull(j['finished_at']),
  );
}

/// The full session state pushed on session_started / session_finished.
class CompetitionSession {
  const CompetitionSession({
    required this.id,
    required this.status,
    required this.roomId,
    required this.roomCode,
    required this.category,
    required this.activityType,
    required this.lessonTasks,
    required this.scores,
  });

  final int id;
  final String status;
  final int roomId;
  final String roomCode;
  final CompetitionCategory category;
  final String activityType;
  final List<LessonTask> lessonTasks;
  final List<CompetitionScore> scores;

  factory CompetitionSession.fromJson(Map<String, dynamic> j) =>
      CompetitionSession(
        id: _asInt(j['id']),
        status: _asStr(j['status']),
        roomId: _asInt(j['room_id']),
        roomCode: _asStr(j['room_code']),
        category: CompetitionCategory.fromWire(j['category']),
        activityType: j['activity_type'] == null
            ? 'all'
            : _asStr(j['activity_type']),
        lessonTasks: [
          for (final t in _mapList(j['lesson_tasks'])) LessonTask.fromJson(t),
        ],
        scores: [
          for (final s in _mapList(j['scores'])) CompetitionScore.fromJson(s),
        ],
      );
}

/// Create/edit payload for a room (`POST /api/competition/rooms`, host_edit_room).
class CompetitionRoomSettings {
  const CompetitionRoomSettings({
    required this.category,
    required this.activityType,
    required this.level,
    required this.passageIds,
    required this.maxUsers,
    required this.sectionTimeoutMinutes,
  });

  final CompetitionCategory category;
  final String activityType;
  final int level;
  final List<String> passageIds;
  final int maxUsers;
  final int sectionTimeoutMinutes;

  Map<String, dynamic> toJson() => {
    'category': category.wire,
    'activity_type': activityType,
    'level': level,
    'passage_ids': passageIds,
    'max_users': maxUsers,
    'section_timeout_minutes': sectionTimeoutMinutes,
  };
}

/// A `{book_code, name}` row for the Book-mode picker (`/api/vocab/saved-books`).
class SavedBook {
  const SavedBook({required this.bookCode, required this.name});
  final String bookCode;
  final String name;

  factory SavedBook.fromJson(Map<String, dynamic> j) => SavedBook(
    bookCode: _asStr(j['book_code']),
    name: j['name'] == null || _asStr(j['name']).isEmpty
        ? _asStr(j['book_code'])
        : _asStr(j['name']),
  );
}
