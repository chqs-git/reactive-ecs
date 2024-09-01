
import 'dart:math';

import 'package:fleet_management_app/ecs/components/cargo.dart';
import 'package:fleet_management_app/ecs/components/cargo_of.dart';
import 'package:fleet_management_app/ecs/components/delivery_history.dart';
import 'package:fleet_management_app/ecs/components/docked.dart';
import 'package:fleet_management_app/ecs/components/fuel.dart';
import 'package:fleet_management_app/ecs/components/name.dart';
import 'package:fleet_management_app/ecs/components/route.dart';
import 'package:fleet_management_app/ecs/components/status.dart';
import 'package:fleet_management_app/ecs/components/unique/camera.dart';
import 'package:fleet_management_app/ecs/components/unique/selected.dart';
import 'package:fleet_management_app/ecs/components/vehicle.dart';
import 'package:fleet_management_app/presentation/elements/fuel_view.dart';
import 'package:flutter/material.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

import '../../ecs/components/assigned_to.dart';
import '../../ecs/components/station.dart';
import '../../ecs/components/unique/self.dart';

class ManagerInterface extends StatefulWidget {
  const ManagerInterface({super.key});

  @override
  State<StatefulWidget> createState() => ManagerInterfaceState();

}

class ManagerInterfaceState extends State<ManagerInterface> {
  late final Group actors = context.entityManager.group(GroupMatcher(any: [Vehicle, Station]));

  @override
  Widget build(BuildContext context) => Container(
      height: 300,
      decoration: BoxDecoration(
          color: Colors.white70
      ),
      child: EntityObservingWidget(
          provider: (em) => em.getUniqueEntity<Self>(),
          builder: (_, self, __) => !self.has<Selected>()
              ? CircularProgressIndicator()
              : EntityObservingWidget(
                provider: (em) => self.getRelationship<Selected>().$1,
                builder: (context, selected, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            final newIndex = self.get<Selected>().index - 1; // always within array bounds
                            final entity = actors.entities[newIndex.abs() % (actors.entities.length)];
                            self + Camera(position: entity.has<Vehicle>() ? entity.get<Vehicle>().position : entity.get<Station>().position);
                            self.addRelationship(Selected(index: newIndex), entity);
                            setState(() {});
                          }
                      ),
                      IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            final newIndex = self.get<Selected>().index + 1; // always within array bounds
                            final entity = actors.entities[newIndex.abs() % (actors.entities.length)];
                            self + Camera(position: entity.has<Vehicle>() ? entity.get<Vehicle>().position : entity.get<Station>().position);
                            self.addRelationship(Selected(index: newIndex), entity);
                            setState(() {});
                          }
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                              selected.has<Vehicle>() ? "assets/cargo_icon.png" : "assets/oil_rig_icon.png",
                              width: 150,
                          ),
                          if (selected.has<Fuel>()) Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Fuel: ', style: TextStyle(color: Colors.blueGrey, fontSize: 14, fontWeight: FontWeight.bold),),
                              FuelView(fuel: selected.get<Fuel>())
                            ],
                          )
                        ],
                      ),
                      SizedBox(width: 25,),
                      Column(
                        children: [
                          Row(children: [
                            Text(selected.get<Name>().name, style: TextStyle(color: Colors.blueGrey, fontSize: 22, fontWeight: FontWeight.bold),),
                            SizedBox(width: 10),
                            status(selected.has<Status>() ? selected.get<Status>().state : StatusState.idle)
                          ],),
                          Row(
                            children: [
                              stat(Icon(Icons.people, color: Colors.blueGrey), selected.getAllEntitiesWithRelationship<AssignedTo>().length),
                              stat(Icon(Icons.inventory, color: Colors.blueGrey), selected.getAllEntitiesWithRelationship<CargoOf>().map((e) => e.$1.get<Cargo>())
                                  .fold(0, (sum, cargo) => sum + cargo.amount)
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  if (selected.has<Vehicle>()) deliveries(selected)
                ],
              ),
            )
      )
  );

  Widget stat(Icon icon, int value) => Column(
    children: [
      icon,
      Text(value.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
    ],
  );

  Widget status(StatusState state) => Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: state == StatusState.idle ? Colors.green : state == StatusState.transit ? Colors.yellowAccent : Colors.red,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(state.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
    ),
  );

  Widget deliveries(Entity selected) =>
      Flexible(
        child: Column(
            children: [
              Expanded(
                  child: ListView(
                    children: [
                      if (selected.has<DeliveryTo>()) Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Delivering to ${selected.getRelationship<DeliveryTo>().$1.get<Name>().name}',
                                      style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${distanceTo(selected.get<Vehicle>().position, selected.get<DeliveryTo>().end).toStringAsFixed(2)} units away',
                                      style: TextStyle(color: Colors.white54, fontSize: 16),
                                    )
                                  ],
                                )
                            ),
                          )
                        ],
                      ),
                      if (!selected.has<DeliveryTo>() && selected.get<Status>().state == StatusState.idle) Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)
                                )
                            ),
                            onPressed: () {
                              final stations = context.entityManager.group(GroupMatcher(all: [Station]));
                              final station = stations.entities[Random().nextInt(stations.length)];
                              final delivery = DeliveryTo(start: selected.get<Vehicle>().position, end: station.get<Station>().position);
                              print('Vehicle ${selected.get<Name>().name} assigned to deliver to ${station.get<Name>().name}');
                              selected
                                  ..removeRelationship<DockedIn>()
                                  ..add(Status(state: StatusState.transit))
                                  ..addRelationship(delivery, station);
                            },
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Assign New Delivery',
                                      style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                            ),
                          )
                        ],
                      ),
                      if (selected.has<DeliveryHistory>()) ...selected.get<DeliveryHistory>().deliveries.map((delivery) => deliveryInfo(delivery))
                    ],
                  )
              )
            ]
        )
      );

  Widget deliveryInfo(DeliveryInfo delivery) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blueGrey.shade700,
              borderRadius: BorderRadius.circular(5)
          ),
          child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(
                    'Delivered to ${delivery.destiny}',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        'Distance: ${delivery.distance} units',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      Text(
                        'Cargo: ${delivery.cargoQuantity} units',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      )
                    ],
                  )
                ],
              )
          ),
        )
      )
    ],
  );
}