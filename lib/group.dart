

import 'state.dart';

class Group {
  final List<Entity> entities;
  // constructor
  Group({required this.entities});
}

class GroupMatcher {
  final List<Type> all;
  final List<Type> any;
  final List<Type> none;
  // constructor
  GroupMatcher({this.all = const [], this.any = const [], this.none = const []});

  bool matches(Entity e) {
    for (final C in all) {
      if (!e.hasType(C)) return false;
    }
    for (final C in any) {
      if (e.hasType(C)) return true;
    }
    for (final C in none) {
      if (e.hasType(C)) return false;
    }
    return true;
  }
}

class ComponentBitSet {
  int _bitset = 0;

  void set(int bit) {
    _bitset |= (1 << bit);
  }

  void clear(int bit) {
    _bitset &= ~(1 << bit);
  }

  bool isSet(int bit) {
    return (_bitset & (1 << bit)) != 0;
  }
}
