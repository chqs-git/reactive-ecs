import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/src/behaviour.dart';
import 'package:reactive_ecs/src/widgets/system.dart';

import '../../reactive_ecs.dart';
import '../system.dart';

/// Widget which holds a reference to an [EntityManager] instance and can expose it to children.
///
/// This widget will create the required behaviour widgets to support the given [System]s.
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
      oldWidget.entityManager.attributes.length != entityManager.attributes.length;

  /// get the [EntityManager] instance from the [EntityManagerProvider] widget.
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
  /// get the [EntityManager] instance from the [EntityManagerProvider] widget.
  EntityManager get entityManager => EntityManagerProvider.of(this);
}