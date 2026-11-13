/// Practice module — the callback contract every group layout shares.
///
/// Mirrors the `GroupProps` interaction callbacks in
/// `yi-chinese-manage/components/page/learner/practice/question-types/types.ts`.
/// The runner builds one [GroupCallbacks] and hands it down to the active layout.
library;

typedef SelectCb = void Function(String blockId, String key);
typedef ToggleCb = void Function(String blockId, String key);
typedef BlankCb = void Function(String blockId, int index);
typedef AssignCb = void Function(String key);

class GroupCallbacks {
  const GroupCallbacks({
    required this.onSelectMC,
    required this.onSelectKey,
    required this.onToggleChip,
    required this.onBlankClick,
    required this.onAssignT6,
  });

  final SelectCb onSelectMC;
  final SelectCb onSelectKey;
  final ToggleCb onToggleChip;
  final BlankCb onBlankClick;
  final AssignCb onAssignT6;
}
