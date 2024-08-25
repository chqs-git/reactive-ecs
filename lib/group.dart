import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/behaviour.dart';
import 'package:reactive_ecs/data_structures/sparse_set.dart';
import 'package:reactive_ecs/entity_manager.dart';
import 'package:reactive_ecs/utils/group_utils.dart';
import 'notifiers.dart';
import 'state.dart';

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

  static create({required List<Entity> entities, required GroupMatcher matcher, required EntityManager manager}) {
    final group = Group(entities: entities, matcher: matcher, manager: manager);
    for (final entity in entities) {
      entity.subscribe(group.subscribeToEntity);
    }
    return group;
  }

  void addEntity(Entity e) {
    data.add(e.index, e); // add to group elements
    e.subscribe(subscribeToEntity); // subscribe to changes on new entity
  }

  void subscribeToEntity(Entity e, Component? prev, Component? next) {
    final isRelevant = matcher.contains(prev?.runtimeType ?? next.runtimeType);
    if (!isRelevant) return;
    if (matcher.matches(e)) {
      data.update(e.index, e); // update entity
      if (prev == null) {
        added(this, e);
      } else if (next == null) {
        removed(this, e);
      } else {
        updated(this, e);
      }
    } else { // else remove: entity no longer belongs to group
      removed(this, e);
      data.delete(e.index);
    }
  }

  void destroy() {
    // unsubscribe
    for(final entity in entities) {
      entity.unsubscribe(subscribeToEntity);
    }
    // empty memory
    data.sparse.clear();
    data.dense.clear();
    manager.groups.remove(matcher);
  }
}

class GroupMatcher {
  final List<Type> all;
  final List<Type> any;
  final List<Type> none;
  final List<Type> relevant;
  // constructor
  GroupMatcher({this.all = const [], this.any = const [], this.none = const [], this.relevant = const []});

  bool contains(Type C) {
    return all.contains(C) || any.contains(C) || none.contains(C) || relevant.contains(C);
  }

  bool matches(Entity e) => e.hasAll(all) && e.hasAny(any) && (none.isEmpty || !e.hasAny(none));
}