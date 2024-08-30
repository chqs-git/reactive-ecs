import 'dart:collection';
import 'package:reactive_ecs/error_handling.dart';
import 'package:reactive_ecs/maps.dart';
import 'data_structures/sparse_set.dart';
import 'group.dart';
import 'state.dart';

/// The EntityManager is the main class of the ECS system.
/// It is responsible for creating, storing and managing entities,
/// as well as maps and groups.
///
/// ```dart
/// final manager = EntityManager();
/// final entity = manager.createEntity();
/// entity.add(Position(x: 0, y: 0));
/// entity.add(Velocity(x: 1, y: 1));
/// // get all entities with Position and Velocity components
/// final group = manager.group(GroupMatcher(all: [Position, Velocity]));
/// ```
class EntityManager {
  int currentIndex = 0;
  final SparseSet<Entity> entities = SparseSet.create();
  // entity attributes
  final Map<Type, SparseSet<EntityAttribute>> attributes = {};
  // relationships
  final Map<int, int> relationships = {}; // (entity index ^ Relationship) => other entity index
  final Map<Type, SparseSet<List<int>>> relationshipReverse = {};
  // groups
  final Map<GroupMatcher, Group> groups = {};
  final List<EntityMap> maps = [];
  final List<EntityMultiMap> multiMaps = [];

  /// This method creates a new entity and adds it to the entity manager.
  Entity createEntity() {
    final e = Entity(index: currentIndex++, attributes: HashSet(), manager: this);
    entities.add(e.index, e);
    return e;
  }

  /// This method creates a [EntityMap] with the given [KeyProducer].
  ///
  /// Maps can be used to quickly access entities and components with a __unique key__. Keys
  /// will be generated by the given [KeyProducer].
  ///
  /// ```dart
  /// // map places by their id
  /// final mappedPlaces = manager.createMap((Place p) => p.id);
  /// final place = mappedPlaces.get(´PLACE_ID_HERE´); // get place by id in O(1)
  /// ```
  EntityMap<A, T> createMap<A extends EntityAttribute, T>(KeyProducer<A, T> keyProducer) {
    final map = EntityMap(keyProducer: keyProducer, manager: this);

    // get entities with EntityAttribute A
    final relevantEntities = (attributes[A]?.sparse.keys.map((index) => entities.get(index)) ?? [])
      .nonNulls; // filter nulls
    for(final entity in relevantEntities) {
      entity.subscribe(map.subscribe);
      map.data[keyProducer(entity.get<A>())] = entity.index; // fill data
    }

    maps.add(map);
    return map;
  }

  /// This method creates a [EntityMultiMap] with the given [KeyProducer].
  ///
  /// MultiMaps can be used to quickly access a list of entities and components
  /// with a __non-unique key__. Keys will be generated by the given [KeyProducer].
  ///
  /// ```dart
  /// // map places by their type
  /// final mappedPlaces = manager.createMultiMap((Place p) => p.category);
  /// final places = mappedPlaces.get(´PLACE_TYPE_HERE´); // get all places with category in O(1)
  /// ```
  EntityMultiMap<A, T> createMultiMap<A extends EntityAttribute, T>(KeyProducer<A, T> keyProducer) {
    final map = EntityMultiMap(keyProducer: keyProducer, manager: this);

    // get entities with EntityAttribute A
    final relevantEntities = (attributes[A]?.sparse.keys.map((index) => entities.get(index)) ?? [])
      .nonNulls; // filter nulls
    for(final entity in relevantEntities) {
      entity.subscribe(map.subscribe);
      map.data[keyProducer(entity.get<A>())] = map.data[keyProducer(entity.get<A>())] ?? List.empty(growable: true);
      map.data[keyProducer(entity.get<A>())] = [...map.data[keyProducer(entity.get<A>())]!, entity.index];
    }

    multiMaps.add(map);
    return map;
  }

  /// Retrieves the only [Entity] containing the specified [UniqueComponent].
  ///
  /// Throws an exception if no such entity exists.
  Entity getUniqueEntity<C extends UniqueComponent>() {
    final set = attributes[C];
    assertRecs(set != null && set.sparse.isNotEmpty, uniqueNotFound(C));
    return entities.get(set!.sparse.keys.first)!;
  }

  /// Retrieves the only [UniqueComponent] of the specified type.
  ///
  /// Throws an exception if no such component exists.
  C getUnique<C extends UniqueComponent>() {
    final set = attributes[C];
    assertRecs(set != null && set.dense.isNotEmpty, uniqueNotFound(C));
    return set!.dense.first as C;
  }

  /// Retrieves the only [Entity] containing the specified [UniqueComponent].
  ///
  /// __Null Safety__: Returns [null] if no such entity exists.
  Entity? getUniqueEntityOrNull<C extends UniqueComponent>() {
    final set = attributes[C];
    if (set == null || set.sparse.isEmpty) return null;
    return entities.get(set.sparse.keys.first);
  }

  /// Retrieves the only [UniqueComponent] of the specified type.
  ///
  /// __Null Safety__: Returns [null] if no such component exists.
  C? getUniqueOrNull<C extends UniqueComponent>() {
    final set = attributes[C];
    if (set == null || set.dense.isEmpty) return null;
    return set.dense.first as C;
  }

  /// Creates and returns a [Group] of all entities that match the specified [GroupMatcher].
  ///
  /// The [GroupMatcher] can be configured to match entities with specific components.
  ///
  /// Note: Groups are cached and will be reused if the same [GroupMatcher] is requested again.
  ///
  /// ```dart
  /// // get all entities with Position and Velocity components
  /// final group = manager.group(GroupMatcher(all: [Position, Velocity]));
  /// ```
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
    final type = matcher.all.first;
    final set = attributes[type];
    final entities = set?.sparse.entries.map<Entity?>((entry) => this.entities.get(entry.key));
      // (set?.dense as List<RelationshipPair>).map((RelationshipPair r) => this.entities.get(r.entityIndex));

    return (entities ?? [])
        .nonNulls
        .toList();
  }

  List<Entity> _fromAny(GroupMatcher matcher) {
    final entitiesMutable = <Entity>[];
    for (final C in matcher.any) {
      final set = attributes[C];
      final entities = set?.sparse.entries.map<Entity?>((entry) => this.entities.get(entry.key));
      // (set?.dense as List<RelationshipPair>).map((RelationshipPair r) => this.entities.get(r.entityIndex));
      entitiesMutable.addAll((entities ?? []).nonNulls);
    }
    return entitiesMutable;
  }
}