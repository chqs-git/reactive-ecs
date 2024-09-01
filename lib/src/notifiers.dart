import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/src/state.dart';

import 'system.dart';
import 'group.dart';

/// The [EntityCallback] is a function that is called when an [Entity] is updated.
typedef EntityCallback = void Function(Entity e, EntityAttribute? prev, EntityAttribute? next);

/// The [EntityListenable] is a [ChangeNotifier] that can be used to listen to changes in an [Entity].
class EntityListenable extends ChangeNotifier {
  final List<EntityCallback> _subscribers = [];

  void subscribe(EntityCallback listener) {
    _subscribers.add(listener);
  }

  void unsubscribe(EntityCallback listener) {
    _subscribers.remove(listener);
  }

  void updated(Entity e, EntityAttribute? prev, EntityAttribute? next) {
    // notify reactive systems
    for (EntityCallback listener in _subscribers) {
      listener(e, prev, next);
    }
    notifyListeners(); // notify listeners
  }
}

/// The [GroupCallback] is a function that is called when an [Entity] is added, updated or removed from a [Group].
typedef GroupCallback = void Function(GroupEventType type, Entity entity, ChangeDetails details);

/// The [GroupNotifier] is a [ChangeNotifier] that can be used to listen to changes in a [Group].
class GroupNotifier extends ChangeNotifier {
  final List<GroupCallback> _subscribers = [];

  void subscribe(GroupCallback listener) {
    _subscribers.add(listener);
  }

  void unsubscribe(GroupCallback listener) {
    _subscribers.remove(listener);
  }

  void added(Group group, Entity entity, ChangeDetails details) {
    // notify reactive systems
    for (var listener in _subscribers) {
      listener(GroupEventType.added, entity, details);
    }
    notifyListeners(); // notify listeners
  }

  void updated(Group group, Entity entity, ChangeDetails details) {
    // notify reactive systems
    for (var listener in _subscribers) {
      listener(GroupEventType.updated, entity, details);
    }
    notifyListeners(); // notify listeners
  }

  void removed(Group group, Entity entity, ChangeDetails details) {
    // notify reactive systems
    for (var listener in _subscribers) {
      listener(GroupEventType.removed, entity, details);
    }
    notifyListeners(); // notify listeners
  }
}