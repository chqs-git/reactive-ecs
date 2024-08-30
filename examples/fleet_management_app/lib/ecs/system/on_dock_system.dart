
import 'dart:math';

import 'package:fleet_management_app/ecs/components/cargo.dart';
import 'package:fleet_management_app/ecs/components/cargo_of.dart';
import 'package:fleet_management_app/ecs/components/delivery_history.dart';
import 'package:fleet_management_app/ecs/components/fuel.dart';
import 'package:fleet_management_app/ecs/components/status.dart';
import 'package:reactive_ecs/system.dart';
import 'package:reactive_ecs/group.dart';
import 'package:reactive_ecs/reactive_ecs.dart';
import 'package:reactive_ecs/relationship.dart';
import 'package:reactive_ecs/state.dart';
import '../components/docked.dart';
import '../components/name.dart';
import '../components/route.dart';
import '../components/station.dart';
import '../components/vehicle.dart';

class OnDockSystem extends ReactiveSystem {
  @override
  GroupMatcher get matcher => GroupMatcher(all: [Vehicle], relevant: [DockedIn, DeliveryTo]);
  @override
  GroupEventType get event => GroupEventType.addOrUpdated;

  final random = Random();

  @override
  void execute(Entity entity, ChangeDetails details) {
    if (!entity.has<DockedIn>() || !entity.has<DeliveryTo>()) return;
    final delivery = entity.get<DeliveryTo>();
    final fuel = entity.get<Fuel>();
    entity + Status(state: StatusState.idle); // update status
    final cargos = entity.getAllEntitiesWithRelationship<CargoOf>();
    final name = entity.get<Name>();
    final (station, _) = entity.getRelationship<DockedIn>();
    final stationDetails = station.get<Station>();
    print('${name.name} docked in ${station.get<Name>().name}');

    // unload cargo
    entity
        ..removeRelationship<DeliveryTo>()
        ..add(
          (entity.getOrNull<DeliveryHistory>() ?? DeliveryHistory(deliveries: []))
              .addDelivery(DeliveryInfo(
                destiny: station.get<Name>().name,
                distance: distanceTo(delivery.start, delivery.end).toStringAsFixed(2),
                cargoQuantity: cargos.map((e) => e.get<Cargo>()).fold(0, (sum, cargo) => sum + cargo.amount))
          ),
        );
    for (final cargoEntity in cargos) {
      if (cargoEntity.get<Cargo>().type != stationDetails.producesType) {
        cargoEntity.addRelationship(CargoOf(), station);
      }
    }
    // load new cargo
    final newCargo = entityManager.createEntity()
      ..add(Cargo(type: stationDetails.producesType, amount: random.nextInt(15) + 15))
      ..addRelationship(CargoOf(), entity);
    // fuel if needed
    if (fuel.level < fuel.maxCapacity / 2) {
      entity + Status(state: StatusState.fueling); // update status
      Future.delayed(Duration(minutes: 1), () {
        entity
          ..add(Fuel(level: 100, maxCapacity: 100))
          ..add(Status(state: StatusState.idle)); // update fuel
      });
    } else if (random.nextDouble() < .5) { // 50 % chance to do another delivery on another station
      final stations = entityManager.group(GroupMatcher(all: [Station]));
      final newStation = stations.entities[(stations.entities.indexOf(station) + 1) % stations.entities.length];
      final delivery = DeliveryTo(start: entity.get<Vehicle>().position, end: newStation.get<Station>().position);
      entity
          ..removeRelationship<DockedIn>()
          ..add(Status(state: StatusState.transit))
          ..addRelationship(delivery, newStation);
    }
  }
}