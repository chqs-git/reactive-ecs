
import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

import 'error_handling.dart';

@immutable
abstract class Relationship extends EntityAttribute {}

class RelationshipPair extends Component {
  final Relationship relationship;
  final int entityIndex;

  RelationshipPair({required this.relationship, required this.entityIndex});
}

extension RelationshipOperations on Entity {
  int id(Entity e, Type type) => e.index ^ type.hashCode;

  bool hasRelationship<R extends Relationship>() => relationships.contains(R);

  bool hasRelationshipByType(Type type) => relationships.contains(type);

  bool hasAllRelationships(List<Type> types) => types.every((Type t) => hasRelationshipByType(t));

  bool hasAnyRelationships(List<Type> types) => types.isEmpty || types.any((Type t) => hasRelationshipByType(t));

  R getRelationship<R extends Relationship>() => (manager.components[R]!.get(id(this, R))! as RelationshipPair).relationship as R;

  R? getOrNullRelationship<R extends Relationship>() => (manager.components[R]?.get(id(this, R)) as RelationshipPair?)?.relationship as R?;

  Entity getRelationshipEntity<R extends Relationship>() {
    final entity = getRelationshipEntityOrNullByType(R);
    assertRecs(entity != null, componentOrRelationshipIsNull(R));
    return entity!;
  }

  Entity? getOrNullRelationshipEntity<R extends Relationship>() => getRelationshipEntityOrNullByType(R);

  List<Entity> getAllEntitiesWithRelationship<R extends Relationship>() {
    final sparseSet = manager.relationshipReverse[R];
    return sparseSet?.get(index)?.map((index) => manager.entities.get(index))
        .whereType<Entity>()
        .toList() ?? [];
  }

  Entity addRelationship<R extends Relationship>(R relationship, Entity entity) {
    assertRecs(isAlive, addOnDestroyed());

    final relationshipIndex = id(this, R);
    final sparseSet = manager.components[R];
    final reverseSparseSet = manager.relationshipReverse[R];
    final prev = getOrNullRelationship<R>();
    final prevEntity = getOrNullRelationshipEntity<R>();
    final relationshipPair = RelationshipPair(relationship: relationship, entityIndex: entity.index);
    if (sparseSet == null) {
      final newSparseSet = SparseSet.create<RelationshipPair>();
      newSparseSet.add(relationshipIndex, relationshipPair);
      manager.components.addAll({ R: newSparseSet });
      // reverse
      final newReverseSparseSet = SparseSet.create<List<int>>();
      newReverseSparseSet.add(entity.index, [index]);
      manager.relationshipReverse.addAll({ R: newReverseSparseSet });
    } else {
      sparseSet.contains(relationshipIndex)
          ? sparseSet.update(relationshipIndex, relationshipPair)
          : sparseSet.add(relationshipIndex, relationshipPair);
      reverseSparseSet!.contains(entity.index)
          ? reverseSparseSet.update(entity.index, [...reverseSparseSet.get(entity.index)!, index])
          : reverseSparseSet.add(entity.index, [index]);

      if (prevEntity != null) {
        reverseSparseSet.update(prevEntity.index, reverseSparseSet.get(prevEntity.index)!..remove(index));
      }
    }
    relationships.add(R);
    addEntityUpdates(prev, relationship);
    return this;
  }

  Entity removeRelationship<R extends Relationship>() => removeRelationshipByType(R);

  Entity removeRelationshipByType(Type type) {
    final relationshipIndex = id(this, type);
    final prev = getRelationshipEntityOrNullByType(type);
    manager.components[type]?.delete(relationshipIndex);
    if (prev != null) manager.relationshipReverse[type]?.get(prev.index)?.remove(relationshipIndex);
    relationships.remove(type);
    updated(this, prev?.getOrNullRelationship(), null); // notify listeners
    return this;
  }

  Entity? getRelationshipEntityOrNullByType(Type type) {
    final index = (manager.components[type]?.get(id(this, type)) as RelationshipPair?)?.entityIndex;
    return index != null ? manager.entities.get(index) : null;
  }
}