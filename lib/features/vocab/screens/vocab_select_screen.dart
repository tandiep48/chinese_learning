/// Vocab module — the learner vocabulary selection page (web `VocabSelectPage`).
///
/// Owns the [VocabSelectController] for the screen's lifetime. A mode picker,
/// search box and the HSK/Book → Lesson → Part filter cascade drive a paginated
/// word table; "Flash Cards" opens the current page's words in the flashcard
/// deck and "Start Training" opens the vocab trainer after the skill picker.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../lessons/data/lesson_repository.dart';
import '../../vocab_trainer/data/trainer_word.dart';
import '../../vocab_trainer/screens/vocab_trainer_page.dart';
import '../data/vocab_repository.dart';
import '../data/vocab_select_logic.dart';
import '../providers/vocab_select_controller.dart';
import '../styles/vocab_styles.dart';
import '../widgets/train_type_picker.dart';
import '../widgets/vocab_multi_select.dart';
import '../widgets/vocab_row_tile.dart';
import '../widgets/vocab_stroke_sheet.dart';
import 'vocab_flashcard_screen.dart';

class VocabSelectScreen extends ConsumerStatefulWidget {
  const VocabSelectScreen({super.key});

  @override
  ConsumerState<VocabSelectScreen> createState() => _VocabSelectScreenState();
}

class _VocabSelectScreenState extends ConsumerState<VocabSelectScreen> {
  VocabSelectController? _controller;
  final _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final l10n = AppLocalizations.of(context);
    final lessonRepo = ref.read(lessonRepositoryProvider);
    _controller = VocabSelectController(
      repo: ref.read(vocabRepositoryProvider),
      fetchHskPassageIds: (level) => lessonRepo
          .getPassages('HSK$level')
          .then((list) => [for (final p in list) p.passageId]),
      strings: VocabStrings(
        chooseFilters: l10n.vocabChooseFilters,
        chooseBook: l10n.vocabChooseBook,
        chooseLessonAndPart: l10n.vocabChooseLessonAndPart,
        chooseHskLessonPart: l10n.vocabChooseHskLessonPart,
        chooseHskOnly: l10n.vocabChooseHskOnly,
        chooseAPart: l10n.vocabChooseAPart,
        noVocabFound: l10n.vocabNoVocabFound,
        loadingVocabulary: l10n.vocabLoadingVocabulary,
        failedLoadVocabulary: l10n.vocabFailedLoadVocabulary,
        searching: l10n.vocabSearching,
        searchFailed: l10n.vocabSearchFailed,
        loadingLessons: l10n.vocabLoadingLessons,
        failedLoadLessons: l10n.vocabFailedLoadLessons,
        noLessonsFound: l10n.vocabNoLessonsFound,
        noSavedBooks: l10n.vocabNoSavedBooks,
        lessonPrefix: l10n.vocabLessonOptionPrefix,
        partPrefix: l10n.vocabPartOptionPrefix,
        other: l10n.vocabOtherLabel,
        noResultsFor: (q) => l10n.vocabNoResultsFor(q),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _modeLabel(AppLocalizations l10n, VocabMode m) => switch (m) {
    VocabMode.free => l10n.vocabModeFree,
    VocabMode.standard => l10n.vocabModeStandard,
    VocabMode.book => l10n.vocabModeBook,
    VocabMode.unsure => l10n.vocabModeUnsure,
    VocabMode.unlearn => l10n.vocabModeUnlearn,
    VocabMode.recent => l10n.vocabModeRecent,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = _controller!;
    return Scaffold(
      backgroundColor: BrandColors.background,
      appBar: AppBar(
        backgroundColor: BrandColors.background,
        title: Text(l10n.vocabTitle),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: c,
          builder: (context, _) => _body(l10n, c),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n, VocabSelectController c) {
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    final ready = c.status == VocabTableStatus.ready && c.rows.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: VocabStyles.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _modeChips(l10n, c),
              VocabStyles.gap12,
              TextField(
                controller: _searchController,
                style: VocabStyles.meaning,
                decoration: VocabStyles.input(
                  l10n.vocabSearchPlaceholder,
                  icon: const Icon(Icons.search, color: BrandColors.mutedText),
                ),
                onChanged: c.setSearchQuery,
              ),
              if (!c.searchMode && !c.isHistory) ...[
                VocabStyles.gap12,
                ..._filters(l10n, c),
              ],
              VocabStyles.gap12,
              _actions(l10n, c, ready, isVi),
            ],
          ),
        ),
        Expanded(child: _table(l10n, c, isVi)),
        if (ready && c.totalPages > 1) _pagination(l10n, c),
      ],
    );
  }

  Widget _modeChips(AppLocalizations l10n, VocabSelectController c) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in VocabMode.values)
          TextButton(
            style: VocabStyles.modeChip(c.mode == m),
            onPressed: () => c.setMode(m),
            child: Text(_modeLabel(l10n, m)),
          ),
      ],
    );
  }

  List<Widget> _filters(AppLocalizations l10n, VocabSelectController c) {
    String count(int n) => l10n.vocabNSelected(n);
    final widgets = <Widget>[];

    if (c.isBook) {
      widgets.add(_fieldLabel(l10n.vocabBookLabel));
      widgets.add(
        DropdownButtonFormField<String>(
          initialValue: c.selectedBook.isEmpty ? null : c.selectedBook,
          isExpanded: true,
          decoration: VocabStyles.input(l10n.vocabSelectBook),
          items: [
            for (final b in c.bookOptions)
              DropdownMenuItem(value: b.code, child: Text(b.name)),
          ],
          onChanged: (v) => c.setBook(v ?? ''),
        ),
      );
    } else if (c.mode == VocabMode.free || c.mode == VocabMode.standard) {
      widgets.add(_fieldLabel(l10n.vocabHskLabel));
      widgets.add(
        DropdownButtonFormField<String>(
          initialValue: c.hskLevel.isEmpty ? null : c.hskLevel,
          isExpanded: true,
          decoration: VocabStyles.input(l10n.vocabSelectHsk),
          items: [
            for (var n = 1; n <= 6; n++)
              DropdownMenuItem(value: '$n', child: Text('HSK $n')),
          ],
          onChanged: (v) => c.setHskLevel(v ?? ''),
        ),
      );
    }

    // Standard + Book drill into Lesson → Part.
    if (c.mode == VocabMode.standard || c.isBook) {
      widgets.add(VocabStyles.gap12);
      widgets.add(_fieldLabel(l10n.vocabLessonLabel));
      widgets.add(
        VocabMultiSelect(
          options: c.lessonOptions,
          values: c.selectedLessons,
          onChanged: c.changeLessons,
          placeholder: l10n.vocabSelectLesson,
          selectAllLabel: l10n.vocabSelectAll,
          countLabel: count,
          doneLabel: l10n.vocabDone,
        ),
      );
      widgets.add(VocabStyles.gap12);
      widgets.add(_fieldLabel(l10n.vocabPartLabel));
      widgets.add(
        VocabMultiSelect(
          options: c.partOptions,
          values: c.selectedParts,
          onChanged: c.changeParts,
          placeholder: l10n.vocabSelectPart,
          selectAllLabel: l10n.vocabSelectAll,
          countLabel: count,
          doneLabel: l10n.vocabDone,
        ),
      );
    }
    return widgets;
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: VocabStyles.label),
  );

  Widget _actions(
    AppLocalizations l10n,
    VocabSelectController c,
    bool ready,
    bool isVi,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: VocabStyles.secondaryButton,
            onPressed: ready ? () => _openFlashcards(c) : null,
            icon: const Icon(Icons.style_outlined, size: 18),
            label: Text(l10n.vocabFlashcards),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            style: VocabStyles.primaryButton,
            onPressed: ready ? () => _startTraining(l10n, c) : null,
            icon: const Icon(Icons.fitness_center, size: 18),
            label: Text(l10n.vocabStartTraining),
          ),
        ),
      ],
    );
  }

  Widget _table(AppLocalizations l10n, VocabSelectController c, bool isVi) {
    if (c.status != VocabTableStatus.ready) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            c.message,
            style: VocabStyles.subtitle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: VocabStyles.pagePadding,
      itemCount: c.rows.length,
      separatorBuilder: (_, _) => VocabStyles.gap8,
      itemBuilder: (context, i) {
        final row = c.rows[i];
        return VocabRowTile(
          row: row,
          isVi: isVi,
          onPlayAudio: (row.audioKey == null || row.audioKey!.isEmpty)
              ? null
              : () => ref
                    .read(audioPlayerProvider)
                    .playUrl(vocabAudioUrl(row.audioKey!)),
          onStroke: () => showVocabStrokeSheet(context, row.cn),
        );
      },
    );
  }

  Widget _pagination(AppLocalizations l10n, VocabSelectController c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: BrandColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: c.page <= 1 ? null : () => c.goToPage(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            l10n.vocabPageStatus(c.page, c.totalPages),
            style: VocabStyles.subtitle,
          ),
          IconButton(
            onPressed: c.page >= c.totalPages ? null : () => c.goToPage(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _openFlashcards(VocabSelectController c) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VocabFlashcardScreen(words: List.of(c.rows)),
      ),
    );
  }

  Future<void> _startTraining(
    AppLocalizations l10n,
    VocabSelectController c,
  ) async {
    final skills = await showTrainTypePicker(context, l10n);
    if (skills == null || !mounted) return;
    final words = [
      for (final r in c.rows)
        TrainerWord(
          word: r.cn.isNotEmpty ? r.cn : r.word,
          pinyin: r.pinyin,
          meaningVn: r.meaningVn,
          meaningEn: r.meaningEn,
          audioKey: r.audioKey ?? '',
          level: r.level,
        ),
    ];
    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: BrandColors.background,
          appBar: AppBar(
            backgroundColor: BrandColors.background,
            title: Text(l10n.vocabStartTraining),
          ),
          body: SafeArea(
            child: VocabTrainerPage(
              words: words,
              activityTypes: skills,
              onExit: () => navigator.canPop() ? navigator.pop() : null,
              onFinished: () => navigator.canPop() ? navigator.pop() : null,
            ),
          ),
        ),
      ),
    );
  }
}
