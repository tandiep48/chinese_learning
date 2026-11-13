/// Unit tests for the practice/exam engine's pure helpers.
library;

import 'package:chinese_learning/features/practice/data/practice_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('answer normalisation', () {
    test('trims and upper-cases; null → empty', () {
      expect(normalizeAnswer('  ab '), 'AB');
      expect(normalizeAnswer(null), '');
    });
    test('answersMatch is case/trim-insensitive', () {
      expect(answersMatch('a', 'A'), isTrue);
      expect(answersMatch(' b ', 'B'), isTrue);
      expect(answersMatch('a', 'b'), isFalse);
    });
  });

  group('image detection', () {
    test('recognises filenames and numeric asset ids', () {
      expect(isImageFilename('a.jpg'), isTrue);
      expect(isImageFilename('photo.PNG'), isTrue);
      expect(isImageFilename('3.12b'), isTrue);
      expect(isImageFilename('hello'), isFalse);
      expect(isImageFilename(42), isFalse);
    });
    test('allOptionsAreImages needs every value to be an image', () {
      expect(allOptionsAreImages({'A': 'a.jpg', 'B': 'b.png'}), isTrue);
      expect(allOptionsAreImages({'A': 'a.jpg', 'B': 'text'}), isFalse);
      expect(allOptionsAreImages(const {}), isFalse);
      expect(allOptionsAreImages(null), isFalse);
    });
  });

  group('blanks', () {
    test('hasBlank detects a parenthesised gap', () {
      expect(hasBlank('你好（）世界'), isTrue);
      expect(hasBlank('没有空'), isFalse);
      expect(hasBlank(null), isFalse);
    });
    test('tokenizeContent splits text and blank segments in order', () {
      final segs = tokenizeContent('你好（）世界');
      expect(segs.map((s) => s.isBlank), [false, true, false]);
      expect(segs.first.text, '你好');
      expect(segs.last.text, '世界');
      expect(segs[1].index, 0);
    });
    test('countBlanks counts gaps', () {
      expect(countBlanks('（）和（）'), 2);
      expect(countBlanks('no blanks'), 0);
    });
  });

  group('navigation + result helpers', () {
    test('firstUncheckedAfter finds the next unchecked index', () {
      expect(firstUncheckedAfter([true, false, true], 0), 1);
      expect(firstUncheckedAfter([true, true, true], 0), -1);
    });
    test('allChecked', () {
      expect(allChecked([true, true]), isTrue);
      expect(allChecked([true, false]), isFalse);
      expect(allChecked(const []), isFalse);
    });
    test('resultTier thresholds', () {
      expect(resultTier(0.95), ResultTier.trophy);
      expect(resultTier(0.9), ResultTier.trophy);
      expect(resultTier(0.7), ResultTier.check);
      expect(resultTier(0.69), ResultTier.chart);
      expect(resultTier(0.5), ResultTier.chart);
      expect(resultTier(0.3), ResultTier.retry);
    });
  });
}
