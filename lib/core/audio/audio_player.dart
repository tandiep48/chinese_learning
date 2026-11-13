/// Core — a single shared audio player for learner media.
///
/// Thin wrapper over `just_audio` that plays the GCS mp3 URLs built in
/// `core/media/gcs.dart` (vocab words, passage lines, pinyin). One player is
/// shared app-wide via [audioPlayerProvider] so starting new audio stops
/// whatever was playing. Failures are swallowed, mirroring the web's
/// `audio.play().catch(() => {})` (e.g. `LessonCardStudy.tsx`).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// App-wide shared [AppAudioPlayer]; disposed with the provider container.
final audioPlayerProvider = Provider<AppAudioPlayer>((ref) {
  final player = AppAudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Plays one clip or a sequence of clips, cancelling any in-flight playback
/// when a new request (or [stop]) arrives.
class AppAudioPlayer {
  AppAudioPlayer();

  final AudioPlayer _player = AudioPlayer();

  /// Bumped on every new request so a running sequence knows it was superseded.
  int _token = 0;

  /// Stop whatever is playing and play [url].
  Future<void> playUrl(String url) async {
    final token = ++_token;
    try {
      await _player.stop();
      await _player.setUrl(url);
      if (token != _token) return;
      await _player.play();
    } catch (_) {
      // Silent — a missing/unreachable clip must not crash the reader.
    }
  }

  /// Play [urls] back-to-back (the reader's Auto Play). A later [playUrl],
  /// [playAll] or [stop] cancels the remaining clips.
  Future<void> playAll(List<String> urls) async {
    final token = ++_token;
    for (final url in urls) {
      if (token != _token) return;
      try {
        await _player.stop();
        await _player.setUrl(url);
        if (token != _token) return;
        await _player.play(); // resolves when this clip finishes.
      } catch (_) {
        // Skip a bad clip and continue the sequence.
      }
    }
  }

  /// Stop playback and cancel any running sequence.
  Future<void> stop() async {
    _token++;
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    _token++;
    await _player.dispose();
  }
}
