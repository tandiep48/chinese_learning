/// Milestone module — the six-segment step bar.
///
/// Ported from `yi-chinese-manage/components/page/learner/milestone/MilestoneBar.tsx`:
/// a connected track of numbered badges with a step caption. Gating is soft —
/// every segment is tappable (jump to any step); the connector leading into a
/// step fills once the previous step is complete. Uses the approved mockup's
/// sage/teal badge styling (see [MilestoneStyles]).
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../milestone_steps.dart';
import '../styles/milestone_styles.dart';

class MilestoneBar extends StatelessWidget {
  const MilestoneBar({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.isCompleted,
    required this.onSelect,
  });

  final int step;
  final int totalSteps;
  final bool Function(int step) isCompleted;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final rowChildren = <Widget>[];
    for (var n = 1; n <= totalSteps; n++) {
      if (n > 1) {
        rowChildren.add(
          Expanded(
            child: Container(
              height: MilestoneStyles.connectorThickness,
              color: isCompleted(n - 1)
                  ? MilestoneStyles.badgeIdle
                  : MilestoneStyles.connectorColor,
            ),
          ),
        );
      }
      rowChildren.add(
        _Segment(
          number: n,
          current: n == step,
          done: isCompleted(n),
          onTap: () => onSelect(n),
        ),
      );
    }

    return Padding(
      padding: MilestoneStyles.barPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: rowChildren),
          MilestoneStyles.captionGap,
          Text(
            '${l10n.milestoneStepCounter(step, totalSteps)} · ${milestoneStepTitle(l10n, step)}',
            style: MilestoneStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.number,
    required this.current,
    required this.done,
    required this.onTap,
  });

  final int number;
  final bool current;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: MilestoneStyles.badgeSize,
      height: MilestoneStyles.badgeSize,
      decoration: BoxDecoration(
        color: current ? MilestoneStyles.badgeActive : MilestoneStyles.badgeIdle,
        shape: BoxShape.circle,
        border: current
            ? Border.all(
                color: MilestoneStyles.focusRingColor,
                width: MilestoneStyles.focusRingWidth,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: done && !current
          ? const Icon(Icons.check,
              size: MilestoneStyles.badgeIconSize, color: Colors.white)
          : Text('$number', style: MilestoneStyles.badgeLabel),
    );

    return InkResponse(
      onTap: onTap,
      radius: MilestoneStyles.badgeSize,
      child: badge,
    );
  }
}
