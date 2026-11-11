/// Unit tests for the pinyin tone-placement helpers.
library;

import 'package:chinese_learning/features/lessons/data/pinyin_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('addTone places the mark on the correct vowel', () {
    test('a always wins', () {
      expect(addTone('ma', 0), 'mā');
      expect(addTone('hao', 2), 'hǎo');
    });
    test('o then e when there is no a', () {
      expect(addTone('guo', 1), 'guó');
      expect(addTone('xue', 3), 'xuè');
    });
    test('iu → the u, ui → the i', () {
      expect(addTone('jiu', 1), 'jiú');
      expect(addTone('gui', 0), 'guī');
    });
    test('lone i / u / ü', () {
      expect(addTone('ni', 2), 'nǐ');
      expect(addTone('bu', 3), 'bù');
      expect(addTone('lü', 3), 'lǜ');
    });
  });

  test('getTones returns all four tones', () {
    expect(getTones('ma'), ['mā', 'má', 'mǎ', 'mà']);
  });

  group('pinyinAudioSyllable', () {
    test('strips a parenthetical alternate', () {
      expect(pinyinAudioSyllable('uei(ui)'), 'uei');
      expect(pinyinAudioSyllable('iou(iu)'), 'iou');
    });
    test('leaves a plain syllable untouched', () {
      expect(pinyinAudioSyllable('ba'), 'ba');
    });
  });
}
