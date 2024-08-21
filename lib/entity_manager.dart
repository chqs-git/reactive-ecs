import 'dart:collection';
import 'package:reactive_ecs/error_handling.dart';

import 'data_structures/sparse_set.dart';
import 'group.dart';
import 'state.dart';

class EntityManager {
  int currentIndex = 0;
  List<Entity> entities = [];
  // components
  final Map<Type, SparseSet<Component>> components = {};
  // groups
  final Map<GroupMatcher, Group> groups = {};

  Entity createEntity() {
    final e = Entity(index: currentIndex++, components: HashSet(), manager: this);
    entities = [...entities, e];
    return e;
  }

  /// Returns a unique entity with the given component or throws an exception if there is none.
  Entity getUniqueEntity<C extends UniqueComponent>() {
    final set = components[C];
    assertRecs(set != null && set.sparse.isNotEmpty, uniqueNotFound(C));
    return entities[set!.sparse.keys.first];
  }

  /// Returns a unique entity with the given component or null if there is none.
  ///
  /// Null safe operation.
  Entity? getUniqueEntityOrNull<C extends UniqueComponent>() {
    final set = components[C];
    if (set == null || set.sparse.isEmpty) return null;
    return entities[set.sparse.keys.first];
  }

  Group group(GroupMatcher matcher) {
    final group = groups[matcher];
    if (group != null) return group;

    final query = matcher.all.isNotEmpty ? fromAll(matcher) : fromAny(matcher);
    // check that entities have all the obligatory components
    final entitiesFiltered = query.where((e) => matcher.matches(e)).toList();
    final newGroup = Group(entities: entitiesFiltered);
    groups.addAll({matcher: newGroup}); // register the group
    return newGroup;
  }

  List<Entity> fromAll(GroupMatcher matcher) {
    final set = components[matcher.all.first];
    return set?.sparse.entries.map<Entity>((entry) => entities[entry.key]).toList() ?? [];
  }

  List<Entity> fromAny(GroupMatcher matcher) {
    final entitiesMutable = <Entity>[];
    for (final C in matcher.any) {
      final set = components[C];
      entitiesMutable.addAll(set?.sparse.entries.map<Entity>((entry) => entities[entry.key]) ?? []);
    }
    return entitiesMutable;
  }
}