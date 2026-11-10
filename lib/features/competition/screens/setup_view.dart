/// Competition — the setup screen (web `SetupScreen`).
///
/// The create/edit form (mode, skill types, source -> lesson -> part cascade,
/// capacity, time limit) plus the join-by-code panel and the live open-room
/// browser. The form state lives in [CompetitionController]; this view holds only
/// the join-code draft and the open-room page index.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/competition_models.dart';
import '../data/room_logic.dart';
import '../providers/competition_controller.dart';
import '../styles/competition_styles.dart';
import '../widgets/competition_multi_select.dart';

const int _openRoomsPerPage = 5;

class CompetitionSetupView extends StatefulWidget {
  const CompetitionSetupView({super.key, required this.controller});

  final CompetitionController controller;

  @override
  State<CompetitionSetupView> createState() => _CompetitionSetupViewState();
}

class _CompetitionSetupViewState extends State<CompetitionSetupView> {
  final _joinController = TextEditingController();
  int _roomPage = 1;

  CompetitionController get c => widget.controller;

  @override
  void dispose() {
    _joinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String count(int n) => l10n.competitionNSelected(n);

    return SingleChildScrollView(
      padding: CompetitionStyles.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.competitionTitle, style: CompetitionStyles.h1),
          const SizedBox(height: 4),
          Text(l10n.competitionSubtitle, style: CompetitionStyles.subtitle),
          CompetitionStyles.gap16,
          _createPanel(l10n, count),
          if (!c.editing) ...[
            CompetitionStyles.gap16,
            _joinPanel(l10n),
            CompetitionStyles.gap16,
            _openRoomsPanel(l10n),
          ],
        ],
      ),
    );
  }

  Widget _panel({required String title, required List<Widget> children}) {
    return Container(
      padding: CompetitionStyles.panelPadding,
      decoration: CompetitionStyles.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: CompetitionStyles.h2),
          CompetitionStyles.gap12,
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: CompetitionStyles.label),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _createPanel(AppLocalizations l10n, String Function(int) count) {
    return _panel(
      title: c.editing
          ? l10n.competitionEditSettings
          : l10n.competitionCreateRoom,
      children: [
        _field(
          l10n.competitionMode,
          DropdownButtonFormField<CompetitionCategory>(
            initialValue: c.mode,
            decoration: CompetitionStyles.inputDecoration(null),
            items: [
              DropdownMenuItem(
                value: CompetitionCategory.vocab,
                child: Text(l10n.competitionModeVocab),
              ),
              DropdownMenuItem(
                value: CompetitionCategory.lesson,
                child: Text(l10n.competitionModeLesson),
              ),
              DropdownMenuItem(
                value: CompetitionCategory.book,
                child: Text(l10n.competitionModeBook),
              ),
            ],
            onChanged: (v) {
              if (v != null) c.setMode(v);
            },
          ),
        ),
        if (c.isBook)
          _field(
            l10n.competitionBook,
            CompetitionMultiSelect(
              options: [
                for (final b in c.bookOptions)
                  PickerOption(value: b.bookCode, label: b.name),
              ],
              values: c.books,
              onChanged: c.setBooks,
              placeholder: l10n.competitionSelectBook,
              selectAllLabel: l10n.competitionSelectAll,
              countLabel: count,
              doneLabel: l10n.competitionDone,
            ),
          ),
        _field(
          l10n.competitionType,
          CompetitionMultiSelect(
            options: [
              for (final o in c.typeOptionsForMode)
                PickerOption(value: o.value, label: _typeLabel(l10n, o.key)),
            ],
            values: c.types,
            onChanged: c.setTypes,
            placeholder: l10n.competitionTypeAll,
            selectAllLabel: l10n.competitionTypeAll,
            countLabel: count,
            doneLabel: l10n.competitionDone,
          ),
        ),
        if (!c.isBook)
          _field(
            'HSK',
            CompetitionMultiSelect(
              options: [
                for (final n in const [1, 2, 3, 4, 5, 6])
                  PickerOption(value: '$n', label: 'HSK $n'),
              ],
              values: c.levels,
              onChanged: c.setLevels,
              placeholder: l10n.competitionSelectHsk,
              selectAllLabel: l10n.competitionSelectAll,
              countLabel: count,
              doneLabel: l10n.competitionDone,
            ),
          ),
        _field(
          l10n.competitionLessonPrefix,
          CompetitionMultiSelect(
            options: c.lessonOptions,
            values: c.lessonKeys,
            onChanged: c.setLessonKeys,
            placeholder: l10n.competitionSelectLesson,
            selectAllLabel: l10n.competitionSelectAll,
            countLabel: count,
            doneLabel: l10n.competitionDone,
          ),
        ),
        _field(
          l10n.competitionPartPrefix,
          CompetitionMultiSelect(
            options: c.partOptions,
            values: c.partIds,
            onChanged: c.setPartIds,
            placeholder: l10n.competitionSelectPart,
            selectAllLabel: l10n.competitionSelectAll,
            countLabel: count,
            doneLabel: l10n.competitionDone,
          ),
        ),
        _field(
          l10n.competitionMaxUsers,
          DropdownButtonFormField<int>(
            initialValue: c.maxUsers,
            decoration: CompetitionStyles.inputDecoration(null),
            items: [
              for (var n = 2; n <= 30; n += 1)
                DropdownMenuItem(value: n, child: Text('$n')),
            ],
            onChanged: (v) {
              if (v != null) c.setMaxUsers(v);
            },
          ),
        ),
        _field(
          l10n.competitionTimeLimit,
          DropdownButtonFormField<int>(
            initialValue: c.timeoutMinutes,
            decoration: CompetitionStyles.inputDecoration(null),
            items: [
              for (final n in timeoutOptions)
                DropdownMenuItem(
                  value: n,
                  child: Text(l10n.competitionMinutes(n)),
                ),
            ],
            onChanged: (v) {
              if (v != null) c.setTimeoutMinutes(v);
            },
          ),
        ),
        if (c.error.isNotEmpty) ...[
          Text(c.error, style: CompetitionStyles.errorText),
          CompetitionStyles.gap8,
        ],
        Row(
          children: [
            Expanded(
              child: FilledButton(
                style: CompetitionStyles.primaryButton,
                onPressed: () => c.submitRoom(),
                child: Text(
                  c.editing
                      ? l10n.competitionSaveChanges
                      : l10n.competitionCreateRoom,
                ),
              ),
            ),
            if (c.editing) ...[
              CompetitionStyles.wgap12,
              Expanded(
                child: OutlinedButton(
                  style: CompetitionStyles.secondaryButton,
                  onPressed: c.cancelEdit,
                  child: Text(l10n.competitionCancel),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _joinPanel(AppLocalizations l10n) {
    return _panel(
      title: l10n.competitionJoinRoom,
      children: [
        _field(
          l10n.competitionRoomCode,
          TextField(
            controller: _joinController,
            maxLength: 12,
            textCapitalization: TextCapitalization.characters,
            style: CompetitionStyles.body,
            decoration: CompetitionStyles.inputDecoration('ABC123')
                .copyWith(counterText: ''),
            onSubmitted: (_) => c.joinRoom(_joinController.text),
          ),
        ),
        FilledButton(
          style: CompetitionStyles.primaryButton,
          onPressed: () => c.joinRoom(_joinController.text),
          child: Text(l10n.competitionJoinRoom),
        ),
      ],
    );
  }

  Widget _openRoomsPanel(AppLocalizations l10n) {
    final rooms = c.openRooms;
    final totalPages = (rooms.length / _openRoomsPerPage).ceil().clamp(1, 9999);
    final pageShown = _roomPage.clamp(1, totalPages);
    final paged = rooms
        .skip((pageShown - 1) * _openRoomsPerPage)
        .take(_openRoomsPerPage);

    return _panel(
      title: l10n.competitionOpenRoomsTitle,
      children: [
        if (rooms.isEmpty)
          Text(l10n.competitionNoOpenRooms, style: CompetitionStyles.muted)
        else
          for (final r in paged)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _openRoomCard(l10n, r),
            ),
        if (totalPages > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: pageShown <= 1
                    ? null
                    : () => setState(() => _roomPage = pageShown - 1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                l10n.competitionPageStatus(pageShown, totalPages),
                style: CompetitionStyles.muted,
              ),
              IconButton(
                onPressed: pageShown >= totalPages
                    ? null
                    : () => setState(() => _roomPage = pageShown + 1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
      ],
    );
  }

  Widget _openRoomCard(AppLocalizations l10n, OpenRoomSummary r) {
    final modeLabel = _modeLabel(l10n, r.category);
    return Container(
      padding: CompetitionStyles.openRoomPadding,
      decoration: CompetitionStyles.openRoomCard,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.roomCode,
                  style: CompetitionStyles.roomCode.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  '$modeLabel · HSK ${r.level} · ${r.ownerUsername}',
                  style: CompetitionStyles.muted,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.competitionLearnersCount(r.memberCount, r.maxUsers),
                  style: CompetitionStyles.muted,
                ),
              ],
            ),
          ),
          CompetitionStyles.wgap8,
          FilledButton(
            style: CompetitionStyles.primaryButton,
            onPressed: r.isFull ? null : () => c.joinRoom(r.roomCode),
            child: Text(
              r.isFull ? l10n.competitionRoomFull : l10n.competitionJoinRoom,
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'competitionTypeTyping':
        return l10n.competitionTypeTyping;
      case 'competitionTypeListening':
        return l10n.competitionTypeListening;
      case 'competitionTypeReading':
        return l10n.competitionTypeReading;
      case 'competitionTypeMeaning':
        return l10n.competitionTypeMeaning;
      case 'competitionTypeReorder':
        return l10n.competitionTypeReorder;
      default:
        return key;
    }
  }

  String _modeLabel(AppLocalizations l10n, CompetitionCategory cat) {
    switch (cat) {
      case CompetitionCategory.vocab:
        return l10n.competitionModeVocab;
      case CompetitionCategory.lesson:
        return l10n.competitionModeLesson;
      case CompetitionCategory.book:
        return l10n.competitionModeBook;
    }
  }
}
