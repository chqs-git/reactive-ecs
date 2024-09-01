import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

void main() {
  test('add elements to set', () {
    final set = SparseSet.create<String>();
    set.add(0, 'hello');
    set.add(1, 'world');
    expect(set.get(0), 'hello');
    expect(set.get(1), 'world');
    expect(set.get(2), null);
  });

  test('add elements to existing set', () {
    final set = SparseSet<String>(sparse: {0: 0}, dense: ['hello']);
    set.add(1, 'world');
    expect(set.get(0), 'hello');
    expect(set.get(1), 'world');
    expect(set.get(2), null);
  });

  test('remove elements on empty set', () {
    final set = SparseSet.create<String>();
    set.delete(0);
    expect(set.get(0), null);
    expect(set.get(1), null);
    expect(set.get(2), null);
  });
  
  test('update elements on empty set', () {
    final set = SparseSet.create<String>();
    set.update(0, 'world');
    expect(set.get(0), null);
    expect(set.get(1), null);
    expect(set.get(2), null);
  });

  test('update elements on existing set', () {
    final set = SparseSet<String>(sparse: {0: 0}, dense: ['hello']);
    set.update(0, 'world');
    expect(set.get(0), 'world');
    expect(set.get(1), null);
    expect(set.get(2), null);
  });



  test('remove elements on existing set', () {
    final set = SparseSet<String>(sparse: {0: 0, 5: 1}, dense: ['hello', 'world']);
    set.delete(0);
    expect(set.get(0), null);
    expect(set.get(5), 'world');
    expect(set.get(2), null);
  });

  test('read elements from existing set', () {
    final set = SparseSet<String>(sparse: {0: 0, 5: 1}, dense: ['hello', 'world']);
    expect(set.get(0), 'hello');
    expect(set.get(5), 'world');
    expect(set.get(2), null);
  });
}