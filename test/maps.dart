
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_ecs/src/entity_manager.dart';
import 'package:reactive_ecs/src/relationship.dart';

import 'components.dart';
import 'relationships.dart';

void main() {
  test('Shopping item maps', () {
    final em = EntityManager();
    final e1 = em.createEntity()
      ..add(ShoppingItem('Eggs'))
      ..add(Price(1.2));

    // create map
    final map = em.createMap<ShoppingItem, String>((item) => item.id);

    final e2 = em.createEntity()..add(ShoppingItem('Avocado'))..add(Price(2.5));

    expect(map.getEntity("Eggs")?.getOrNull<Price>()?.value, 1.2);
    expect(map.getEntity("Avocado")?.getOrNull<Price>()?.value, 2.5);

    e2 + ShoppingItem("Barbecue Kit");

    expect(map.getEntity("Eggs") != null, true);
    expect(map.getEntity("Avocado"), null);
    expect(map.getEntity("Barbecue Kit")?.getOrNull<Price>()?.value, 2.5);
  });

  test('check destroyed entities have been removed from map', () {
    final em = EntityManager();
    final e1 = em.createEntity()
      ..add(ShoppingItem('Eggs'))
      ..add(Price(1.2));

    // create map
    final map = em.createMap<ShoppingItem, String>((item) => item.id);

    final e2 = em.createEntity()..add(ShoppingItem('Avocado'))..add(Price(2.5));

    expect(map.getEntity("Eggs")?.getOrNull<Price>()?.value, 1.2);
    expect(map.getEntity("Avocado")?.getOrNull<Price>()?.value, 2.5);

    e1.destroy();
    e2 + ShoppingItem("Barbecue Kit");

    expect(map.getEntity("Eggs"), null);
    expect(map.getEntity("Avocado"), null);
    expect(map.getEntity("Barbecue Kit")?.getOrNull<Price>()?.value, 2.5);
  });

  test('Conflict in adding component because it has the same key in EntityMap', () {
    final em = EntityManager();
    final e1 = em.createEntity()
      ..add(ShoppingItem('Eggs'))
      ..add(Price(1.2));

    // create map
    final map = em.createMap<ShoppingItem, String>((item) => item.id);

    final e2 = em.createEntity()..add(ShoppingItem('Avocado'))..add(Price(2.5));

    expect(map.getEntity("Eggs")?.getOrNull<Price>()?.value, 1.2);
    expect(map.getEntity("Avocado")?.getOrNull<Price>()?.value, 2.5);

    expect(() => e2 + ShoppingItem("Eggs"), throwsAssertionError);

    expect(map.getEntity("Eggs") != null, true);
  });

  test('Observe changes in maps', () {
    final em = EntityManager();
    final e1 = em.createEntity()
      ..add(ShoppingItem('Eggs'))
      ..add(Price(1.2));

    final map = em.createMap<ShoppingItem, String>((item) => item.id);

    final e2 = em.createEntity()..add(ShoppingItem('Avocado'))..add(Price(2.5));

    expect(map.getEntity("Eggs")?.getOrNull<Price>()?.value, 1.2);
    expect(map.getEntity("Avocado")?.getOrNull<Price>()?.value, 2.5);

    e1.add(Price(1.5));
    e2.add(Price(2.7));

    expect(map.getEntity("Eggs")?.getOrNull<Price>()?.value, 1.5);
    expect(map.getEntity("Avocado")?.getOrNull<Price>()?.value, 2.7);
  });

  test('Map Relationships', () {
    final em = EntityManager();
    final place = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));
    final e1 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Great place"), place);

    final map = em.createMap<RatingOfPlace, int>((item) => item.rating);

    expect(map.getEntity(5)?.getOrNull<RatingOfPlace>()?.rating, 5);
    expect(map.get(5)?.rating, 5);

    final e2 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 3, comment: "Food took too long"), place);

    expect(map.getEntity(3)?.getOrNull<RatingOfPlace>()?.rating, 3);
    expect(map.get(3)?.rating, 3);
  });

  test('Add and observe changes in Multimap', () {
    final em = EntityManager();
    final e1 = em.createEntity()
      ..add(ShoppingItem('Eggs'))
      ..add(Category('Food'))
      ..add(Price(1.2));

    final multiMap = em.createMultiMap<Category, String>((item) => item.name);

    final e2 = em.createEntity()
      ..add(ShoppingItem('Avocado'))
      ..add(Category('Food'))
      ..add(Price(2.5));

    expect(multiMap.getEntities("Food").length, 2);

    e1.destroy();

    expect(multiMap.getEntities("Food").length, 1);

    e2.add(Category('Fruit'));

    expect(multiMap.getEntities("Food").length, 0);
    expect(multiMap.getEntities("Fruit").length, 1);
  });

  test('Add and observe changes in Relationships Multi-mapped', () {
    final em = EntityManager();
    final place = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));
    final e1 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Great place"), place);


    final multiMap = em.createMultiMap<RatingOfPlace, int>((item) => item.rating);

    final e2 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Great Staff and Food, loved it!"), place);

    final e3 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Enjoyed."), place);

    expect(multiMap.getEntities(5).length, 3);

    e1.destroy();

    expect(multiMap.getEntities(5).length, 2);
    expect(multiMap.getEntities(0).length, 0);
  });
}