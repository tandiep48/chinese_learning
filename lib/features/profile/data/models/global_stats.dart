/// Profile module — the learner's headline learning statistics.
///
/// Ported from `GlobalStats` / `GlobalStatsBucket` in
/// `yi-chinese-manage/lib/types/dashboard.ts`. Raw JSON from
/// `GET /api/user/global-stats`. Every `fromJson` validates (plan rule 6).
library;

import '../../../../core/api/validators.dart';

/// Per-activity totals (questions answered + time spent).
class GlobalStatsBucket {
  const GlobalStatsBucket({
    required this.questions,
    required this.timeMs,
    required this.timeLabel,
  });

  final int questions;
  final int timeMs;
  final String timeLabel;

  static const GlobalStatsBucket empty = GlobalStatsBucket(
    questions: 0,
    timeMs: 0,
    timeLabel: '0s',
  );

  factory GlobalStatsBucket.fromJson(Map<String, dynamic> json) {
    return GlobalStatsBucket(
      questions: optInt(json, 'questions') ?? 0,
      timeMs: optInt(json, 'time_ms') ?? 0,
      timeLabel: optString(json, 'time_label') ?? '0s',
    );
  }
}

class GlobalStats {
  const GlobalStats({
    required this.totalTimeMs,
    required this.totalTimeLabel,
    required this.totalWords,
    required this.exercise,
    required this.exam,
    required this.lessonTrainer,
    required this.vocabTrainer,
  });

  final int totalTimeMs;
  final String totalTimeLabel;
  final int totalWords;
  final GlobalStatsBucket exercise;
  final GlobalStatsBucket exam;
  final GlobalStatsBucket lessonTrainer;
  final GlobalStatsBucket vocabTrainer;

  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    final buckets = json['buckets'] == null
        ? const <String, dynamic>{}
        : asMap(json['buckets'], what: 'buckets');
    GlobalStatsBucket bucket(String key) => buckets[key] == null
        ? GlobalStatsBucket.empty
        : GlobalStatsBucket.fromJson(asMap(buckets[key], what: key));
    return GlobalStats(
      totalTimeMs: optInt(json, 'total_time_ms') ?? 0,
      totalTimeLabel: optString(json, 'total_time_label') ?? '0s',
      totalWords: optInt(json, 'total_words') ?? 0,
      exercise: bucket('exercise'),
      exam: bucket('exam'),
      lessonTrainer: bucket('lesson_trainer'),
      vocabTrainer: bucket('vocab_trainer'),
    );
  }
}
