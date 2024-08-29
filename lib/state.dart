import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/error_handling.dart';
import 'package:reactive_ecs/relationship.dart';
import 'package:reactive_ecs/utils/group_utils.dart';
import 'data_structures/sparse_set.dart';
import 'entity_manager.dart';
import 'notifiers.dart';

abstract class EntityAttribute {}

@immutable
abstract class Component extends EntityAttribute {}

@immutable
abstract class UniqueComponent extends Component {}

class Entity extends EntityListenable {
  final int index;
  final HashSet<Type> components;
  final HashSet<Type> relationships;
  final EntityManager manager;
  bool isAlive = true;

  // constructor
  Entity({required this.index, required this.components, required this.relationships, required this.manager});

  bool has<C extends Component>() => components.contains(C);

  bool hasAll(List<Type> types) => types.every((Type t) => hasType(t));

  bool hasAny(List<Type> types) => types.isEmpty || types.any((Type t) => hasType(t));

  /// Returns a component of the given type or throws an exception if there is none.
  C get<C extends Component>() => manager.components[C]!.get(index)! as C;

  /// Returns a component of the given type or null if there is none.
  C? getOrNull<C extends Component>() => manager.components[C]?.get(index) as C?;

  C? _getComponent<C extends Component>(Type type) => manager.components[type]?.get(index) as C?;

  Entity add<C extends Component>(C c) {
    assertRecs(isAlive, addOnDestroyed());
    final prev = _getComponent(c.runtimeType) as C?;
    final sparseSet = manager.components[c.runtimeType];
    assertRecs(c is! UniqueComponent || (sparseSet == null || (sparseSet.sparse.isEmpty) || sparseSet.sparse.containsKey(index)), uniqueRestraint(c.runtimeType));

    if (sparseSet == null) {
      final newSparseSet = SparseSet.create<Component>();
      newSparseSet.add(index, c);
      manager.components.addAll({ c.runtimeType: newSparseSet });
    } else {
      sparseSet.contains(index) ? sparseSet.update(index, c) : sparseSet.add(index, c);
    }
    components.add(c.runtimeType); // add component to entity
    
    addEntityUpdates(prev, c);
    return this;
  }

  Entity remove<C extends Component>() => this - C;

  bool hasType(Type c) => components.contains(c);

  Entity operator +(Component c) => add(c);

  Entity operator - (Type C) {
    final prev = manager.components[C]?.get(index);
    manager.components[C]?.delete(index);
    components.remove(C);
    updated(this, prev, null);
    return this;
  }

  void destroy() {
    isAlive = false;
    // remove all components components
    for (final C in components.toList()) {
      this - C;
    }
    
    for(final R in relationships.toList()) {
      removeRelationshipByType(R);
    }

    manager.entities.delete(index); // remove from list of entities
    notifyListeners(); // notify listeners
  }

  void addEntityUpdates(EntityAttribute? prev, EntityAttribute? next) {
    if (prev == null) {
      // add entity to groups that match the new set of components
      for (final group in manager.groups.values) {
        if (group.matcher.matches(this) && !group.contains(this)) group.addEntity(this);
      }
      // add to maps
      for (final map in manager.maps) {
        if (map.isType(next.runtimeType)) {
          subscribe(map.subscribe);
        }
      }

      for(final map in manager.multiMaps) {
        if (map.isType(next.runtimeType)) {
          subscribe(map.subscribe);
        }
      }
    }

    updated(this, prev, next); // notify listeners
  }
}