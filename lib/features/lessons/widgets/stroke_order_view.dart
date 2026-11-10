/// Lessons module — the stroke-order panel shown inside the word popup.
///
/// Native port of `StrokeOrder.tsx`: a per-character tab strip and an animated
/// stroke diagram with Animate / Practice (quiz) / Reset controls, built on
/// `stroke_order_animator`. The drawable paths come from the Hanzi Writer
/// dataset, downloaded on demand from the jsDelivr CDN (`downloadStrokeOrder`) —
/// exactly like the web, since the backend `/api/chinese_stroke_info` holds only
/// stroke counts, not paths.
library;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stroke_order_animator/stroke_order_animator.dart';

import '../../../l10n/app_localizations.dart';
import '../styles/lessons_styles.dart';

/// Han ideographs (BMP + extension A + compatibility), used to drop punctuation
/// and latin characters so only drawable characters get a tab.
final RegExp _hanRegExp = RegExp(r'[㐀-鿿豈-﫿]');

class StrokeOrderView extends StatefulWidget {
  const StrokeOrderView({super.key, required this.word});

  final String word;

  @override
  State<StrokeOrderView> createState() => _StrokeOrderViewState();
}

class _StrokeOrderViewState extends State<StrokeOrderView>
    with TickerProviderStateMixin {
  final http.Client _client = http.Client();
  late final List<String> _chars = _hanRegExp
      .allMatches(widget.word)
      .map((m) => m.group(0)!)
      .toList(growable: false);

  int _active = 0;
  StrokeOrderAnimationController? _controller;
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    if (_chars.isNotEmpty) _load(0);
  }

  Future<void> _load(int index) async {
    _controller?.dispose();
    setState(() {
      _active = index;
      _controller = null;
      _loading = true;
      _error = false;
    });
    try {
      final json = await downloadStrokeOrder(_chars[index], _client);
      if (!mounted) return;
      final controller = StrokeOrderAnimationController(
        StrokeOrder(json),
        this,
        strokeColor: LessonsStyles.strokeColor,
      );
      setState(() {
        _controller = controller;
        _loading = false;
      });
      controller.startAnimation();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_chars.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: LessonsStyles.strokeAreaPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_chars.length > 1) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _chars.length; i++)
                  OutlinedButton(
                    style: LessonsStyles.strokeTabStyle(i == _active),
                    onPressed: i == _active ? null : () => _load(i),
                    child: Text(_chars[i]),
                  ),
              ],
            ),
            LessonsStyles.strokeControlsTopGap,
          ],
          Center(
            child: Container(
              width: LessonsStyles.strokeCanvasSize,
              height: LessonsStyles.strokeCanvasSize,
              decoration: LessonsStyles.strokeCanvasDecoration,
              clipBehavior: Clip.antiAlias,
              child: _buildCanvas(l10n),
            ),
          ),
          LessonsStyles.strokeControlsTopGap,
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                style: LessonsStyles.wordPopupButtonStyle,
                onPressed: _controller == null
                    ? null
                    : () => _controller!.startAnimation(),
                icon: const Icon(
                  Icons.play_arrow,
                  size: LessonsStyles.toolbarIconSize,
                ),
                label: Text(l10n.strokeAnimate),
              ),
              OutlinedButton.icon(
                style: LessonsStyles.wordPopupButtonStyle,
                onPressed: _controller == null
                    ? null
                    : () => _controller!.startQuiz(),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: LessonsStyles.toolbarIconSize,
                ),
                label: Text(l10n.strokePractice),
              ),
              OutlinedButton.icon(
                style: LessonsStyles.wordPopupButtonStyle,
                onPressed: _controller == null
                    ? null
                    : () => _controller!.reset(),
                icon: const Icon(
                  Icons.refresh,
                  size: LessonsStyles.toolbarIconSize,
                ),
                label: Text(l10n.strokeReset),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final controller = _controller;
    if (_error || controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            l10n.strokeLoadError,
            textAlign: TextAlign.center,
            style: LessonsStyles.wordPopupNotFoundStyle,
          ),
        ),
      );
    }
    return StrokeOrderAnimator(
      controller,
      size: const Size(
        LessonsStyles.strokeCanvasSize,
        LessonsStyles.strokeCanvasSize,
      ),
    );
  }
}
