
import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

import 'error_handling.dart';

/// A [Relationship] is a special type of [EntityAttribute]. It can contain data
/// like a [Component], but it is used to establish a relationship between two entities.
///
/// Relationships are __One-Way__ and thus have a specific way to how they work:
/// Say we have three entities.
/// [ChildOf] is a relationship that establishes a child-parent relationship between two entities.
///
/// ```dart
/// entityB.addRelationship(ChildOf(), entityA); // Entity B is [ChildOf] Entity A
/// entityB.getRelationship<ChildOf>(); // returns (entityA, ChildOf())
/// entityA.getRelationship<ChildOf>(); // returns null
/// // but we can get all entities that are children of entityA
/// entityA.getAllEntitiesWithRelationship<ChildOf>(); // returns [entityB]
/// entityC.addRelationship(ChildOf(), entityA); // Entity C is ChildOf Entity A
/// entityA.getAllEntitiesWithRelationship<ChildOf>(); // returns [entityB, entityC]
/// ```
///
/// This property allows us to create __One-to-One__ and __One-to-Many__ relationships
/// between entities.
@immutable
abstract class Relationship extends EntityAttribute {}

extension RelationshipOperations on Entity {

  /// Returns a (Entity, Relationship) pair if the relationship exists.
  ///
  /// If the relationship does not exist, it throws an [AssertionError].
  (Entity, R) getRelationship<R extends Relationship>() {
    final data = getOrNullRelationship<R>();
    assertRecs(data != null, componentOrRelationshipIsNull(R));
    return data!;
  }

  /// Returns a (Entity, Relationship) pair if the relationship exists.
  ///
  /// __Null Safety__: If the relationship does not exist, it returns null.
  (Entity, R)? getOrNullRelationship<R extends Relationship>() {
    final relationship = getOrNull<R>();
    final entityIndex = manager.relationships[index ^ R.hashCode];
    if (relationship == null || entityIndex == null) return null;
    final entity = manager.entities.get(entityIndex);
    return entity != null ? (entity, relationship) : null;
  }

  /// Returns a list of all entities that have a relationship with this entity.
  List<Entity> getAllEntitiesWithRelationship<R extends Relationship>() {
    final sparseSet = manager.relationshipReverse[R];
    return sparseSet?.get(index)?.map((index) => manager.entities.get(index))
        .whereType<Entity>()
        .toList() ?? [];
  }

  /// Adds to __this__ entity a [Relationship] with another [Entity].
  ///
  /// If the relationship already exists, it updates the relationship.
  Entity addRelationship<R extends Relationship>(R relationship, Entity entity) {
    final reverseSparseSet = manager.relationshipReverse[R];
    final prevEntity = getOrNullRelationship<R>()?.$1;
    if (reverseSparseSet == null) {
      // reverse
      final newReverseSparseSet = SparseSet.create<List<int>>();
      newReverseSparseSet.add(entity.index, [index]);
      manager.relationshipReverse.addAll({ R: newReverseSparseSet });
    } else {
      reverseSparseSet.contains(entity.index)
          ? reverseSparseSet.update(entity.index, [...reverseSparseSet.get(entity.index)!, index])
          : reverseSparseSet.add(entity.index, [index]);

      if (prevEntity != null) {
        reverseSparseSet.update(prevEntity.index, reverseSparseSet.get(prevEntity.index)!..remove(index));
      }
    }
    manager.relationships[index ^ R.hashCode] = entity.index;

    addAttribute(relationship); // add attribute and notify listeners
    return this;
  }

  /// Removes a [Relationship] from __this__ entity.
  ///
  /// If the relationship does not exist, it does nothing.
  Entity removeRelationship<R extends Relationship>() => removeRelationshipByType(R);

  Entity removeRelationshipByType(Type type) {
    final entityIndex = manager.relationships[index ^ type.hashCode];
    final prev = manager.attributes[type]?.get(index);
    if (entityIndex == null) return this;
    final entity = manager.entities.get(entityIndex);
    manager.attributes[type]?.delete(index);
    manager.relationships.remove(index ^ type.hashCode);
    if (entity != null) manager.relationshipReverse[type]?.get(entity.index)?.remove(index);
    attributes.remove(type);
    updated(this, prev, null); // notify listeners
    return this;
  }
}