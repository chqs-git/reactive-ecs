import 'dart:collection';
import 'package:reactive_ecs/src/system.dart';
import 'package:reactive_ecs/src/state.dart';
import 'entity_manager.dart';

class Behaviour {
  final List<InitSystem> initSystems;
  final List<CleanupSystem> cleanupSystems;
  final EntityManager _entityManager;
  // constructor
  Behaviour({this.initSystems = const [], this.cleanupSystems = const [], required EntityManager entityManager}) : _entityManager = entityManager;

  /// Initialize behaviour
  /// This is called by the behaviour Widget when it is initialized
  void init({Function()? setState}) async {
    for(int i = 0; i < initSystems.length; i++) {
      final s = initSystems[i];
      if (s is EntityManagerSystem) (s as EntityManagerSystem).manager = _entityManager;
    }

    for(int i = 0; i < cleanupSystems.length; i++) {
      final s = cleanupSystems[i];
      if (s is EntityManagerSystem) (s as EntityManagerSystem).manager = _entityManager;
    }

    for (final s in initSystems) {
      await s.init(setState ?? () {});
    }
  }

  /// Dispose of behaviour
  /// This is called by the behaviour Widget when it is disposed
  void dispose() async {
    for(int i = 0; i < cleanupSystems.length; i++) {
      await cleanupSystems[i].cleanup();
    }
  }
}

class ReactiveBehaviour {
  final List<ReactiveSystem> systems;
  final EntityManager _entityManager;
  final Queue<Function> _updateQueue = Queue();
  final bool allowConcurrentExecution;
  bool executing = false;
  // constructor
  ReactiveBehaviour({required this.systems, required EntityManager entityManager, this.allowConcurrentExecution = false}) : _entityManager = entityManager;

  /// Initialize behaviour
  /// This is called by the behaviour Widget when it is initialized
  void init() {
    for(int i = 0; i < systems.length; i++) {
      systems[i].manager = _entityManager;
      final group = _entityManager.group(systems[i].matcher);
      // subscribe to group events
      group.subscribe((event, entity, details) => execute(i, event, entity, details));
    }
  }

  /// Dispose of behaviour
  /// This is called by the behaviour Widget when it is disposed
  void dispose() {
    for(int i = 0; i < systems.length; i++) {
      final group = _entityManager.group(systems[i].matcher);
      // unsubscribe to group events
      group.unsubscribe((event, entity, details) => execute(i, event, entity, details));
    }
  }

  /// This method is called by the group when an event occurs.
  /// It executes the system if the event matches the system's event type.
  /// If the system is already executing, it adds the execution request to the update queue to prevent infinite loops.
  /// Once the current execution is complete, it processes any pending requests in the update queue.
  void execute(int index, GroupEventType event, Entity entity, ChangeDetails details) {
    if (executing && !allowConcurrentExecution) {
      _updateQueue.add(() => execute(index, event, entity, details));
      return;
    }

    executing = true;
    final system = systems[index];
    if (system.event == GroupEventType.any || system.event == event || system.event == GroupEventType.addedOrUpdated && (event == GroupEventType.added || event == GroupEventType.updated)) {
      system.execute(entity, details);
    }

    executing = false;
    while(_updateQueue.isNotEmpty) {
      _updateQueue.removeFirst()();
    }
  }
}