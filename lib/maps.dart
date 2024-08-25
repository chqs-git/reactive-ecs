import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/entity_manager.dart';
import 'package:reactive_ecs/state.dart';

typedef KeyProducer<C extends Component, T> = T Function(C c);

class EntityMap<C extends Component, T> extends ChangeNotifier {
  final Map<T, int> data = {};
  final KeyProducer<C, T> keyProducer;
  final EntityManager manager;
  // constructor
  EntityMap({required this.keyProducer, required this.manager});

  bool isType(Type type) => C == type;

  void subscribe(Entity e, Component? prev, Component? next) {
    if (next is! C? || prev is! C?) return;
    // update key producer
    if (prev != null) data.remove(keyProducer(prev as C));
    if (next != null) data[keyProducer(next)] = e.index;
    notifyListeners(); // notify changes to map
  }

  Entity? getEntity(T key) {
    final index = data[key];
    return index != null ? manager.entities.get(index) : null;
  }

  C? get(T key) => getEntity(key)?.getOrNull<C>();
}

class EntityMultiMap<C extends Component, T> extends ChangeNotifier {
  final Map<T, List<int>> data = {};
  final KeyProducer<C, T> keyProducer;
  final EntityManager manager;
  // constructor
  EntityMultiMap({required this.keyProducer, required this.manager});
  
  bool isType(Type type) => C == type;
  
  void subscribe(Entity e, Component? prev, Component? next) {
    if (next is! C? || prev is! C?) return;
    // update key producer
    if (prev != null) {
      final key = keyProducer(prev as C);
      data[key] = data[key] ?? List.empty();
      data[key]!.remove(e.index);
    }
    if (next != null) {
      final key = keyProducer(next);
      data[key] = data[key] ?? List.empty();
      data[key] = [...data[key]!, e.index];
    }
    notifyListeners(); // notify changes to map
  }

  List<Entity> getEntities(T key) {
    final index = data[key] ?? List.empty();
    return index
        .map((id) => manager.entities.get(id))
        .whereType<Entity>()
        .toList();
  }

  List<C> get(T key) => getEntities(key).map((e) => e.get<C>()).toList();
}