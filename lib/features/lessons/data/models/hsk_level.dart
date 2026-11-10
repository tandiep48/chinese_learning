/// Lessons module — HSK level metadata for the Library's HSK browse path.
///
/// Ported from `yi-chinese-manage/lib/lessons/constants.ts`
/// (`LESSON_CONSTANTS.HSK_LEVELS`) and the GCS cover-image helper in
/// `yi-chinese-manage/lib/gcs.ts` (`hskImageUrl`). Static metadata, not an API
/// model — HSK 7–9 and the HSK1 pinyin/number special-cases are deferred
/// (see the port plan, Slice N2).
library;

import 'package:flutter/material.dart';

/// One HSK level card: its id (`HSK1`), numeric level, display label and the
/// card background tint from the web constant.
class HskLevel {
  const HskLevel({
    required this.key,
    required this.level,
    required this.label,
    required this.color,
  });

  final String key;
  final int level;
  final String label;
  final Color color;
}

/// The six HSK levels, mirroring `LESSON_CONSTANTS.HSK_LEVELS` (colors converted
/// from the CSS hex values).
const List<HskLevel> hskLevels = [
  HskLevel(key: 'HSK1', level: 1, label: 'HSK 1', color: Color(0xFFD9D9D8)),
  HskLevel(key: 'HSK2', level: 2, label: 'HSK 2', color: Color(0xFFD0F1D2)),
  HskLevel(key: 'HSK3', level: 3, label: 'HSK 3', color: Color(0xFF99D8E9)),
  HskLevel(key: 'HSK4', level: 4, label: 'HSK 4', color: Color(0xFFFCE084)),
  HskLevel(key: 'HSK5', level: 5, label: 'HSK 5', color: Color(0xFFFCB86F)),
  HskLevel(key: 'HSK6', level: 6, label: 'HSK 6', color: Color(0xFFEE5550)),
];

/// The level whose [HskLevel.key] matches [key] case-insensitively, or null.
/// Mirrors `getLevel` in `lib/lessons/lessons.ts`.
HskLevel? hskLevelByKey(String key) {
  final lower = key.toLowerCase();
  for (final l in hskLevels) {
    if (l.key.toLowerCase() == lower) return l;
  }
  return null;
}

/// GCS bucket base; override at build time with
/// `--dart-define=GCS_BUCKET_URL=...`. Default mirrors `lib/gcs.ts`.
const String _gcsBucketUrl = String.fromEnvironment(
  'GCS_BUCKET_URL',
  defaultValue: 'https://storage.googleapis.com/chinese-learning-audio-assets',
);

/// Cover image for an HSK level (`hskImageUrl` in `lib/gcs.ts`).
String hskImageUrl(int level) => '$_gcsBucketUrl/hsk_images/hsk$level.png';
