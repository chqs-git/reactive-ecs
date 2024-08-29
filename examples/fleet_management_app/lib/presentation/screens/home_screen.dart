
import 'package:fleet_management_app/ecs/components/cargo_of.dart';
import 'package:fleet_management_app/ecs/components/unique/selected.dart';
import 'package:fleet_management_app/presentation/elements/manager_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reactive_ecs/reactive_ecs.dart';
import 'package:reactive_ecs/relationship.dart';

import '../../ecs/components/station.dart';
import '../../ecs/components/unique/camera.dart';
import '../../ecs/components/unique/self.dart';
import '../../ecs/components/vehicle.dart';
import '../canvas/world_canvas.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) =>
      GroupObservingWidget( // listen to updates to station
        matcher: GroupMatcher(all: [Station]),
        builder: (context, stations, _) =>
            GroupObservingWidget(
              matcher: GroupMatcher(all: [Vehicle]),  // listen to updates to vehicle
              builder: (context, vehicles, _) =>
                  EntityObservingWidget(
                      provider: (em) => em.getUniqueEntity<Self>(), // listen to updates to self
                      builder: (context, entity, _) =>
                          GestureDetector(
                            onPanUpdate: (details) {
                              final pos = entity.get<Camera>().position;
                              entity + Camera(position: pos.addOffset(-details.delta / WorldCanvas.boardSize));
                            },
                            child: CustomPaint(
                              painter: WorldCanvas(
                                camera: entity.get<Camera>(),
                                stations: stations.entities,
                                vehicles: vehicles.entities,
                              ),
                              size: Size.infinite,
                              child: Container(),
                            ),
                          )
                  )
            ),
      );
}