import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/src/system.dart';
import 'package:reactive_ecs/src/entity_manager.dart';
import 'package:reactive_ecs/src/utils/group_utils.dart';
import 'data_structures/sparse_set.dart';
import 'notifiers.dart';
import 'state.dart';

/// The [Group] class is responsible for storing entities that match a given criteria.
///
/// Groups are [Listenable] and can be used to listen to changes in the group.
///
/// ```dart
/// final group = manager.group(GroupMatcher(all: [Position, Velocity]));
/// final numEntities = group.length;
/// final isEmpty = group.isEmpty;
/// group.forEach((entity) {
///  print(entity);
/// }
/// /// etc...
/// ```
class Group extends GroupNotifier {
  late final SparseSet<Entity> data;
  final GroupMatcher matcher;
  final EntityManager manager;
  // constructor
  Group({required List<Entity> entities, required this.matcher, required this.manager})
      : data = SparseSet(
      sparse: { for (int i = 0; i < entities.length; i++) entities[i].index : i },
      dense: entities
  );

  /// Do not use this constructor directly. Use [EntityManager.group] instead.
  ///
  /// This method is used internally to create a new group with the given entities, matcher and manager.
  static create({required List<Entity> entities, required GroupMatcher matcher, required EntityManager manager}) {
    final group = Group(entities: entities, matcher: matcher, manager: manager);
    for (final entity in entities) {
      entity.subscribe(group._subscribeToEntity);
    }
    return group;
  }

  /// This method adds a new [Entity] to the group.
  ///
  /// This method is used internally by the [EntityManager] to add entities to the group
  /// and is not recommended to use directly.
  void addEntity(Entity e) {
    data.add(e.index, e); // add to group elements
    e.subscribe(_subscribeToEntity); // subscribe to changes on new entity
  }

  /// This method cleans this group from memory.
  /// It does not remove the entities from the [EntityManager].
  void destroy() {
    // unsubscribe
    for(final entity in entities) {
      entity.unsubscribe(_subscribeToEntity);
    }
    // empty memory
    data.sparse.clear();
    data.dense.clear();
    manager.groups.remove(matcher);
  }

  void _subscribeToEntity(Entity e, EntityAttribute? prev, EntityAttribute? next) {
    final isRelevant = matcher.contains(prev?.runtimeType ?? next.runtimeType);
    if (!isRelevant) return;
    if (matcher.matches(e)) {
      data.update(e.index, e); // update entity
      if (prev == null) {
        added(this, e, ChangeDetails(prev: prev, next: next));
      } else if (next == null) {
        removed(this, e, ChangeDetails(prev: prev, next: next));
      } else {
        updated(this, e, ChangeDetails(prev: prev, next: next));
      }
    } else { // else remove: entity no longer belongs to group
      removed(this, e, ChangeDetails(prev: prev, next: next));
      data.delete(e.index);
    }
  }
}

/// The [GroupMatcher] class is responsible for matching entities with a given criteria.
///
///
/// [all]: list of [EntityAttributes] that the entity must have;
///
/// [any]: list of [EntityAttributes] that the entity need to have at least one;
///
/// [none]: list of [EntityAttributes] that the entity must not have;
///
/// [relevant]: list of [EntityAttributes] that should notify the group of changes.
class GroupMatcher {
  final List<Type> all;
  final List<Type> any;
  final List<Type> none;
  final List<Type> relevant;
  // constructor
  GroupMatcher({this.all = const [], this.any = const [], this.none = const [], this.relevant = const []});

  /// This method checks if the given [Type] is contained in the group.
  bool contains(Type C) {
    return all.contains(C) || any.contains(C) || none.contains(C) || relevant.contains(C);
  }

  /// This method checks if the given entity matches the criteria of this group.
  bool matches(Entity e) => e.hasAll(all) && e.hasAny(any) && (none.isEmpty || !e.hasAny(none));
}