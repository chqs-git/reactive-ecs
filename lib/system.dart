import 'package:reactive_ecs/group.dart';
import 'package:reactive_ecs/state.dart';

import 'entity_manager.dart';

/// Interface that all behaviours must implement.
abstract class System {}

/// Interface for systems that need to execute logic every frame.
abstract class ExecuteSystem extends System {
  void execute();
  void cleanup();
}

/// Interface for systems to run login at initialization.
abstract class InitSystem extends System {
  void init(void Function() notifyWidgets);
}

/// Interface for systems to run logic at disposal
abstract class CleanupSystem extends System {
  void cleanup();
}


abstract class EntityManagerSystem extends System {
  late EntityManager __manager;

  set manager(EntityManager m){
    __manager = m;
  }

  EntityManager get entityManager => __manager;
}

/// Contains details from a update that occurred in an entity.
/// [prev] is the previous attribute of the entity.
/// [next] is the next attribute of the entity.
class ChangeDetails {
  final EntityAttribute? prev;
  final EntityAttribute? next;
  // constructor
  ChangeDetails({required this.prev, required this.next});
}

/// Interface for systems that need to run logic when a condition is met.
abstract class ReactiveSystem extends EntityManagerSystem {
  GroupMatcher get matcher;
  GroupEventType get event;

  void execute(Entity entity, ChangeDetails details);
}

enum GroupEventType { add, updated, addOrUpdated, remove, any }