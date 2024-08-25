import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_ecs/entity_manager.dart';
import 'package:reactive_ecs/group.dart';
import 'package:reactive_ecs/utils/group_utils.dart';

import 'components.dart';

void main() {
  test('Create entities', (){
    EntityManager em = EntityManager();
    var e1 = em.createEntity()
      ..add(ShoppingItem('Eggs'))
      ..add(Price(1.2));
    var e2 = em.createEntity();
    e2 += ShoppingItem("Avocado");
    e2 += Price(2.5);

    expect(em.entities.sparse.length, 2);
    expect(em.entities.dense.contains(e1), true);
    expect(em.entities.dense.contains(e2), true);

    e1.destroy();

    expect(em.entities.sparse.length, 1);
    expect(em.entities.dense.contains(e1), false);
    expect(em.entities.dense.contains(e2), true);

    expect(e2.getOrNull<ShoppingItem>()?.id, "Avocado");

    e2 += ShoppingItem("Barbecue Kit");
    expect(e2.getOrNull<ShoppingItem>()?.id, "Barbecue Kit");

    expect(e1.isAlive, false);
    expect(e2.isAlive, true);
  });

  test('Unique component as service', () {
    EntityManager em = EntityManager();
    var e1 = em.createEntity()
      ..add(ShoppingItem('Eggs'))
      ..add(Price(1.2))
      ..add(Sale(50));
    var e2 = em.createEntity()
      ..add(ShoppingItem('Avocado'))
      ..add(Price(2.5));


    expect(em.getUniqueEntityOrNull<ShopService>(), null);

    var service = em.createEntity()
      ..add(ShopService());

    expect(em.getUniqueEntity<ShopService>(), service);
    expect(em.getUnique<ShopService>().buyItem(e1), 0.6);
    expect(em.getUnique<ShopService>().buyItem(e2), 2.5);
    expect(em.getUnique<ShopService>().buyItem(em.createEntity()), null);

    // creating 2 entities with the same unique component will result in an assertion error
    expect(() => em.createEntity().add(ShopService()), throwsAssertionError);
  });

  test('update entities and check for changes in the group', () {
    EntityManager em = EntityManager();
    var e1 = em.createEntity()
      ..add(ShoppingItem('Eggs'))
      ..add(Price(1.2))
      ..add(Sale(50));
    var e2 = em.createEntity()
      ..add(ShoppingItem('Avocado'))
      ..add(Price(2.5));
    var e3 = em.createEntity()
      ..add(ShoppingItem('Barbecue Kit'))
      ..add(Price(20.0))
      ..add(Sale(10));

    // create group
    var group = em.group(GroupMatcher(all: [ShoppingItem, Price]));

    expect(group.length, 3);
    expect(group.contains(e1), true);
    expect(group.contains(e2), true);
    expect(group.contains(e3), true);

    // remove components from entities, making these entities not part of the group

    e1.remove<Price>();
    expect(group.length, 2);
    expect(group.contains(e1), false);
    expect(group.contains(e2), true);
    expect(group.contains(e3), true);

    e2.remove<ShoppingItem>();
    expect(group.length, 1);
    expect(group.contains(e1), false);
    expect(group.contains(e2), false);
    expect(group.contains(e3), true);

    e3.remove<Price>();
    expect(group.length, 0);
    expect(group.contains(e1), false);
    expect(group.contains(e2), false);
    expect(group.contains(e3), false);

    // add entity to group
    final e4 = em.createEntity()
      ..add(ShoppingItem('Bread'))
      ..add(Price(1.0));

    expect(group.length, 1);
    expect(group.contains(e1), false);
    expect(group.contains(e2), false);
    expect(group.contains(e3), false);
    expect(group.contains(e4), true);
  });

  test('listen for updates in group', () {
    EntityManager em = EntityManager();
    var e1 = em.createEntity()
      ..add(ShoppingItem('Eggs'))
      ..add(Price(1.2))
      ..add(Sale(50));
    var e2 = em.createEntity()
      ..add(ShoppingItem('Avocado'))
      ..add(Price(2.5));

    // create group
    var group = em.group(GroupMatcher(all: [ShoppingItem, Price], relevant: [Sale]));

    expect(group.length, 2);
    int numOfChanges = 0;
    group.subscribe((event, entity) { numOfChanges++; }); // listen for changes and update numOfChanges

    e2 + Sale(50); // add 50 % safe

    expect(numOfChanges, 1);

    e2.destroy();

    expect(numOfChanges, 4); // 3 updates: removing sale, removing price, removing shopping item

    final bread = em.createEntity()
      ..add(ShoppingItem('Bread'))
      ..add(Price(1.0));

    expect(numOfChanges, 5);

    bread + Price(1.2);

    expect(numOfChanges, 6);
  });
}