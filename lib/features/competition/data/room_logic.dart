/// Competition — pure logic behind the setup form and room summary.
///
/// Ported from `yi-chinese-manage/lib/competition/roomLogic.ts` (itself a port of
/// `Learning/web_app/static/competition/competition.js`). Free of UI and i18n:
/// label prefixes come in through an [OptionLabels] bag and summary lines are
/// returned as i18n keys the screens translate.
library;

import 'models/competition_models.dart';

/// One passage id split into its parts. [lessonKey] scopes a lesson to its HSK
/// level ("H1_2") so lesson numbers never collide across levels.
class PassageInfo {
  const PassageInfo({
    required this.passageId,
    required this.hsk,
    required this.level,
    required this.lesson,
    required this.part,
    required this.lessonKey,
  });

  final String passageId;
  final String hsk;
  final int level;
  final String lesson;
  final String part;
  final String lessonKey;
}

/// One picker option: [value] + display [label], optionally grouped under [group].
class PickerOption {
  const PickerOption({required this.value, required this.label, this.group});
  final String value;
  final String label;
  final String? group;
}

class OptionLabels {
  const OptionLabels({
    required this.lessonPrefix,
    required this.partPrefix,
    required this.other,
  });
  final String lessonPrefix;
  final String partPrefix;
  final String other;
}

/// The i18n key for each selectable skill, per mode.
class TypeOption {
  const TypeOption(this.value, this.key);
  final String value;
  final String key;
}

const List<TypeOption> _vocabTypeSet = [
  TypeOption('typing', 'competitionTypeTyping'),
  TypeOption('listening', 'competitionTypeListening'),
  TypeOption('reading', 'competitionTypeReading'),
];

/// The Type selector offers a different skill set per mode. Book rooms play the
/// vocab trainer, so they share the vocab set.
const Map<CompetitionCategory, List<TypeOption>> typeOptions = {
  CompetitionCategory.vocab: _vocabTypeSet,
  CompetitionCategory.book: _vocabTypeSet,
  CompetitionCategory.lesson: [
    TypeOption('listening', 'competitionTypeListening'),
    TypeOption('meaning', 'competitionTypeMeaning'),
    TypeOption('typing', 'competitionTypeTyping'),
    TypeOption('reorder', 'competitionTypeReorder'),
  ],
};

const List<int> hskLevels = [1, 2, 3, 4, 5, 6];

int _levelOf(String hsk) =>
    int.tryParse(hsk.replaceAll(RegExp(r'\D'), '')) ?? 0;

/// Group header for an option: "HSK 1" for HSK passages, or the book code (whose
/// parsed level is 0).
String sourceGroupLabel(PassageInfo info) =>
    info.level != 0 ? 'HSK ${info.level}' : info.hsk;

/// Real passage ids look like "H1_10_2"; the level is read by stripping
/// non-digits (also accepts "HSK1_...").
PassageInfo parsePassageId(String passageId) {
  final parts = passageId.split('_');
  final hsk = parts.isNotEmpty ? parts[0] : '';
  final hasStructure = parts.length >= 2;
  return PassageInfo(
    passageId: passageId,
    hsk: hsk,
    level: _levelOf(hsk),
    lesson: hasStructure ? parts[1] : 'Other',
    part: parts.length >= 3 ? parts[2] : passageId,
    lessonKey: hasStructure ? '${hsk}_${parts[1]}' : passageId,
  );
}

int _numericSort(String a, String b) {
  if (a == 'Other') return 1;
  if (b == 'Other') return -1;
  final na = int.tryParse(a), nb = int.tryParse(b);
  if (na != null && nb != null && na != nb) return na - nb;
  return a.compareTo(b);
}

int lessonKeySort(String a, String b) {
  final pa = a.split('_'), pb = b.split('_');
  final la = _levelOf(pa[0]), lb = _levelOf(pb[0]);
  if (la != lb) return la - lb;
  return _numericSort(pa.length > 1 ? pa[1] : '', pb.length > 1 ? pb[1] : '');
}

/// Rebuild the lesson -> passages map from the selected sources only, so
/// deselecting a source drops its lessons while the others stay.
Map<String, List<PassageInfo>> groupPassagesByLesson(
  List<String> sources,
  Map<String, List<PassageInfo>> bySource,
) {
  final grouped = <String, List<PassageInfo>>{};
  for (final key in sources) {
    for (final info in (bySource[key] ?? const [])) {
      (grouped[info.lessonKey] ??= []).add(info);
    }
  }
  return grouped;
}

/// Lesson options, grouped under their source header when > 1 source is picked.
List<PickerOption> buildLessonOptions(
  Map<String, List<PassageInfo>> grouped,
  int sourceCount,
  OptionLabels labels,
) {
  final showGroups = sourceCount > 1;
  final keys = grouped.keys.toList()..sort(lessonKeySort);
  return [
    for (final key in keys)
      PickerOption(
        value: key,
        label: grouped[key]!.first.lesson == 'Other'
            ? labels.other
            : '${labels.lessonPrefix} ${grouped[key]!.first.lesson}',
        group: showGroups ? sourceGroupLabel(grouped[key]!.first) : null,
      ),
  ];
}

/// Part options carry the full passage_id; grouped by HSK + lesson when several
/// lessons are selected.
List<PickerOption> buildPartOptions(
  List<String> selectedKeys,
  Map<String, List<PassageInfo>> grouped,
  OptionLabels labels,
) {
  final showGroups = selectedKeys.length > 1;
  final options = <PickerOption>[];
  final keys = [...selectedKeys]..sort(lessonKeySort);
  for (final key in keys) {
    final passages = grouped[key];
    if (passages == null || passages.isEmpty) continue;
    final info = passages.first;
    final groupLabel = info.lesson == 'Other'
        ? labels.other
        : '${sourceGroupLabel(info)} · ${labels.lessonPrefix} ${info.lesson}';
    final sorted = [...passages]
      ..sort(
        (a, b) => (int.tryParse(a.part) ?? 0) - (int.tryParse(b.part) ?? 0),
      );
    for (final p in sorted) {
      options.add(
        PickerOption(
          value: p.passageId,
          label: '${labels.partPrefix} ${p.part}',
          group: showGroups ? groupLabel : null,
        ),
      );
    }
  }
  return options;
}

/// Parse a stored activity_type ("all" or a CSV of values) into a value list,
/// expanding "all" to every option for the mode.
List<String> parseTypeValues(String? activityType, CompetitionCategory mode) {
  final all = [for (final o in typeOptions[mode]!) o.value];
  if (activityType == null || activityType.isEmpty || activityType == 'all') {
    return all;
  }
  final wanted = activityType
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet();
  final picked = all.where(wanted.contains).toList();
  return picked.isNotEmpty ? picked : all;
}

/// Validated room-settings payload (shared by create + edit), or null when no
/// part is picked.
CompetitionRoomSettings? collectRoomSettings({
  required CompetitionCategory mode,
  required List<String> types,
  required List<String> passageIds,
  required int maxUsers,
  required int sectionTimeoutMinutes,
}) {
  if (passageIds.isEmpty) return null;
  final levels = passageIds
      .map((id) => parsePassageId(id).level)
      .where((l) => l != 0)
      .toList();
  return CompetitionRoomSettings(
    category: mode,
    activityType: types.isNotEmpty ? types.join(',') : 'all',
    level: levels.isNotEmpty ? levels.reduce((a, b) => a < b ? a : b) : 1,
    passageIds: passageIds,
    maxUsers: maxUsers,
    sectionTimeoutMinutes: sectionTimeoutMinutes,
  );
}

/// The translatable pieces of a room's lobby summary.
class RoomSummary {
  const RoomSummary({
    required this.sourceLabel,
    required this.modeKey,
    required this.typeKeys,
    required this.allTypes,
    required this.lessonCount,
    required this.partCount,
    required this.countKey,
    required this.count,
    required this.memberCount,
    required this.maxUsers,
    required this.minutes,
  });

  final String sourceLabel;
  final String modeKey;
  final List<String> typeKeys;
  final bool allTypes;
  final int lessonCount;
  final int partCount;
  final String countKey;
  final int count;
  final int memberCount;
  final int maxUsers;
  final int minutes;
}

RoomSummary roomSummary(CompetitionRoom room) {
  final infos = room.passageIds.map(parsePassageId).toList();
  final hskSet = infos.map((i) => i.level).where((l) => l != 0).toSet().toList()
    ..sort();
  final mode = room.category;
  final isBook = mode == CompetitionCategory.book;
  final activityType = room.activityType.isEmpty ? 'all' : room.activityType;
  final byValue = {for (final o in typeOptions[mode]!) o.value: o.key};
  final allTypes = activityType == 'all';
  final bookCodes = infos
      .map((i) => i.hsk)
      .where((h) => h.isNotEmpty)
      .toSet()
      .toList();

  return RoomSummary(
    sourceLabel: isBook
        ? bookCodes.join(', ')
        : hskSet.isNotEmpty
        ? hskSet.map((n) => 'HSK $n').join(', ')
        : 'HSK ${room.level}',
    modeKey: mode == CompetitionCategory.lesson
        ? 'competitionModeLesson'
        : isBook
        ? 'competitionModeBook'
        : 'competitionModeVocab',
    typeKeys: allTypes
        ? const []
        : activityType
              .split(',')
              .map((v) => byValue[v.trim()] ?? v.trim())
              .toList(),
    allTypes: allTypes,
    lessonCount: infos.map((i) => i.lessonKey).toSet().length,
    partCount: room.passageIds.length,
    countKey: mode == CompetitionCategory.lesson
        ? 'competitionTasksSourceCount'
        : isBook
        ? 'competitionBookPoolNote'
        : 'competitionWordsCount',
    count: room.wordCount,
    memberCount: room.members.length,
    maxUsers: room.maxUsers,
    minutes: room.sectionTimeoutMinutes,
  );
}

/// The per-task identity a lesson answer is recorded under ("passage_id:line_id").
String lessonItemKey(String passageId, int lineId) => '$passageId:$lineId';

bool isRoomHost(CompetitionRoom? room, int? userId) =>
    room != null && userId != null && room.hostUserId == userId;

/// The host's Edit / Start controls hide once the room is running.
bool canManageRoom(CompetitionRoom? room, int? userId) =>
    isRoomHost(room, userId) && room?.status != 'running';
