
import 'dart:math';
import 'dart:ui';

import 'package:reactive_ecs/reactive_ecs.dart';
import 'package:reactive_ecs/relationship.dart';

class Position {
  final double x;
  final double y;
  // constructor
  Position({required this.x, required this.y});

  Position operator +(Position other) => Position(x: x + other.x, y: y + other.y);
  Position addOffset(Offset other) => Position(x: x + other.dx, y: y + other.dy);
  Position normalize(Position b) {
    final distance = distanceTo(this, b);
    return Position(x: (b.x - x) / distance, y: (b.y - y) / distance);
  }
}

double distanceTo(Position a, Position b) {
  return sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
}

class DeliveryTo extends Relationship {
  final Position start;
  final Position end;
  // constructor
  DeliveryTo({required this.start, required this.end});
}