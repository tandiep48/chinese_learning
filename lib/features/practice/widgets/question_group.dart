/// Practice module — the layout dispatcher.
///
/// Ported from `QuestionGroup.tsx`: picks a group layout with
/// [classifyGroupLayout] and hands it the shared state + callbacks.
library;

import 'package:flutter/material.dart';

import '../data/group_state.dart';
import '../data/models/practice_question.dart';
import '../data/practice_engine.dart';
import 'group_props.dart';
import 'single_group.dart';
import 't5_listening_group.dart';
import 't5_reading_match_group.dart';
import 'type2_group.dart';
import 'type6_group.dart';

class QuestionGroup extends StatelessWidget {
  const QuestionGroup({
    super.key,
    required this.group,
    required this.state,
    required this.category,
    required this.cb,
  });

  final PracticeGroup group;
  final GroupUIState state;
  final PracticeCategory category;
  final GroupCallbacks cb;

  @override
  Widget build(BuildContext context) {
    switch (classifyGroupLayout(group)) {
      case GroupLayout.type2:
        return Type2Group(
          group: group,
          state: state,
          category: category,
          cb: cb,
        );
      case GroupLayout.t5Listening:
        return T5ListeningGroup(
          group: group,
          state: state,
          category: category,
          cb: cb,
        );
      case GroupLayout.t5ReadingMatch:
        return T5ReadingMatchGroup(
          group: group,
          state: state,
          category: category,
          cb: cb,
          imageMode: false,
        );
      case GroupLayout.t5ReadingImage:
        return T5ReadingMatchGroup(
          group: group,
          state: state,
          category: category,
          cb: cb,
          imageMode: true,
        );
      case GroupLayout.type6Group:
        return Type6Group(
          group: group,
          state: state,
          category: category,
          cb: cb,
        );
      case GroupLayout.single:
        return SingleGroup(
          group: group,
          state: state,
          category: category,
          cb: cb,
        );
    }
  }
}
