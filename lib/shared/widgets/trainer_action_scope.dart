/// Shared — lets a host (the milestone) take over a trainer's bottom bar.
///
/// Mirrors the web's `bottomBarSlot` / `useTrainerActionSlot`: inside a
/// [TrainerActionScope] a trainer's [TrainerBarSlot] publishes its primary
/// action (Check / Next / Continue) to the host's [TrainerActionController]
/// instead of drawing its own bar, so one nav bar carries Quit · Previous · action.
/// Outside a scope the slot renders the trainer's own [standalone] bar.
library;

import 'package:flutter/material.dart';

/// What the on-screen trainer wants shown in the host's nav bar.
@immutable
class TrainerAction {
  const TrainerAction({
    required this.label,
    required this.enabled,
    required this.confirmQuit,
  });

  final String label;
  final bool enabled;

  /// Whether Quit should ask first (false on the recap, where nothing is lost).
  final bool confirmQuit;

  @override
  bool operator ==(Object other) =>
      other is TrainerAction &&
      other.label == label &&
      other.enabled == enabled &&
      other.confirmQuit == confirmQuit;

  @override
  int get hashCode => Object.hash(label, enabled, confirmQuit);
}

class TrainerActionController extends ChangeNotifier {
  TrainerAction? _action;
  Object? _owner;
  bool _disposed = false;

  /// The latest press handler; updated every frame without notifying so the
  /// host never rebuilds just because a closure was recreated.
  VoidCallback? onPressed;

  TrainerAction? get action => _action;

  /// Publishes [next] on behalf of [owner] (the slot's state object).
  void publish(Object owner, TrainerAction next) {
    if (_disposed) return;
    _owner = owner;
    if (_action == next) return;
    _action = next;
    notifyListeners();
  }

  /// Clears the action, but only if [owner] is still the one showing it — a
  /// slot mounted in the same frame has already taken over otherwise.
  void clear(Object owner) {
    if (_disposed || _owner != owner) return;
    _owner = null;
    _action = null;
    onPressed = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class TrainerActionScope extends InheritedWidget {
  const TrainerActionScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final TrainerActionController controller;

  static TrainerActionController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TrainerActionScope>()?.controller;

  @override
  bool updateShouldNotify(TrainerActionScope old) =>
      old.controller != controller;
}

class TrainerBarSlot extends StatefulWidget {
  const TrainerBarSlot({
    super.key,
    required this.label,
    required this.onPressed,
    required this.confirmQuit,
    required this.standalone,
  });

  final String label;

  /// Null means the primary action is disabled.
  final VoidCallback? onPressed;
  final bool confirmQuit;

  /// The trainer's own bar, used when no host scope exists.
  final Widget standalone;

  @override
  State<TrainerBarSlot> createState() => _TrainerBarSlotState();
}

class _TrainerBarSlotState extends State<TrainerBarSlot> {
  TrainerActionController? _controller;

  void _publish() {
    final controller = _controller;
    if (controller == null) return;
    controller.onPressed = widget.onPressed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controller != controller) return;
      controller.publish(
        this,
        TrainerAction(
          label: widget.label,
          enabled: widget.onPressed != null,
          confirmQuit: widget.confirmQuit,
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = TrainerActionScope.maybeOf(context);
    _publish();
  }

  @override
  void didUpdateWidget(TrainerBarSlot old) {
    super.didUpdateWidget(old);
    _publish();
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.clear(this),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _controller == null ? widget.standalone : const SizedBox.shrink();
}
