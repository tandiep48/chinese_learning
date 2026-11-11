/// Unit tests for the GCS media-URL builders (pure string functions).
library;

import 'package:chinese_learning/core/media/gcs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('audio URLs', () {
    test('vocab / lesson / pinyin paths', () {
      expect(vocabAudioUrl('nihao'), '$gcsBucketUrl/vocab_audio/nihao.mp3');
      expect(lessonAudioUrl('HSK1', 'line1'),
          '$gcsBucketUrl/lesson_audio/HSK1/line1.mp3');
      expect(pinyinAudioUrl('ni'), '$gcsBucketUrl/audio_pinyin/ni.mp3');
    });
    test('keys are URL-encoded', () {
      expect(vocabAudioUrl('a b'), contains('vocab_audio/a%20b.mp3'));
    });
  });

  group('practice media', () {
    test('audio path includes category + level, 0 → 1', () {
      expect(practiceAudioUrl('k', 2, 'exam'),
          '$gcsBucketUrl/question_bank/exam/exam-2/k.mp3');
      expect(practiceAudioUrl('k', 0, 'practice'),
          '$gcsBucketUrl/question_bank/practice/practice-1/k.mp3');
    });
    test('image path appends .jpg when no extension', () {
      expect(practiceImageUrl(1, 'pic', 'exam'),
          '$gcsBucketUrl/images/exam/1/pic.jpg');
      expect(practiceImageUrl(1, 'pic.png', 'exam'),
          '$gcsBucketUrl/images/exam/1/pic.png');
    });
  });

  group('lessonAudioFolder', () {
    test('book code wins', () {
      expect(lessonAudioFolder(bookCode: 'ABC', hskLevel: '2'), 'ABC');
    });
    test('normalises an HSK level to HSKn', () {
      expect(lessonAudioFolder(hskLevel: '2'), 'HSK2');
      expect(lessonAudioFolder(hskLevel: 'h4'), 'HSK4');
      expect(lessonAudioFolder(hskLevel: 'HSK3'), 'HSK3');
    });
    test('defaults to HSK1 when nothing is given', () {
      expect(lessonAudioFolder(), 'HSK1');
    });
  });
}
