/// Unit tests for the lesson-trainer answer matching (punctuation/space-insensitive).
library;

import 'package:chinese_learning/features/lesson_trainer/data/answer_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeAnswer strips punctuation and spaces', () {
    expect(normalizeAnswer('你好。'), '你好');
    expect(normalizeAnswer('你 好！'), '你好');
    expect(normalizeAnswer(null), '');
  });

  test('answersMatch ignores punctuation and spacing', () {
    expect(answersMatch('你好', '你 好！'), isTrue);
    expect(answersMatch('你好', '再见'), isFalse);
  });

  group('reorderMatches', () {
    test('order-sensitive, punctuation-insensitive', () {
      expect(reorderMatches(['我', '爱', '你'], ['我', '爱', '你']), isTrue);
      expect(reorderMatches(['我', '你', '爱'], ['我', '爱', '你']), isFalse);
    });
    test('length mismatch fails', () {
      expect(reorderMatches(['我', '爱'], ['我', '爱', '你']), isFalse);
    });
  });
}
