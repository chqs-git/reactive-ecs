import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/error_handling.dart';
import 'data_structures/sparse_set.dart';
import 'entity_manager.dart';

@immutable
abstract class Component {}

@immutable
abstract class UniqueComponent extends Component {}

class Entity extends ChangeNotifier {
  final int index;
  final HashSet<Type> components;
  final EntityManager manager;
  bool isAlive = true;

  // constructor
  Entity({required this.index, required this.components, required this.manager});

  bool has<C extends Component>() => components.contains(C);

  bool hasAll(List<Type> types) => types.every((Type t) => hasType(t));

  Entity add(Component c) => this + c;

  Entity remove<C extends Component>() => this - C;

  bool hasType(Type c) => components.contains(c.runtimeType);

  Entity operator + (Component c) {
    assertRecs(isAlive, addOnDestroyed());
    final sparseSet = manager.components[c.runtimeType];
    assertRecs(c is! UniqueComponent || (sparseSet == null || (sparseSet.sparse.isEmpty) || sparseSet.sparse.containsKey(index)), uniqueRestraint(c.runtimeType));

    if (sparseSet == null) {
      final newSparseSet = SparseSet.create<Component>();
      newSparseSet.add(index, c);
      manager.components.addAll({ c.runtimeType: newSparseSet });
    } else {
      sparseSet.add(index, c);
    }
    components.add(c.runtimeType);
    notifyListeners(); // notify listeners
    return this;
  }

  Entity operator - (Type C) {
    manager.components[C]?.delete(index);
    components.remove(C);
    notifyListeners(); // notify listeners
    return this;
  }

  void destroy() {
    isAlive = false;
    // remove all components components
    for (final C in components) {
      this - C;
    }
    manager.entities.removeAt(index); // remove from list of entities
    notifyListeners(); // notify listeners
  }
}