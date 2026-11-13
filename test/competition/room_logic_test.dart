/// Unit tests for the competition (Learn Together) pure room logic.
///
/// Covers the passage parsing, lesson/part grouping, type-selection expansion,
/// settings collection, lobby summary and host-permission helpers — all pure,
/// so no device, backend or widget tree is needed.
library;

import 'package:chinese_learning/features/competition/data/models/competition_models.dart';
import 'package:chinese_learning/features/competition/data/room_logic.dart';
import 'package:flutter_test/flutter_test.dart';

CompetitionRoom _room({
  String category = 'vocab',
  List<String> passageIds = const ['H1_1_1', 'H1_1_2'],
  String activityType = 'all',
  int level = 1,
  int wordCount = 10,
  int maxUsers = 8,
  int timeout = 15,
  int hostUserId = 7,
  String status = 'waiting',
  List<Map<String, dynamic>> members = const [],
}) {
  return CompetitionRoom.fromJson({
    'id': 1,
    'room_code': 'ABC123',
    'host_user_id': hostUserId,
    'level': level,
    'passage_ids': passageIds,
    'word_count': wordCount,
    'max_users': maxUsers,
    'section_timeout_minutes': timeout,
    'status': status,
    'category': category,
    'activity_type': activityType,
    'members': members,
    'chat': const [],
  });
}

void main() {
  const labels = OptionLabels(lessonPrefix: 'Lesson', partPrefix: 'Part', other: 'Other');

  group('parsePassageId', () {
    test('splits a real HSK id into level/lesson/part/lessonKey', () {
      final info = parsePassageId('H2_3_1');
      expect(info.hsk, 'H2');
      expect(info.level, 2);
      expect(info.lesson, '3');
      expect(info.part, '1');
      expect(info.lessonKey, 'H2_3');
    });

    test('a book id (non-numeric prefix) parses to level 0', () {
      final info = parsePassageId('ZGL_4_2');
      expect(info.level, 0);
      expect(info.hsk, 'ZGL');
      expect(info.lessonKey, 'ZGL_4');
    });

    test('an unstructured id falls back to Other / itself', () {
      final info = parsePassageId('weird');
      expect(info.lesson, 'Other');
      expect(info.part, 'weird');
      expect(info.lessonKey, 'weird');
    });
  });

  group('grouping + options', () {
    final grouped = groupPassagesByLesson(
      ['1'],
      {
        '1': [parsePassageId('H1_1_1'), parsePassageId('H1_1_2')],
      },
    );

    test('groups passages under their lessonKey', () {
      expect(grouped.keys, ['H1_1']);
      expect(grouped['H1_1']!.length, 2);
    });

    test('buildLessonOptions labels lessons', () {
      final opts = buildLessonOptions(grouped, 1, labels);
      expect(opts.single.value, 'H1_1');
      expect(opts.single.label, 'Lesson 1');
      expect(opts.single.group, isNull); // single source → no group header
    });

    test('buildPartOptions carries the full passage id and sorts by part', () {
      final opts = buildPartOptions(['H1_1'], grouped, labels);
      expect(opts.map((o) => o.value), ['H1_1_1', 'H1_1_2']);
      expect(opts.first.label, 'Part 1');
    });

    test('lessonKeySort orders by HSK level then lesson number', () {
      final keys = ['H2_1', 'H1_10', 'H1_2']..sort(lessonKeySort);
      expect(keys, ['H1_2', 'H1_10', 'H2_1']);
    });
  });

  group('parseTypeValues', () {
    test('"all" expands to every skill for the mode', () {
      expect(parseTypeValues('all', CompetitionCategory.vocab),
          ['typing', 'listening', 'reading']);
      expect(parseTypeValues(null, CompetitionCategory.lesson),
          ['listening', 'meaning', 'typing', 'reorder']);
    });

    test('a CSV keeps the known subset in option order', () {
      expect(parseTypeValues('reading,typing', CompetitionCategory.vocab),
          ['typing', 'reading']);
    });

    test('an unknown selection falls back to all', () {
      expect(parseTypeValues('nope', CompetitionCategory.vocab),
          ['typing', 'listening', 'reading']);
    });
  });

  group('collectRoomSettings', () {
    test('returns null when no part is picked', () {
      final s = collectRoomSettings(
        mode: CompetitionCategory.vocab,
        types: const ['typing'],
        passageIds: const [],
        maxUsers: 8,
        sectionTimeoutMinutes: 15,
      );
      expect(s, isNull);
    });

    test('joins types, picks the lowest level, and carries the parts', () {
      final s = collectRoomSettings(
        mode: CompetitionCategory.vocab,
        types: const ['typing', 'reading'],
        passageIds: const ['H3_1_1', 'H1_2_1'],
        maxUsers: 6,
        sectionTimeoutMinutes: 10,
      )!;
      expect(s.activityType, 'typing,reading');
      expect(s.level, 1); // min of {3, 1}
      expect(s.passageIds, ['H3_1_1', 'H1_2_1']);
      expect(s.toJson()['category'], 'vocab');
    });

    test('empty types serialize to "all"', () {
      final s = collectRoomSettings(
        mode: CompetitionCategory.book,
        types: const [],
        passageIds: const ['ABC_1_1'],
        maxUsers: 4,
        sectionTimeoutMinutes: 5,
      )!;
      expect(s.activityType, 'all');
      expect(s.level, 1); // no numeric levels → default 1
    });
  });

  group('roomSummary', () {
    test('vocab room: source label, counts and "all types"', () {
      final s = roomSummary(_room());
      expect(s.sourceLabel, 'HSK 1');
      expect(s.modeKey, 'competitionModeVocab');
      expect(s.allTypes, isTrue);
      expect(s.typeKeys, isEmpty);
      expect(s.lessonCount, 1);
      expect(s.partCount, 2);
      expect(s.countKey, 'competitionWordsCount');
      expect(s.count, 10);
    });

    test('lesson room counts tasks; a CSV lists type keys', () {
      final s = roomSummary(_room(category: 'lesson', activityType: 'meaning,typing'));
      expect(s.modeKey, 'competitionModeLesson');
      expect(s.countKey, 'competitionTasksSourceCount');
      expect(s.allTypes, isFalse);
      expect(s.typeKeys, ['competitionTypeMeaning', 'competitionTypeTyping']);
    });

    test('book room uses the book-pool note and book codes', () {
      final s = roomSummary(_room(category: 'book', passageIds: ['ABC_1_1', 'ABC_1_2']));
      expect(s.countKey, 'competitionBookPoolNote');
      expect(s.sourceLabel, 'ABC');
    });
  });

  group('host helpers', () {
    test('lessonItemKey joins passage and line', () {
      expect(lessonItemKey('H1_1_1', 5), 'H1_1_1:5');
    });

    test('isRoomHost / canManageRoom', () {
      final waiting = _room(hostUserId: 7, status: 'waiting');
      expect(isRoomHost(waiting, 7), isTrue);
      expect(isRoomHost(waiting, 9), isFalse);
      expect(canManageRoom(waiting, 7), isTrue);
      expect(canManageRoom(_room(hostUserId: 7, status: 'running'), 7), isFalse);
      expect(canManageRoom(null, 7), isFalse);
    });
  });
}
