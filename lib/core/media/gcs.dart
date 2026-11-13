/// Core — public GCS media URLs for learner audio.
///
/// Mirrors `yi-chinese-manage/lib/audio.ts` (+ the bucket in `lib/gcs.ts`),
/// which resolve `audio_key` fields straight to the public GCS bucket — the
/// Flask `/audio` and `/lesson_audio` routes are just redirects to these same
/// objects, so the app plays them directly. Override the bucket at build time
/// with `--dart-define=GCS_BUCKET_URL=...`.
library;

/// Public GCS bucket base, without a trailing slash. Default mirrors
/// `GCS_BUCKET_URL` in `lib/gcs.ts`.
const String gcsBucketUrl = String.fromEnvironment(
  'GCS_BUCKET_URL',
  defaultValue: 'https://storage.googleapis.com/chinese-learning-audio-assets',
);

/// Book cover, `.../lesson_cover/<CODE>.png` (`bookCoverUrl` in `lib/gcs.ts`).
String bookCoverUrl(String bookCode) =>
    '$gcsBucketUrl/lesson_cover/${Uri.encodeComponent(bookCode.toUpperCase())}.png';

/// HSK achievement badge, e.g. level 3 -> `.../badge/HSK3.png` (`badgeUrl` in
/// `lib/gcs.ts`); null for a level outside 1..6.
String? badgeUrl(int? level) => (level != null && level >= 1 && level <= 6)
    ? '$gcsBucketUrl/badge/HSK$level.png'
    : null;

/// Vocabulary word audio, e.g. "xiuxi_1" → `.../vocab_audio/xiuxi_1.mp3`
/// (`vocabAudioUrl` in `lib/audio.ts`).
String vocabAudioUrl(String audioKey) =>
    '$gcsBucketUrl/vocab_audio/${Uri.encodeComponent(audioKey)}.mp3';

/// Passage-line audio, e.g. HSK2 key "l2_1" → `.../lesson_audio/HSK2/l2_1.mp3`.
/// [folder] is the HSK level (e.g. "HSK2") or, for book lessons, the book code
/// (`lessonAudioUrl` in `lib/audio.ts`).
String lessonAudioUrl(String folder, String audioKey) =>
    '$gcsBucketUrl/lesson_audio/${Uri.encodeComponent(folder)}'
    '/${Uri.encodeComponent(audioKey)}.mp3';

/// Pinyin syllable audio (basic/advanced pinyin guides),
/// `.../audio_pinyin/<syllable>.mp3` (`pinyinAudioUrl` in `lib/audio.ts`).
String pinyinAudioUrl(String syllable) =>
    '$gcsBucketUrl/audio_pinyin/${Uri.encodeComponent(syllable)}.mp3';

/// Practice/exam question audio, e.g. `.../question_bank/practice/practice-2/<key>.mp3`
/// (`practiceAudioUrl` in `lib/gcs.ts`). [categoryWire] is "practice" | "exam".
String practiceAudioUrl(String key, int level, String categoryWire) {
  final lvl = level == 0 ? 1 : level;
  return '$gcsBucketUrl/question_bank/$categoryWire/$categoryWire-$lvl'
      '/${Uri.encodeComponent(key)}.mp3';
}

/// Practice/exam question image, e.g. `.../images/practice/2/<file>.jpg`
/// (`practiceImageUrl` in `lib/gcs.ts`). Appends `.jpg` when [filename] has no
/// image extension. [categoryWire] is "practice" | "exam".
String practiceImageUrl(int level, String filename, String categoryWire) {
  var file = filename.trim();
  if (!RegExp(
    r'\.(jpg|jpeg|png|gif|webp)$',
    caseSensitive: false,
  ).hasMatch(file)) {
    file += '.jpg';
  }
  return '$gcsBucketUrl/images/$categoryWire/$level/${Uri.encodeComponent(file)}';
}

/// The lesson-audio folder for a passage: the book code (book lessons) or the
/// normalised HSK level (e.g. "H2"/"2" → "HSK2") — mirrors `lessonAudioFolder`
/// in `lib/audio.ts`.
String lessonAudioFolder({String? hskLevel, String? bookCode}) {
  if (bookCode != null && bookCode.isNotEmpty) return bookCode;
  final raw = (hskLevel == null || hskLevel.isEmpty) ? 'HSK1' : hskLevel;
  if (raw.toLowerCase().startsWith('hsk')) return raw.toUpperCase();
  return 'HSK${raw.replaceFirst(RegExp(r'^[hH]'), '')}';
}
