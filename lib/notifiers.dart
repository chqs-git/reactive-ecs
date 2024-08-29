import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/state.dart';

import 'system.dart';
import 'group.dart';

typedef EntityCallback = void Function(Entity e, EntityAttribute? prev, EntityAttribute? next);

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

typedef GroupCallback = void Function(GroupEventType type, Entity entity, ChangeDetails details);

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
      listener(GroupEventType.add, entity, details);
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
      listener(GroupEventType.remove, entity, details);
    }
    notifyListeners(); // notify listeners
  }
}