/// Lessons module — static data for the HSK 1 Lesson 1 basic pinyin guide.
///
/// Ported 1:1 from `yi-chinese-manage/lib/lessons/pinyin.ts` (the basic grid +
/// pronunciation hints). `null` marks an intentionally empty cell. The basic
/// chart's cells have recordings in the `audio_pinyin` bucket, so they play via
/// the core audio player (`pinyinAudioUrl`). The advanced initial×final matrix
/// (TTS-only) is deferred.
library;

/// Initials — left half, rows 0–5.
const List<List<String?>> basicInitialRows = [
  ['b', 'p', 'm', 'f'],
  ['d', 't', 'n', 'l'],
  ['g', 'k', 'h', null],
  ['j', 'q', 'x', null],
  ['zh', 'ch', 'sh', 'r'],
  ['z', 'c', 's', null],
];

/// Toned single vowels under the "Tones" header — left half, rows 7–12.
const List<List<String?>> basicToneRows = [
  ['ā', 'á', 'ǎ', 'à'],
  ['ō', 'ó', 'ǒ', 'ò'],
  ['ē', 'é', 'ě', 'è'],
  ['ī', 'í', 'ǐ', 'ì'],
  ['ū', 'ú', 'ǔ', 'ù'],
  ['ǖ', 'ǘ', 'ǚ', 'ǜ'],
];

/// Finals — right half for every one of the 13 rows.
const List<List<String?>> basicFinalRows = [
  ['i', 'u', 'ü', 'er'],
  ['a', 'ia', 'ua', null],
  ['o', 'uo', null, null],
  ['e', 'ie', 'üe', null],
  ['ai', 'uai', null, null],
  ['ei', 'uei(ui)', null, null],
  ['ao', 'iao', null, null],
  ['ou', 'iou(iu)', null, null],
  ['an', 'ian', 'uan', 'üan'],
  ['en', 'in', 'uen(un)', 'ün'],
  ['ang', 'iang', 'uang', null],
  ['eng', 'ing', 'ueng', null],
  ['ong', 'iong', null, null],
];

/// English pronunciation hints for the initials (`PRONUNCIATION_MAP`).
const Map<String, String> pinyinPronunciation = {
  'b': "Like 'p' in 'spit'",
  'p': "Like 'p' in 'pit'",
  'm': "Like 'm' in 'man'",
  'f': "Like 'f' in 'fan'",
  'd': "Like 't' in 'stop'",
  't': "Like 't' in 'top'",
  'n': "Like 'n' in 'not'",
  'l': "Like 'l' in 'lot'",
  'g': "Like 'k' in 'skill'",
  'k': "Like 'k' in 'kill'",
  'h': "Like 'h' in 'hat'",
  'j': "Like 'j' in 'jeep'",
  'q': "Like 'ch' in 'cheat'",
  'x': "Like 'sh' in 'sheet'",
  'zh': "Like 'j' in 'jump'",
  'ch': "Like 'ch' in 'church'",
  'sh': "Like 'sh' in 'shoe'",
  'r': "Like 'r' in 'run' but with tongue curled back",
  'z': "Like 'ds' in 'pads'",
  'c': "Like 'ts' in 'cats'",
  's': "Like 's' in 'sun'",
};

/// The audio-bucket key for a basic-chart cell (strips the `(ui)`-style
/// parenthetical alternates so `uei(ui)` requests `uei`).
String pinyinAudioSyllable(String cell) {
  final paren = cell.indexOf('(');
  return (paren >= 0 ? cell.substring(0, paren) : cell).trim();
}

// ── Advanced guide: tone helpers + the initial×final matrix ──────────────────
const Map<String, List<String>> _toneMarks = {
  'a': ['ā', 'á', 'ǎ', 'à'],
  'o': ['ō', 'ó', 'ǒ', 'ò'],
  'e': ['ē', 'é', 'ě', 'è'],
  'i': ['ī', 'í', 'ǐ', 'ì'],
  'u': ['ū', 'ú', 'ǔ', 'ù'],
  'ü': ['ǖ', 'ǘ', 'ǚ', 'ǜ'],
};

/// Place the tone mark on the correct vowel (a > o > e; the second vowel of
/// iu/ui; then i/u/ü) — identical to `addTone` in `pinyin.ts`.
String addTone(String syllable, int toneIndex) {
  String target = '';
  if (syllable.contains('a')) {
    target = 'a';
  } else if (syllable.contains('o')) {
    target = 'o';
  } else if (syllable.contains('e')) {
    target = 'e';
  } else if (syllable.contains('iu')) {
    target = 'u';
  } else if (syllable.contains('ui')) {
    target = 'i';
  } else if (syllable.contains('i')) {
    target = 'i';
  } else if (syllable.contains('u')) {
    target = 'u';
  } else if (syllable.contains('ü')) {
    target = 'ü';
  }
  if (target.isEmpty) return syllable;
  return syllable.replaceFirst(target, _toneMarks[target]![toneIndex]);
}

/// The four toned forms (1st → 4th tone) of a base syllable.
List<String> getTones(String syllable) =>
    [0, 1, 2, 3].map((i) => addTone(syllable, i)).toList();

/// One row of an advanced table: a final plus 22 cells (bare final, then one
/// per initial in `initials` order). `null` marks a gap.
class AdvancedPinyinRow {
  const AdvancedPinyinRow({required this.finalLabel, required this.cells});

  final String finalLabel;
  final List<String?> cells;
}

/// The advanced initial×final matrix (3 tables), from
/// `assets/pinyin/advanced_pinyin_data.json`.
class AdvancedPinyinData {
  const AdvancedPinyinData({required this.initials, required this.tables});

  final List<String> initials;
  final List<List<AdvancedPinyinRow>> tables;

  factory AdvancedPinyinData.fromJson(Map<String, dynamic> json) {
    final initials = [
      for (final e in (json['initials'] as List? ?? const [])) e.toString(),
    ];
    final tables = <List<AdvancedPinyinRow>>[];
    for (final table in (json['tables'] as List? ?? const [])) {
      final rows = <AdvancedPinyinRow>[];
      for (final row in (table as List)) {
        final map = row as Map<String, dynamic>;
        rows.add(
          AdvancedPinyinRow(
            finalLabel: (map['final'] ?? '').toString(),
            cells: [
              for (final c in (map['cells'] as List? ?? const []))
                c?.toString(),
            ],
          ),
        );
      }
      tables.add(rows);
    }
    return AdvancedPinyinData(initials: initials, tables: tables);
  }
}
