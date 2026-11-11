/// Unit tests for the vocab-trainer activity builder, including the listening
/// skill's homophone-safe grouping.
library;

import 'package:chinese_learning/features/vocab_trainer/data/trainer_word.dart';
import 'package:chinese_learning/features/vocab_trainer/data/vocab_activity.dart';
import 'package:flutter_test/flutter_test.dart';

TrainerWord _w(String word, {String pinyin = ''}) =>
    TrainerWord(word: word, pinyin: pinyin, meaningEn: 'm-$word');

List<TrainerWord> _words(int n) =>
    [for (var i = 0; i < n; i++) _w('w$i', pinyin: 'p$i')];

void main() {
  group('groupSizes', () {
    test('exact multiples group by five', () {
      expect(groupSizes(5), [5]);
      expect(groupSizes(10), [5, 5]);
    });
    test('avoids a lone trailing word by borrowing one', () {
      expect(groupSizes(6), [4, 2]);
      expect(groupSizes(11), [5, 4, 2]);
    });
    test('a single short group is left as-is', () {
      expect(groupSizes(3), [3]);
    });
  });

  group('pinyinKey', () {
    test('lowercases and strips spaces; tones kept', () {
      expect(pinyinKey(_w('他', pinyin: 'Tā')), 'tā');
      expect(pinyinKey(_w('x', pinyin: 'n i')), 'ni');
    });
    test('blank pinyin falls back to the word so distinct words never clash', () {
      expect(pinyinKey(_w('爱')), '__爱');
      expect(pinyinKey(_w('爱')) == pinyinKey(_w('恨')), isFalse);
    });
  });

  group('buildGroupsAvoidingKey', () {
    test('keeps every word exactly once', () {
      final rows = _words(13);
      final groups = buildGroupsAvoidingKey(rows, pinyinKey);
      final flat = groups.expand((g) => g).map((w) => w.word).toList();
      expect(flat.length, 13);
      expect(flat.toSet(), rows.map((w) => w.word).toSet());
    });

    test('never puts two homophones in the same group', () {
      // 他/她 share pinyin "tā"; they must be separated.
      final rows = [
        _w('他', pinyin: 'tā'),
        _w('她', pinyin: 'tā'),
        _w('地', pinyin: 'dì'),
        _w('的', pinyin: 'de'),
        _w('得', pinyin: 'dé'),
      ];
      for (var trial = 0; trial < 30; trial++) {
        final groups = buildGroupsAvoidingKey(rows, pinyinKey);
        for (final g in groups) {
          final keys = g.map(pinyinKey).toList();
          expect(keys.toSet().length, keys.length,
              reason: 'a group repeated a pinyin key: $keys');
        }
      }
    });

    test('empty input yields no groups', () {
      expect(buildGroupsAvoidingKey(const [], pinyinKey), isEmpty);
    });
  });

  group('buildActivities', () {
    test('defaults to all three skills in web order', () {
      final acts = buildActivities(_words(8));
      expect(acts.map((a) => a.type).toSet(), {'typing', 'listen', 'reading'});
      // Round 0 interleaves the types in declared order.
      expect(acts.take(3).map((a) => a.type), ['typing', 'listen', 'reading']);
    });

    test('every word appears once per selected skill', () {
      final rows = _words(12);
      final acts = buildActivities(rows);
      for (final type in ['typing', 'listen', 'reading']) {
        final words = acts
            .where((a) => a.type == type)
            .expand((a) => a.words)
            .map((w) => w.word)
            .toList();
        expect(words.toSet(), rows.map((w) => w.word).toSet(),
            reason: '$type should cover every word once');
        expect(words.length, rows.length);
      }
    });

    test('types filter restricts the skills built', () {
      final acts = buildActivities(_words(6), types: ['typing']);
      expect(acts.map((a) => a.type).toSet(), {'typing'});
    });

    test('an empty types list falls back to all skills', () {
      final acts = buildActivities(_words(6), types: const []);
      expect(acts.map((a) => a.type).toSet(), {'typing', 'listen', 'reading'});
    });

    test('empty rows yield no activities', () {
      expect(buildActivities(const []), isEmpty);
    });

    test('the listen db type is recorded as "listen"', () {
      expect(vocabActivityDb['listen'], 'listen');
      expect(vocabActivityDb['reading'], 'meaning');
      expect(vocabActivityDb['typing'], 'typing');
    });
  });
}
