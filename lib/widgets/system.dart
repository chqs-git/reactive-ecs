
import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/behaviour.dart';
import 'package:reactive_ecs/group.dart';
import 'package:reactive_ecs/widgets/entity_manager_provider.dart';

import '../notifiers.dart';

class RootSystem extends StatefulWidget {
  final List<InitSystem> initSystems;
  final List<CleanupSystem> cleanupSystems;
  final List<ReactiveSystem> reactiveSystems;
  final Widget child;
  const RootSystem({super.key, required this.initSystems, required this.cleanupSystems, required this.reactiveSystems, required this.child});

  @override
  State<StatefulWidget> createState() => RootSystemState();
}

class RootSystemState extends State<RootSystem> {
  final List<GroupCallback> callbacks = [];

  @override
  void initState() {
    super.initState();
    // run init behaviour
    for (final system in widget.initSystems) {
      system.init( () => setState(() {}) );
    }

    // setup reactive systems
    final em = context.entityManager;
    for (final system in widget.reactiveSystems) {
      final group = em.group(system.matcher);
      // subscribe to group events
      group.subscribe((event, entity) {
        if (system.event == GroupEventType.any || system.event == event) {
          system.execute(entity);
        }
      });
    }
  }

  @override
  void dispose() {
    final em = context.entityManager;
    for (final system in widget.cleanupSystems) {
      system.cleanup();
    }
    for (int i = 0; i < widget.reactiveSystems.length; i++) {
      final group = em.group(widget.reactiveSystems[i].matcher);
      // subscribe to group events
      group.unsubscribe(callbacks[i]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}