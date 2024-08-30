import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/entity_manager.dart';
import 'package:reactive_ecs/error_handling.dart';
import 'package:reactive_ecs/state.dart';

/// A [KeyProducer] is a function that produces a key from an [EntityAttribute].
typedef KeyProducer<Attribute extends EntityAttribute, T> = T Function(Attribute attribute);

/// An [EntityMap] is a map that maps a __unique key__ to an [EntityAttribute].
/// 
/// ```dart
/// // map places by their id
/// final mappedPlaces = manager.createMap((Place p) => p.id);
/// final place = mappedPlaces.get(´PLACE_ID_HERE´); // get place by id in O(1)
/// ```
class EntityMap<Attribute extends EntityAttribute, T> extends ChangeNotifier {
  final Map<T, int> data = {};
  final KeyProducer<Attribute, T> _keyProducer;
  final EntityManager _manager;
  // constructor
  EntityMap({required T Function(Attribute) keyProducer, required EntityManager manager}) 
      : _keyProducer = keyProducer, _manager = manager;

  /// Check if the [Attribute] is of the same type as the [Type] provided.
  bool isType(Type type) => Attribute == type;

  /// Subscribe to changes in the [EntityMap].
  void subscribe(Entity e, EntityAttribute? prev, EntityAttribute? next) {
    if (next is! Attribute? || prev is! Attribute?) return;
    // update key producer
    if (prev != null) data.remove(_keyProducer(prev as Attribute));
    if (next != null) {
      final oldIndex = data[_keyProducer(next)];
      assertRecs(oldIndex == null || oldIndex == e.index, mappedRestraint(Attribute));
      data[_keyProducer(next)] = e.index;
    }
    notifyListeners(); // notify changes to map
  }

  /// Get the [Entity] with the given key.
  /// 
  /// __Null Safety__: Returns `null` if the key is not found.
  Entity? getEntity(T key) {
    final index = data[key];
    return index != null ? _manager.entities.get(index) : null;
  }

  /// Get the [Attribute] with the given key.
  /// 
  /// __Null Safety__: Returns `null` if the key is not found.
  Attribute? get(T key) => getEntity(key)?.getOrNull<Attribute>();
}

/// An [EntityMultiMap] is a map that maps a __key__ to a list of [EntityAttribute]s.
/// 
/// ```dart
/// // map places by their type
/// final mappedPlaces = manager.createMultiMap((Place p) => p.category);
/// final places = mappedPlaces.get(´PLACE_TYPE_HERE´); // get all places with category in O(1)
/// ```
class EntityMultiMap<Attribute extends EntityAttribute, T> extends ChangeNotifier {
  final Map<T, List<int>> data = {};
  final KeyProducer<Attribute, T> _keyProducer;
  final EntityManager _manager;
  // constructor
  EntityMultiMap({required T Function(Attribute) keyProducer, required EntityManager manager})
      : _keyProducer = keyProducer, _manager = manager;
  
  /// Check if the [Attribute] is of the same type as the [Type] provided.
  bool isType(Type type) => Attribute == type;
  
  /// Subscribe to changes in the [EntityMultiMap].
  void subscribe(Entity e, EntityAttribute? prev, EntityAttribute? next) {
    if (next is! Attribute? || prev is! Attribute?) return;
    // update key producer
    if (prev != null) {
      final key = _keyProducer(prev as Attribute);
      data[key] = data[key] ?? List.empty();
      data[key]!.remove(e.index);
    }
    if (next != null) {
      final key = _keyProducer(next);
      data[key] = data[key] ?? List.empty();
      data[key] = [...data[key]!, e.index];
    }
    notifyListeners(); // notify changes to map
  }

  /// Get the [Entity]s with the given key.
  List<Entity> getEntities(T key) {
    final index = data[key] ?? List.empty();
    return index
        .map((id) => _manager.entities.get(id))
        .whereType<Entity>()
        .toList();
  }

  /// Get the [Attribute]s with the given key.
  List<Attribute> get(T key) => getEntities(key).map((e) => e.get<Attribute>()).toList();
}