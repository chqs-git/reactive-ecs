import 'package:reactive_ecs/relationship.dart';

/// A unique component that links an entity to another entity that is selected.
class Selected extends Relationship {
  final int index;
  // constructor
  Selected({required this.index});

}