import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'data_structures/sparse_set.dart';
import 'entity_manager.dart';

@immutable
abstract class Component {}

@immutable
abstract class UniqueComponent extends Component {}

class Entity {
  final int index;
  final HashSet<Type> components;
  final EntityManager manager;

  // constructor
  Entity({required this.index, required this.components, required this.manager});

  bool has<C extends Component>() => components.contains(C);

  Entity add(Component c) => this + c;

  Entity remove<C extends Component>() => this - C;

  bool hasType(Type c) => components.contains(c.runtimeType);

  Entity operator + (Component c) {
    final sparseSet = manager.components[c.runtimeType];
    if (sparseSet == null) {
      final newSparseSet = SparseSet.create<Component>();
      newSparseSet.add(index, c);
      manager.components.addAll({ c.runtimeType: newSparseSet });
    } else {
      sparseSet.add(index, c);
    }
    components.add(c.runtimeType);
    return this;
  }

  Entity operator - (Type C) {
    manager.components[C]?.delete(index);
    components.remove(C);
    return this;
  }

  void destroy() {
    // remove all components components
    for (final C in components) {
      this - C;
    }
    manager.entities.removeAt(index); // remove from list of entities
  }
}