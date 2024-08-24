import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/state.dart';

import 'behaviour.dart';
import 'group.dart';

typedef EntityCallback = void Function(Entity e, Component? prev, Component? next);

class EntityListenable extends ChangeNotifier {
  final List<EntityCallback> _subscribers = [];

  void subscribe(EntityCallback listener) {
    _subscribers.add(listener);
  }

  void unsubscribe(EntityCallback listener) {
    _subscribers.remove(listener);
  }

  void updated(Entity e, Component? prev, Component? next) {
    // notify reactive systems
    for (EntityCallback listener in _subscribers) {
      listener(e, prev, next);
    }
    notifyListeners(); // notify listeners
  }
}

typedef GroupCallback = void Function(GroupEventType type, Entity entity);

class GroupNotifier extends ChangeNotifier {
  final List<GroupCallback> _subscribers = [];

  void subscribe(GroupCallback listener) {
    _subscribers.add(listener);
  }

  void unsubscribe(GroupCallback listener) {
    _subscribers.remove(listener);
  }

  void added(Group group, Entity entity) {
    // notify reactive systems
    for (var listener in _subscribers) {
      listener(GroupEventType.add, entity);
    }
    notifyListeners(); // notify listeners
  }

  void updated(Group group, Entity entity) {
    // notify reactive systems
    for (var listener in _subscribers) {
      listener(GroupEventType.updated, entity);
    }
    notifyListeners(); // notify listeners
  }

  void removed(Group group, Entity entity) {
    // notify reactive systems
    for (var listener in _subscribers) {
      listener(GroupEventType.remove, entity);
    }
    notifyListeners(); // notify listeners
  }
}