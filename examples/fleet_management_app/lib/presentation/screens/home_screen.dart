import 'dart:ui' as UI;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

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
  UI.Image? ship;
  UI.Image? station;

  @override
  void initState() {
    super.initState();
    loadImage('assets/ship.png').then((image) {
      setState(() {
        ship = image;
      });
    });

    loadImage('assets/oil_rig.png').then((image) {
      setState(() {
        station = image;
      });
    });
  }

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
                                vehicleImage: ship,
                                stationImage: station,
                              ),
                              size: Size.infinite,
                              child: Container(),
                            ),
                          )
                  )
            ),
      );
}

Future<UI.Image> loadImage(String path) async {
  final data = await rootBundle.load(path);
  final Uint8List bytes = data.buffer.asUint8List();
  return await decodeImageFromList(bytes);
}