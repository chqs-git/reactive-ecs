import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

/// Widget that handles all the systems and behaviours.
class BehaviourManager extends StatefulWidget {
  final Behaviour behaviour;
  final ReactiveBehaviour reactiveBehaviour;
  final List<ExecuteSystem> executeSystems;
  final EntityManager entityManager;
  final Widget child;
  const BehaviourManager({
    super.key, required this.behaviour, required this.child, required this.reactiveBehaviour,
    required this.executeSystems, required this.entityManager
  });

  @override
  State<StatefulWidget> createState() => BehaviourManagerState();
}

class BehaviourManagerState extends State<BehaviourManager> {
  @override
  void initState() {
    super.initState();
    widget.behaviour.init(setState: () => setState(() {}));
    widget.reactiveBehaviour.init();
  }

  @override
  void dispose() {
    widget.reactiveBehaviour.dispose();
    widget.behaviour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.executeSystems.isEmpty
      ? widget.child
      : ExecuteBehaviourTicker(systems: widget.executeSystems, entityManager: widget.entityManager, child: widget.child);
}

class ExecuteBehaviourTicker extends StatefulWidget {
  final List<ExecuteSystem> systems;
  final EntityManager entityManager;
  final Widget child;
  const ExecuteBehaviourTicker({super.key, required this.systems, required this.child, required this.entityManager});

  @override
  State<StatefulWidget> createState() => ExecuteBehaviourTickerState();
}

class ExecuteBehaviourTickerState extends State<ExecuteBehaviourTicker> with TickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void initState() {
    super.initState();
    for (final system in widget.systems) {
      if (system is EntityManagerSystem) {
        (system as EntityManagerSystem).manager = widget.entityManager;
      }
    }
    _ticker = createTicker(tick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.stop();
    super.dispose();
  }

  tick(Duration elapsed) {
    for (final system in widget.systems) {
      system.execute();
    }
    for (final system in widget.systems) {
      system.cleanup();
    }
  }
}