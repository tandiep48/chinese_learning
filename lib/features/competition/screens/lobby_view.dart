/// Competition — the lobby screen (web `LobbyScreen`).
///
/// The room-code bar, the settings summary + member list with the host's
/// Edit / Start controls, and the chat panel.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/competition_models.dart';
import '../data/room_logic.dart';
import '../providers/competition_controller.dart';
import '../styles/competition_styles.dart';

class CompetitionLobbyView extends StatefulWidget {
  const CompetitionLobbyView({super.key, required this.controller});

  final CompetitionController controller;

  @override
  State<CompetitionLobbyView> createState() => _CompetitionLobbyViewState();
}

class _CompetitionLobbyViewState extends State<CompetitionLobbyView> {
  final _chatController = TextEditingController();
  final _chatScroll = ScrollController();

  CompetitionController get c => widget.controller;

  @override
  void didUpdateWidget(covariant CompetitionLobbyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.jumpTo(_chatScroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    c.sendChat(text);
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final room = c.room;
    if (room == null) return const SizedBox.shrink();
    final summary = roomSummary(room);
    final canManage = canManageRoom(room, c.userId);

    return SingleChildScrollView(
      padding: CompetitionStyles.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _roomBar(l10n, room),
          CompetitionStyles.gap16,
          _setupPanel(l10n, room, summary, canManage),
          CompetitionStyles.gap16,
          _chatPanel(l10n),
        ],
      ),
    );
  }

  Widget _roomBar(AppLocalizations l10n, CompetitionRoom room) {
    return Container(
      padding: CompetitionStyles.roomBarPadding,
      decoration: CompetitionStyles.roomBar,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.competitionRoomLabel, style: CompetitionStyles.muted),
                Text(room.roomCode, style: CompetitionStyles.roomCode),
              ],
            ),
          ),
          OutlinedButton(
            style: CompetitionStyles.secondaryButton,
            onPressed: c.leaveRoom,
            child: Text(l10n.competitionLeave),
          ),
        ],
      ),
    );
  }

  Widget _setupPanel(
    AppLocalizations l10n,
    CompetitionRoom room,
    RoomSummary s,
    bool canManage,
  ) {
    final typeLabel = s.allTypes
        ? l10n.competitionTypeAll
        : s.typeKeys.map((k) => _typeLabel(l10n, k)).join(', ');

    return Container(
      padding: CompetitionStyles.panelPadding,
      decoration: CompetitionStyles.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.competitionRoomSetup, style: CompetitionStyles.h2),
          CompetitionStyles.gap12,
          Text(
            s.sourceLabel.isNotEmpty
                ? s.sourceLabel
                : _modeKeyLabel(l10n, s.modeKey),
            style: CompetitionStyles.label,
          ),
          const SizedBox(height: 4),
          Text(
            '${_modeKeyLabel(l10n, s.modeKey)} · $typeLabel',
            style: CompetitionStyles.muted,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.competitionLessonsPartsCount(s.lessonCount, s.partCount),
            style: CompetitionStyles.muted,
          ),
          const SizedBox(height: 4),
          Text(
            _countLabel(l10n, s.countKey, s.count),
            style: CompetitionStyles.muted,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.competitionUsersCount(s.memberCount, s.maxUsers),
            style: CompetitionStyles.muted,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.competitionTimeLimitValue(s.minutes),
            style: CompetitionStyles.muted,
          ),
          CompetitionStyles.gap12,
          for (final m in room.members)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      m.username,
                      style: CompetitionStyles.memberName,
                    ),
                  ),
                  Text(m.role, style: CompetitionStyles.memberRole),
                ],
              ),
            ),
          if (c.error.isNotEmpty) ...[
            CompetitionStyles.gap8,
            Container(
              width: double.infinity,
              decoration: CompetitionStyles.errorBox,
              padding: CompetitionStyles.errorPadding,
              child: Text(c.error, style: CompetitionStyles.errorText),
            ),
          ],
          if (canManage) ...[
            CompetitionStyles.gap12,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: CompetitionStyles.secondaryButton,
                    onPressed: c.editRoomSettings,
                    child: Text(l10n.competitionEditSettings),
                  ),
                ),
                CompetitionStyles.wgap12,
                Expanded(
                  child: FilledButton(
                    style: CompetitionStyles.primaryButton,
                    onPressed: c.startSession,
                    child: Text(l10n.competitionStartSession),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chatPanel(AppLocalizations l10n) {
    return Container(
      padding: CompetitionStyles.panelPadding,
      decoration: CompetitionStyles.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.competitionChat, style: CompetitionStyles.h2),
          CompetitionStyles.gap12,
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: c.chat.isEmpty
                ? const SizedBox(height: 40)
                : ListView.builder(
                    controller: _chatScroll,
                    shrinkWrap: true,
                    itemCount: c.chat.length,
                    itemBuilder: (context, i) {
                      final m = c.chat[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.username.isNotEmpty
                                  ? m.username
                                  : l10n.competitionUserFallback,
                              style: CompetitionStyles.chatAuthor,
                            ),
                            Text(m.message, style: CompetitionStyles.chatText),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          CompetitionStyles.gap8,
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  maxLength: 1000,
                  style: CompetitionStyles.body,
                  decoration: CompetitionStyles.inputDecoration(
                    l10n.competitionMessagePlaceholder,
                  ).copyWith(counterText: ''),
                  onSubmitted: (_) => _send(),
                ),
              ),
              CompetitionStyles.wgap8,
              FilledButton(
                style: CompetitionStyles.primaryButton,
                onPressed: _send,
                child: Text(l10n.competitionSend),
              ),
            ],
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

  String _modeKeyLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'competitionModeLesson':
        return l10n.competitionModeLesson;
      case 'competitionModeBook':
        return l10n.competitionModeBook;
      default:
        return l10n.competitionModeVocab;
    }
  }

  String _countLabel(AppLocalizations l10n, String key, int count) {
    switch (key) {
      case 'competitionTasksSourceCount':
        return l10n.competitionTasksSourceCount(count);
      case 'competitionBookPoolNote':
        return l10n.competitionBookPoolNote;
      default:
        return l10n.competitionWordsCount(count);
    }
  }
}
