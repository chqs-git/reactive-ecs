import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/entity_manager.dart';

class EntityManagerProvider extends InheritedWidget {
  final EntityManager entityManager;
  // constructor
  const EntityManagerProvider({super.key, required this.entityManager, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false; // TODO: check

  static EntityManager of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<EntityManagerProvider>();
    return provider!.entityManager;
  }
}

extension EntityManagerUtils on BuildContext {
  EntityManager get entityManager => EntityManagerProvider.of(this);
}