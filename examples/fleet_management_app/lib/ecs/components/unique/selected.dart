import 'package:reactive_ecs/reactive_ecs.dart';

/// A unique component that links an entity to another entity that is selected.
class Selected extends Relationship {
  final int index;
  // constructor
  Selected({required this.index});

}