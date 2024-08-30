import 'dart:math';
import 'package:fleet_management_app/ecs/components/assigned_to.dart';
import 'package:fleet_management_app/ecs/components/cargo.dart';
import 'package:fleet_management_app/ecs/components/cargo_of.dart';
import 'package:fleet_management_app/ecs/components/status.dart';
import 'package:fleet_management_app/ecs/components/vehicle.dart';
import 'package:reactive_ecs/system.dart';
import 'package:reactive_ecs/reactive_ecs.dart';
import 'package:reactive_ecs/relationship.dart';

import '../components/fuel.dart';
import '../components/name.dart';
import '../components/route.dart';
import '../components/station.dart';
import '../components/unique/camera.dart';
import '../components/unique/selected.dart';
import '../components/unique/self.dart';

class GenerateSystem extends EntityManagerSystem implements InitSystem {
  final int entityMultiplier;
  GenerateSystem({this.entityMultiplier = 1});

  final random = Random();
  @override
  void init(void Function() notifyWidgets) {
    // create stations
    final numStations = (random.nextInt(2) + 4) * entityMultiplier; // between 4 and 6
    print(numStations);
    final stations = <Entity>[];
    for (var i = 0; i < numStations; i++) {
      final station = entityManager.createEntity()
         ..add(Name(name: 'Station $i'))
         ..add(Station(
             position: Position(
              x: random.nextDouble() * 100, // value between 0 and 100
              y: random.nextDouble() * 100 // value between 0 and 100
            ),
            producesType: randomCargoType()
         ));

      final numOfPeople = (random.nextInt(8) + 4) * entityMultiplier; // between 4 and 12
      for (var p = 0; p < numOfPeople; p++) {
        final person = entityManager.createEntity()
          ..add(Name(name: 'Person $p'))
          ..addRelationship(AssignedTo(role: Role.mechanic), station);
      }
      stations.add(station);
    }

    // create vehicles
    final numVehicles = (random.nextInt(5) + 5) * entityMultiplier; // between 5 and 10
    for(var i = 0; i < numVehicles; i++) {
      final vehicle = entityManager.createEntity()
        ..add(Name(name: 'Vehicle $i'))
        ..add(Vehicle(
            position: Position(
              x: random.nextDouble() * 100, // value between 0 and 100
              y: random.nextDouble() * 100 // value between 0 and 100
            ),
            rotation: random.nextDouble() * 360 // value between 0 and 360
        ))
        ..add(Fuel(maxCapacity: 10, level: 10))
        ..add(Status(state: StatusState.idle));
      if (i == 0) {
        entityManager.getUniqueEntity<Self>()
            .addRelationship(Selected(index: 0), vehicle);
        entityManager.getUniqueEntity<Self>() + Camera(position: vehicle.get<Vehicle>().position);
      }

      giveDeliveryTask(vehicle, stations);

      for (var j = 0; j < 3; j++) {
        final cargo = entityManager.createEntity()
            ..add(Cargo(type: randomCargoType(), amount: (random.nextInt(22) + 5) * entityMultiplier)) // between 5 and 25
            ..addRelationship(CargoOf(), vehicle);
      }

      final numOfPeople = random.nextInt(12) + 8; // between 8 and 20
      for (var p = 0; p < numOfPeople; p++) {
        final person = entityManager.createEntity()
            ..add(Name(name: 'Person $p'))
            ..addRelationship(AssignedTo(role: p == 0 ? Role.driver : randomRole()), vehicle);
      }
    }
  }

  void giveDeliveryTask(Entity vehicle, List<Entity> stations) {
    final station = stations[random.nextInt(stations.length)];
    final delivery = DeliveryTo(start: vehicle.get<Vehicle>().position, end: station.get<Station>().position);
    print('Vehicle ${vehicle.get<Name>().name} assigned to deliver to ${station.get<Name>().name}');
    vehicle.addRelationship(delivery, station);
    vehicle + Status(state: StatusState.transit);
  }

  Role randomRole() => Role.values[random.nextInt(Role.values.length)];
  CargoType randomCargoType() => CargoType.values[random.nextInt(CargoType.values.length)];
}