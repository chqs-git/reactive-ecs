import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/entity_manager.dart';
import 'package:reactive_ecs/behaviour.dart';
import 'package:reactive_ecs/widgets/system.dart';

import '../system.dart';

class EntityManagerProvider extends InheritedWidget {
  final EntityManager entityManager;

  // constructor
  EntityManagerProvider({super.key, required this.entityManager, required List<System> systems, required Widget child})
    : super(child: BehaviourManager(
        entityManager: entityManager,
        behaviour: _buildBehaviour(systems, entityManager),
        reactiveBehaviour: ReactiveBehaviour(systems: systems.whereType<ReactiveSystem>().toList(), entityManager: entityManager),
        executeSystems: systems.whereType<ExecuteSystem>().toList(),
        child: child
      ));

  @override
  bool updateShouldNotify(covariant EntityManagerProvider oldWidget) =>
      oldWidget.entityManager.currentIndex != entityManager.currentIndex ||
      oldWidget.entityManager.components.length != entityManager.components.length;

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