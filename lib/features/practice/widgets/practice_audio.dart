/// Practice module — one shared audio player for a session, plus the inline
/// [AudioControl] (play/stop, ±5s seek, scrubber).
///
/// Ported from `PracticeAudio.tsx`: playing one control stops the others
/// (`activeAudioControl`), with a draggable scrubber ported from
/// `makeAudioBtn()/seekAudio()`. Built on `just_audio` (same engine as the P1
/// reader audio), scoped to the runner so it disposes with the screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/practice_question.dart';
import '../styles/practice_styles.dart';

/// App-wide shared practice audio player (one clip plays at a time). The
/// controller is a [ChangeNotifier]; widgets rebuild on it via [ListenableBuilder].
final practiceAudioProvider = Provider<PracticeAudioController>((ref) {
  final controller = PracticeAudioController();
  ref.onDispose(controller.dispose);
  return controller;
});

class PracticeAudioController extends ChangeNotifier {
  PracticeAudioController() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _activeSrc = '';
        _player.pause();
        _player.seek(Duration.zero);
      }
      notifyListeners();
    });
  }

  final AudioPlayer _player = AudioPlayer();
  String _activeSrc = '';

  String get activeSrc => _activeSrc;
  bool get playing => _player.playing;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<void> toggle(String src) async {
    try {
      if (_activeSrc == src && _player.playing) {
        await _player.pause();
        notifyListeners();
        return;
      }
      if (_activeSrc != src) {
        _activeSrc = src;
        notifyListeners();
        await _player.setUrl(src);
        await _player.seek(Duration.zero);
      }
      await _player.play();
    } catch (_) {
      // Ignore a missing/unreachable clip.
    }
    notifyListeners();
  }

  Future<void> seekBy(String src, int deltaSeconds) async {
    try {
      if (_activeSrc != src) {
        _activeSrc = src;
        notifyListeners();
        await _player.setUrl(src);
      }
      var target = _player.position + Duration(seconds: deltaSeconds);
      if (target < Duration.zero) target = Duration.zero;
      final dur = _player.duration;
      if (dur != null && target > dur) target = dur;
      await _player.seek(target);
    } catch (_) {}
  }

  Future<void> seekTo(String src, int seconds) async {
    try {
      if (_activeSrc != src) {
        _activeSrc = src;
        notifyListeners();
        await _player.setUrl(src);
      }
      var target = Duration(seconds: seconds);
      final dur = _player.duration;
      if (dur != null && target > dur) target = dur;
      await _player.seek(target);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _activeSrc = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

String _formatTime(Duration d) {
  final total = d.inSeconds < 0 ? 0 : d.inSeconds;
  final m = total ~/ 60;
  final s = total % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// One audio clip's inline control. All controls in a session share the player,
/// so starting one stops the others.
class AudioControl extends ConsumerWidget {
  const AudioControl({
    super.key,
    required this.audioKey,
    required this.level,
    required this.category,
    this.label,
  });

  final String audioKey;
  final int level;
  final PracticeCategory category;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(practiceAudioProvider);
    final l10n = AppLocalizations.of(context);
    final src = practiceAudioUrl(audioKey, level, category.wire);

    return ListenableBuilder(
      listenable: audio,
      builder: (context, _) {
        final isActive = audio.activeSrc == src;
        final playing = isActive && audio.playing;
        return Container(
          decoration: PracticeStyles.audioControlDecoration,
          padding: PracticeStyles.audioControlPadding,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.replay_5),
                tooltip: l10n.practiceBack5,
                color: BrandColors.navTeal,
                onPressed: () => audio.seekBy(src, -5),
              ),
              IconButton(
                icon: Icon(playing ? Icons.stop : Icons.play_arrow),
                tooltip: playing
                    ? l10n.practiceStopAudio
                    : (label ?? l10n.practiceAudioFallback),
                color: BrandColors.navTeal,
                onPressed: () => audio.toggle(src),
              ),
              IconButton(
                icon: const Icon(Icons.forward_5),
                tooltip: l10n.practiceForward5,
                color: BrandColors.navTeal,
                onPressed: () => audio.seekBy(src, 5),
              ),
              Expanded(
                child: _Scrubber(active: isActive, audio: audio, src: src),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Scrubber extends StatelessWidget {
  const _Scrubber({
    required this.active,
    required this.audio,
    required this.src,
  });

  final bool active;
  final PracticeAudioController audio;
  final String src;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<Duration>(
      stream: active ? audio.positionStream : Stream<Duration>.empty(),
      builder: (context, posSnap) {
        final pos = active ? (posSnap.data ?? Duration.zero) : Duration.zero;
        return StreamBuilder<Duration?>(
          stream: active ? audio.durationStream : Stream<Duration?>.empty(),
          builder: (context, durSnap) {
            final dur = active
                ? (durSnap.data ?? Duration.zero)
                : Duration.zero;
            final maxSec = dur.inSeconds <= 0 ? 1.0 : dur.inSeconds.toDouble();
            final cur = pos.inSeconds.clamp(0, maxSec.toInt()).toDouble();
            return Row(
              children: [
                Text(_formatTime(pos), style: PracticeStyles.audioTimeStyle),
                Expanded(
                  child: Slider(
                    value: cur,
                    min: 0,
                    max: maxSec,
                    label: l10n.practiceSeekSlider,
                    onChanged: active
                        ? (v) => audio.seekTo(src, v.round())
                        : null,
                  ),
                ),
                Text(_formatTime(dur), style: PracticeStyles.audioTimeStyle),
              ],
            );
          },
        );
      },
    );
  }
}
