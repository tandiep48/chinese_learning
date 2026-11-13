/// Milestone module — the six-segment step bar.
///
/// Ported from `yi-chinese-manage/components/page/learner/milestone/MilestoneBar.tsx`
/// + `milestone.css`: numbered circles joined by connectors, with a step caption.
/// Pending steps are white with a sage outline, done steps are filled sage, the
/// current step is teal and slightly larger. Gating is soft — every segment is
/// tappable; the connector leading into a step fills once the previous step is
/// complete.
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
              constraints: const BoxConstraints(
                minWidth: MilestoneStyles.connectorMinWidth,
              ),
              margin: MilestoneStyles.connectorMargin,
              height: MilestoneStyles.connectorThickness,
              decoration: BoxDecoration(
                color: isCompleted(n - 1)
                    ? MilestoneStyles.connectorDone
                    : MilestoneStyles.connectorIdle,
                borderRadius: BorderRadius.circular(999),
              ),
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
    final filled = current || done;
    final color = current
        ? MilestoneStyles.badgeCurrent
        : (done ? MilestoneStyles.badgeDone : MilestoneStyles.badgeFillIdle);
    final border = filled ? color : MilestoneStyles.badgeBorderIdle;

    final badge = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: MilestoneStyles.badgeSize,
      height: MilestoneStyles.badgeSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: border,
          width: MilestoneStyles.badgeBorderWidth,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: MilestoneStyles.badgeLabel.copyWith(
          color: filled ? Colors.white : MilestoneStyles.badgeNumberIdle,
        ),
      ),
    );

    return InkResponse(
      onTap: onTap,
      radius: MilestoneStyles.badgeSize,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: current ? MilestoneStyles.badgeCurrentScale : 1,
        child: badge,
      ),
    );
  }
}
