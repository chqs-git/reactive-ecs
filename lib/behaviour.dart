
import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/group.dart';
import 'package:reactive_ecs/state.dart';

import 'entity_manager.dart';

/// Interface that all behaviours must implement.
abstract class System {}

/// Interface for systems that need to execute logic every frame.
abstract class ExecuteSystem extends System {
  void execute();
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

/// Interface for systems that need to run logic when a condition is met.
abstract class ReactiveSystem extends EntityManagerSystem {
  GroupMatcher get matcher;
  GroupEventType get event;

  void execute(Entity entity);
}

enum GroupEventType { add, updated, addOrUpdated, remove, any }