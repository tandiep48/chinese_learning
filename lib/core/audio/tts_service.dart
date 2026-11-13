/// Core — a shared text-to-speech voice for Chinese syllables.
///
/// Used by the advanced pinyin chart, whose syllables have no recordings (the
/// web spoke them with the browser's `speechSynthesis`). Wraps `flutter_tts`;
/// `speak` is best-effort and never throws. **Native setup:** Android uses the
/// device TTS engine (install a Chinese voice if missing); iOS uses the built-in
/// `AVSpeechSynthesizer` (no extra config).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// App-wide shared [TtsService]; disposed with the provider container.
final ttsProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

class TtsService {
  TtsService();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> speak(String text, {String language = 'zh-CN'}) async {
    try {
      if (!_configured) {
        await _tts.setLanguage(language);
        await _tts.setSpeechRate(0.4);
        _configured = true;
      }
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Best-effort: a missing voice/engine must not crash the chart.
    }
  }

  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
