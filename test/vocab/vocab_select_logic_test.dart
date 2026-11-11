/// Unit tests for the Vocabulary selection-page pure logic.
library;

import 'package:chinese_learning/features/vocab/data/vocab_select_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VocabMode', () {
    test('wire values match the backend', () {
      expect(VocabMode.free.wire, 'free');
      expect(VocabMode.standard.wire, 'standard');
      expect(VocabMode.book.wire, 'book');
      expect(VocabMode.unsure.wire, 'unsure');
      expect(VocabMode.unlearn.wire, 'unlearn');
      expect(VocabMode.recent.wire, 'recent');
    });
  });

  group('isHistoryMode', () {
    test('history modes carry no filters', () {
      expect(isHistoryMode(VocabMode.unsure), isTrue);
      expect(isHistoryMode(VocabMode.unlearn), isTrue);
      expect(isHistoryMode(VocabMode.recent), isTrue);
    });
    test('filtered modes are not history modes', () {
      expect(isHistoryMode(VocabMode.free), isFalse);
      expect(isHistoryMode(VocabMode.standard), isFalse);
      expect(isHistoryMode(VocabMode.book), isFalse);
    });
  });

  group('numericSort', () {
    test('Other sinks to the bottom', () {
      expect(numericSort('Other', '5'), greaterThan(0));
      expect(numericSort('5', 'Other'), lessThan(0));
    });
    test('numbers sort numerically', () {
      final xs = ['10', '2', '1']..sort(numericSort);
      expect(xs, ['1', '2', '10']);
    });
  });

  group('grouping + options', () {
    final grouped = groupPassagesByLesson(['H1_2_1', 'H1_2_2', 'H1_3_1']);

    test('groups by lesson segment', () {
      expect(grouped.keys.toSet(), {'2', '3'});
      expect(grouped['2']!.map((p) => p.part), ['1', '2']);
    });

    test('buildLessonOptions runs the label callback and sorts', () {
      final opts = buildLessonOptions(grouped, (l) => 'Lesson $l');
      expect(opts.map((o) => o.value), ['2', '3']);
      expect(opts.first.label, 'Lesson 2');
    });

    test('buildPartOptions groups parts by lesson when >1 lesson chosen', () {
      final opts = buildPartOptions(
        ['2', '3'],
        grouped,
        (l) => 'Lesson $l',
        (p) => 'Part $p',
      );
      expect(opts.map((o) => o.value), ['H1_2_1', 'H1_2_2', 'H1_3_1']);
      expect(opts.first.group, 'Lesson 2'); // grouped because >1 lesson
    });

    test('a single lesson yields no group header', () {
      final opts = buildPartOptions(['2'], grouped, (l) => 'Lesson $l', (p) => 'Part $p');
      expect(opts.every((o) => o.group == null), isTrue);
    });
  });
}
