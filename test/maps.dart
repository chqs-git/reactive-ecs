
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_ecs/entity_manager.dart';

import 'components.dart';

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

    e1.destroy();
    e2 + ShoppingItem("Barbecue Kit");

    expect(map.getEntity("Eggs"), null);
    expect(map.getEntity("Avocado"), null);
    expect(map.getEntity("Barbecue Kit")?.getOrNull<Price>()?.value, 2.5);
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

  test('MultiMap', () {
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
}