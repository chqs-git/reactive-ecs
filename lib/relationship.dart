
import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

import 'error_handling.dart';

@immutable
abstract class Relationship {}

class RelationshipPair {
  final Relationship relationship;
  final int entityIndex;

  RelationshipPair({required this.relationship, required this.entityIndex});
}

extension RelationshipOperations on Entity {
  int id(Entity e, Type type) => e.index ^ type.hashCode;

  bool hasRelationship<R extends Relationship>() => manager.relationships[R]?.contains(id(this, R)) ?? false;

  R getRelationship<R extends Relationship>() => manager.relationships[R]!.get(id(this, R))!.relationship as R;

  R? getOrNullRelationship<R extends Relationship>() => manager.relationships[R]?.get(id(this, R))?.relationship as R?;

  Entity getRelationshipEntity<R extends Relationship>() {
    final index = manager.relationships[R]!.get(id(this, R))!.entityIndex;
    return manager.entities.get(index)!;
  }

  Entity? getOrNullRelationshipEntity<R extends Relationship>() {
    final index = manager.relationships[R]?.get(id(this, R))?.entityIndex;
    return index != null ? manager.entities.get(index) : null;
  }

  List<Entity> getAllEntitiesWithRelationship<R extends Relationship>() {
    final sparseSet = manager.relationshipReverse[R];
    return sparseSet?.get(index)?.map((index) => manager.entities.get(index))
        .whereType<Entity>()
        .toList() ?? [];
  }

  Entity addRelationship<R extends Relationship>(R relationship, Entity entity) {
    assertRecs(isAlive, addOnDestroyed());

    final relationshipIndex = id(this, R);
    final sparseSet = manager.relationships[R];
    final reverseSparseSet = manager.relationshipReverse[R];
    final relationshipPair = RelationshipPair(relationship: relationship, entityIndex: entity.index);
    if (sparseSet == null) {
      final newSparseSet = SparseSet.create<RelationshipPair>();
      newSparseSet.add(relationshipIndex, relationshipPair);
      manager.relationships.addAll({ R: newSparseSet });
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
    }

    // TODO: add to groups that match the new set of relationships
    return this;
  }

  Entity removeRelationship<R extends Relationship>(Entity entity) {
    final relationshipIndex = id(this, R);
    final prev = manager.relationships[R]?.get(relationshipIndex);
    manager.relationships[R]?.delete(relationshipIndex);
    manager.relationshipReverse[R]?.get(entity.index)?.remove(relationshipIndex);
    return this;
  }
}