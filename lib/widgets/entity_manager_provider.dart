import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/entity_manager.dart';
import 'package:reactive_ecs/system.dart';
import 'package:reactive_ecs/widgets/system.dart';

import '../behaviour.dart';

class EntityManagerProvider extends InheritedWidget {
  final EntityManager entityManager;
  final BehaviourManager behaviourManager;
  // constructor
  EntityManagerProvider({super.key, required this.entityManager, required List<System> systems, required super.child})
    : behaviourManager = BehaviourManager(
      behaviour: _buildBehaviour(systems, entityManager),
      reactiveBehaviour: ReactiveBehaviour(systems: systems.whereType<ReactiveSystem>().toList(), entityManager: entityManager),
      child: child
  );

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false; // TODO: check

  static EntityManager of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<EntityManagerProvider>();
    return provider!.entityManager;
  }

  static Behaviour _buildBehaviour(List<System> systems, EntityManager em) {
    final initSystems = <InitSystem>[];
    final cleanupSystems = <CleanupSystem>[];
    for (final system in systems) {
      if (system is InitSystem) initSystems.add(system);
      if (system is CleanupSystem) cleanupSystems.add(system);
    }
    return Behaviour(initSystems: initSystems, cleanupSystems: cleanupSystems, entityManager: em);
  }
}

extension EntityManagerUtils on BuildContext {
  EntityManager get entityManager => EntityManagerProvider.of(this);
}