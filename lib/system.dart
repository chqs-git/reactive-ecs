import 'package:reactive_ecs/group.dart';
import 'package:reactive_ecs/state.dart';

import 'entity_manager.dart';

/// Interface that all systems must implement.
abstract class System {}

/// Interface for systems that need to execute logic every frame.
///
/// ```dart
/// class MySystem extends EntityManagerSystem implements ExecuteSystem {
///  @override
///  void execute() {
///  // logic to run every frame
///  }
///
/// @override
/// void cleanup() {
///   // cleanup logic
///   }
/// }
/// ```
/// __Note__: In flutter the __execute__ & __cleanup__ methods are called every tick.
abstract class ExecuteSystem extends System {
  void execute();
  void cleanup();
}

/// Interface for systems to run login at initialization.
///
/// ```dart
/// class MySystem extends EntityManagerSystem implements InitSystem {
///  @override
///  void init(void Function() notifyWidgets) {
///  // logic to run at initialization
///  }
/// }
/// ```
/// __Note__: In flutter the __init__ method is called in the [init] method of the widget.
abstract class InitSystem extends System {
  void init(void Function() notifyWidgets);
}

/// Interface for systems to run logic at disposal.
///
/// ```dart
/// class MySystem extends EntityManagerSystem implements CleanupSystem {
///  @override
///  void cleanup() {
///  // logic to run at cleanup
///  }
/// }
///```
/// __Note__: In flutter the __cleanup__ method is called in the [dispose] method of the widget.
abstract class CleanupSystem extends System {
  void cleanup();
}

/// Interface that systems need to __extend__ from to access the [EntityManager].
abstract class EntityManagerSystem extends System {
  late EntityManager __manager;

  set manager(EntityManager m){
    __manager = m;
  }

  EntityManager get entityManager => __manager;
}

/// Contains details from a update that occurred in an [Entity].
/// [prev] is the previous [EntityAttribute].
/// [next] is the next [EntityAttribute].
class ChangeDetails {
  final EntityAttribute? prev;
  final EntityAttribute? next;
  // constructor
  ChangeDetails({required this.prev, required this.next});
}

/// Interface for systems that need to run logic when a condition is met.
///
/// ```dart
/// class MySystem extends ReactiveSystem {
///  @override
///  GroupMatcher get matcher => GroupMatcher.all([ComponentA, ComponentB]);
///
/// @override
/// GroupEventType get event => GroupEventType.add;
///
/// @override
/// void execute(Entity entity, ChangeDetails details) {
///  // logic to run when condition is met
///  }
/// ```
abstract class ReactiveSystem extends EntityManagerSystem {
  /// The [GroupMatcher] describes the criteria for the group this system will react to.
  GroupMatcher get matcher;
  /// The [GroupEventType] describes the event types that will trigger this system.
  GroupEventType get event;

  /// The [execute] method is called when the condition is met.
  void execute(Entity entity, ChangeDetails details);
}

enum GroupEventType { add, updated, addOrUpdated, remove, any }