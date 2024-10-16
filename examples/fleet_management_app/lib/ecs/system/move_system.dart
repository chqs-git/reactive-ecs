
import 'dart:math';

import 'package:fleet_management_app/ecs/components/docked.dart';
import 'package:fleet_management_app/ecs/components/fuel.dart';
import 'package:reactive_ecs/reactive_ecs.dart';
import '../components/route.dart';
import '../components/vehicle.dart';

class MoveSystem extends EntityManagerSystem implements ExecuteSystem {
  late final vehicles = entityManager.group(GroupMatcher(all: [Vehicle]));

  final speed = 1 / 25;

  @override
  void execute() {
    for (final vehicle in vehicles.entities) {
      if (!vehicle.has<DeliveryTo>() || vehicle.has<DockedIn>()) continue;
      final route = vehicle.get<DeliveryTo>();
      final position = vehicle.get<Vehicle>().position;
      final dir = position.normalize(route.end);
      // get rotation from dir
      final rotation = atan2(dir.y, dir.x) * (180 / pi); // Convert radians to degrees if needed
      vehicle + Vehicle(
          position: Position(x: position.x + dir.x * speed, y: position.y + dir.y * speed),
          rotation: rotation
      ); // update position
      vehicle + vehicle.get<Fuel>().addFuel(-.0025);
    }
  }

  @override
  void cleanup() {
    for (final vehicle in vehicles.entities) {
      if (!vehicle.has<DeliveryTo>() || vehicle.has<DockedIn>()) continue;

      final route = vehicle.get<DeliveryTo>();
      final (stationEntity, station) = vehicle.getRelationship<DeliveryTo>();
      final position = vehicle.get<Vehicle>().position;

      if (distanceTo(position, route.end) < 8) {
        vehicle.addRelationship(DockedIn(), stationEntity);
      }
    }
  }
}