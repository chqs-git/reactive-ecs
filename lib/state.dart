import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/error_handling.dart';
import 'package:reactive_ecs/relationship.dart';
import 'package:reactive_ecs/utils/group_utils.dart';
import 'data_structures/sparse_set.dart';
import 'entity_manager.dart';
import 'notifiers.dart';

/// An [EntityAttribute] represents an attribute from a [Entity], 
/// it can be a [Component] or a [Relationship].
abstract class EntityAttribute {}

/// A [Component] is a data structure that holds data for an [Entity].
/// 
/// An entity can only contain one [Component] of a given type.
@immutable
abstract class Component extends EntityAttribute {}

/// A [UniqueComponent] is a [Component] that is unique through the whole system.
/// Meaning that only one [Entity] can have a given [UniqueComponent].
@immutable
abstract class UniqueComponent extends Component {}

/// An [Entity] is a container for [EntityAttribute]s.
/// 
/// Entities are the main building blocks of the ECS architecture. 
/// They are indexes that hold a group of [Component] and [Relationship]s.
class Entity extends EntityListenable {
  final int index;
  final HashSet<Type> attributes;
  final EntityManager manager;
  bool isAlive = true;
  // constructor
  Entity({required this.index, required this.attributes, required this.manager});

  /// Returns [True] if the entity contains the given [Component] or [Relationship].
  bool has<A extends EntityAttribute>() => attributes.contains(A);

  /// Returns [True] if the entity contains all of the given [Component]s and [Relationship]s.
  bool hasAll(List<Type> types) => types.every((Type t) => hasType(t));

  /// Returns [True] if the entity contains any of the given [Component]s and [Relationship]s.
  bool hasAny(List<Type> types) => types.isEmpty || types.any((Type t) => hasType(t));

  /// Returns a [Component] or [Relationship] of the given type.
  /// 
  /// If the entity does not contain the given type, an [AssertionError] is thrown.
  Attribute get<Attribute extends EntityAttribute>() {
    final attribute = getOrNull<Attribute>();
    assertRecs(attribute != null, componentOrRelationshipIsNull(Attribute));
    return attribute!;
  }

  /// Returns a [Component] or [Relationship] of the given type.
  /// 
  /// __Null Safety__: If the entity does not contain the given type, [null] is returned.
  Attribute? getOrNull<Attribute extends EntityAttribute>() => _getAttribute(Attribute);

  Attribute? _getAttribute<Attribute extends EntityAttribute>(Type type) => manager.attributes[type]?.get(index) as Attribute?;

  /// Add [Component] instance to __this__ [Entity].
  /// 
  /// If this entity already contains a [Component] of the same type, it will be update.
  /// 
  /// This operation will notify all listeners of the change.
  Entity add(Component component) => addAttribute(component);

  /// Removes a [Component] from __this__ [Entity].
  /// 
  /// This operation will notify all listeners of the change.
  Entity remove<C extends Component>() => this - C;

  bool hasType(Type c) => attributes.contains(c);
  
  Entity operator +(Component c) => add(c);

  /// Do not use this method directly. Use the operator [Entity.add] instead.
  Entity addAttribute<C extends EntityAttribute>(EntityAttribute attribute) {
    assertRecs(isAlive, addOnDestroyed());
    final prev = _getAttribute(attribute.runtimeType) as C?;
    final sparseSet = manager.attributes[attribute.runtimeType];
    assertRecs(attribute is! UniqueComponent || (sparseSet == null || (sparseSet.sparse.isEmpty) || sparseSet.sparse.containsKey(index)), uniqueRestraint(attribute.runtimeType));

    if (sparseSet == null) {
      final newSparseSet = SparseSet.create<EntityAttribute>();
      newSparseSet.add(index, attribute);
      manager.attributes.addAll({ attribute.runtimeType: newSparseSet });
    } else {
      sparseSet.contains(index) ? sparseSet.update(index, attribute) : sparseSet.add(index, attribute);
    }
    attributes.add(attribute.runtimeType); // add component to entity

    _addEntityUpdates(prev, attribute);
    return this;
  }

  Entity operator - (Type C) {
    final prev = manager.attributes[C]?.get(index);
    manager.attributes[C]?.delete(index);
    attributes.remove(C);
    updated(this, prev, null);
    return this;
  }

  /// This method will destroy __this__ Entity and remove it from the [EntityManager].
  /// 
  /// All [Component]s and [Relationship]s will also be removed. Each remove operation
  /// will notify all listeners of the change.
  void destroy() {
    isAlive = false;
    // remove all components components
    for (final C in attributes.toList()) {
      final attribute = manager.attributes[C]?.get(index);
      if (attribute is Component) this - C;
      if (attribute is Relationship) removeRelationshipByType(C);
    }

    manager.entities.delete(index); // remove from list of entities
  }

  void _addEntityUpdates(EntityAttribute? prev, EntityAttribute? next) {
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