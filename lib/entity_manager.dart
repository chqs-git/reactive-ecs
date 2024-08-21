import 'dart:collection';
import 'data_structures/sparse_set.dart';
import 'group.dart';
import 'state.dart';

class EntityManager {
  int currentIndex = 0;
  List<Entity> entities = [];
  // sparse sets of components
  final Map<Type, SparseSet<Component>> components = {};
  final Map<Type, int> uniqueComponents = {}; // TODO: implement unique components
  // groups
  final Map<GroupMatcher, Group> groups = {};

  Entity createEntity() {
    final e = Entity(index: currentIndex++, components: HashSet(), manager: this);
    entities = [...entities, e];
    return e;
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