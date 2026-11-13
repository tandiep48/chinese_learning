/// Lessons module — per-character typing feedback for the card learners.
///
/// Ported from `lib/lessons/typingGlow.ts`: given the target characters and what
/// the learner has typed so far, one state per target character — correct or
/// wrong for a judged character, none for one not judged yet (nothing typed there,
/// or the typed slot is still a Latin letter, i.e. IME composition). `、`
/// separators in the target consume no input.
library;

enum GlowState { none, correct, wrong }

final RegExp _judge = RegExp(r'[一-鿿0-9０-９]');

List<GlowState> typingGlow(List<String> target, String value) {
  final typed = value.runes.map(String.fromCharCode).toList();
  final states = <GlowState>[];
  var ti = 0;
  for (final ch in target) {
    if (ch == '、') {
      states.add(GlowState.none);
      continue;
    }
    var state = GlowState.none;
    if (ti < typed.length && _judge.hasMatch(typed[ti])) {
      state = typed[ti] == ch ? GlowState.correct : GlowState.wrong;
    }
    states.add(state);
    ti++;
  }
  return states;
}
