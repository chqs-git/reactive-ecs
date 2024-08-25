import 'dart:collection';
import 'package:reactive_ecs/error_handling.dart';
import 'package:reactive_ecs/maps.dart';
import 'data_structures/sparse_set.dart';
import 'group.dart';
import 'state.dart';

class EntityManager {
  int currentIndex = 0;
  final SparseSet<Entity> entities = SparseSet.create();
  // components
  final Map<Type, SparseSet<Component>> components = {};
  // groups
  final Map<GroupMatcher, Group> groups = {};
  final List<EntityMap> maps = [];
  final List<EntityMultiMap> multiMaps = [];

  Entity createEntity() {
    final e = Entity(index: currentIndex++, components: HashSet(), manager: this);
    entities.add(e.index, e);
    return e;
  }

  EntityMap<C, T> createMap<C extends Component, T>(KeyProducer<C, T> keyProducer) {
    final map = EntityMap(keyProducer: keyProducer, manager: this);

    // get entities with component C
    final relevantEntities = (components[C]?.sparse.keys.map((index) => entities.get(index)) ?? [])
      .nonNulls; // filter nulls
    for(final entity in relevantEntities) {
      entity.subscribe(map.subscribe);
      map.data[keyProducer(entity.get<C>())] = entity.index; // fill data
    }

    maps.add(map);
    return map;
  }
  
  EntityMultiMap<C, T> createMultiMap<C extends Component, T>(KeyProducer<C, T> keyProducer) {
    final map = EntityMultiMap(keyProducer: keyProducer, manager: this);

    // get entities with component C
    final relevantEntities = (components[C]?.sparse.keys.map((index) => entities.get(index)) ?? [])
      .nonNulls; // filter nulls
    for(final entity in relevantEntities) {
      entity.subscribe(map.subscribe);
      map.data[keyProducer(entity.get<C>())] = map.data[keyProducer(entity.get<C>())] ?? List.empty(growable: true);
      map.data[keyProducer(entity.get<C>())] = [...map.data[keyProducer(entity.get<C>())]!, entity.index];
    }

    multiMaps.add(map);
    return map;
  }

  /// Returns a unique entity with the given component or throws an exception if there is none.
  Entity getUniqueEntity<C extends UniqueComponent>() {
    final set = components[C];
    assertRecs(set != null && set.sparse.isNotEmpty, uniqueNotFound(C));
    return entities.get(set!.sparse.keys.first)!;
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
    return entities.get(set.sparse.keys.first);
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
    return (set?.sparse.entries.map<Entity?>((entry) => entities.get(entry.key)) ?? []).nonNulls.toList();
  }

  List<Entity> _fromAny(GroupMatcher matcher) {
    final entitiesMutable = <Entity>[];
    for (final C in matcher.any) {
      final set = components[C];
      entitiesMutable.addAll((set?.sparse.entries.map<Entity?>((entry) => entities.get(entry.key)) ?? []).nonNulls);
    }
    return entitiesMutable;
  }
}