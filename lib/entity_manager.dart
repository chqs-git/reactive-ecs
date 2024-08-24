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

  C getUnique<C extends UniqueComponent>() {
    final set = components[C];
    assertRecs(set != null && set.dense.isNotEmpty, uniqueNotFound(C));
    return set!.dense.first as C;
  }

  /// Returns a unique entity with the given component or null if there is none.
  ///
  /// Null safe operation.
  Entity? getUniqueEntityOrNull<C extends UniqueComponent>() {
    final set = components[C];
    if (set == null || set.sparse.isEmpty) return null;
    return entities[set.sparse.keys.first];
  }

  C? getUniqueOrNull<C extends UniqueComponent>() {
    final set = components[C];
    if (set == null || set.dense.isEmpty) return null;
    return set.dense.first as C;
  }

  Group group(GroupMatcher matcher) {
    final group = groups[matcher];
    if (group != null) return group;

    final query = matcher.all.isNotEmpty ? _fromAll(matcher) : _fromAny(matcher);
    // check that entities have all the obligatory components
    final entitiesFiltered = query.where((e) => matcher.matches(e)).toList();
    final newGroup = Group.create(entities: entitiesFiltered, matcher: matcher, manager: this);
    groups.addAll({matcher: newGroup}); // register the group
    return newGroup;
  }

  List<Entity> _fromAll(GroupMatcher matcher) {
    final set = components[matcher.all.first];
    return set?.sparse.entries.map<Entity>((entry) => entities[entry.key]).toList() ?? [];
  }

  List<Entity> _fromAny(GroupMatcher matcher) {
    final entitiesMutable = <Entity>[];
    for (final C in matcher.any) {
      final set = components[C];
      entitiesMutable.addAll(set?.sparse.entries.map<Entity>((entry) => entities[entry.key]) ?? []);
    }
    return entitiesMutable;
  }
}