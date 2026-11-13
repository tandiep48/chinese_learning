/// Lessons module — learn-progress for the HSK pickers.
///
/// Ported from `PickerProgressSummary` / `toProgress` (`lib/types/lesson.ts`,
/// `lib/lessons/lessons.ts`). Raw JSON: `/api/lesson/picker-progress?hsk_level=`
/// → `{ lessons: {<lesson>: entry}, parts: {<passage_id>: entry} }`.
library;

import '../../../../core/api/validators.dart';

class PickerProgress {
  const PickerProgress({
    required this.learnedWords,
    required this.totalWords,
    required this.progressPct,
  });

  static const PickerProgress empty = PickerProgress(
    learnedWords: 0,
    totalWords: 0,
    progressPct: 0,
  );

  final int learnedWords;
  final int totalWords;
  final int progressPct;

  factory PickerProgress.fromJson(Map<String, dynamic> json) {
    return PickerProgress(
      learnedWords: optInt(json, 'learned_words') ?? 0,
      totalWords: optInt(json, 'total_words') ?? 0,
      progressPct: optInt(json, 'progress_pct') ?? 0,
    );
  }
}

class PickerProgressSummary {
  const PickerProgressSummary({required this.lessons, required this.parts});

  static const PickerProgressSummary empty = PickerProgressSummary(
    lessons: {},
    parts: {},
  );

  final Map<String, PickerProgress> lessons;
  final Map<String, PickerProgress> parts;

  factory PickerProgressSummary.fromJson(Map<String, dynamic> json) {
    Map<String, PickerProgress> read(String key) {
      final raw = json[key];
      if (raw is! Map) return const {};
      return {
        for (final e in raw.entries)
          if (e.value is Map)
            e.key.toString(): PickerProgress.fromJson(
              (e.value as Map).cast<String, dynamic>(),
            ),
      };
    }

    return PickerProgressSummary(
      lessons: read('lessons'),
      parts: read('parts'),
    );
  }
}
