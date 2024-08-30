import 'package:fleet_management_app/ecs/system/on_dock_system.dart';
import 'package:fleet_management_app/presentation/elements/manager_interface.dart';
import 'package:fleet_management_app/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

import 'ecs/components/route.dart';
import 'ecs/components/unique/camera.dart';
import 'ecs/components/unique/self.dart';
import 'ecs/system/generate_system.dart';
import 'ecs/system/move_system.dart';

void main() {
  runApp(buildEcs());
}

Widget buildEcs() {
  final entityManager = EntityManager()
    ..createEntity()
        .add(Camera(position: Position(x: 50, y: 50)))
        .add(Self());

  return EntityManagerProvider(
    entityManager: entityManager,
    systems: [
      GenerateSystem(entityMultiplier: 1),
      MoveSystem(),
      OnDockSystem()
    ],
    child: const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fleet Management Demo App',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    home: Scaffold(
      appBar: AppBar(
        title: Text('Fleet Management Demo App'),
      ),
      body: HomeScreen(),
      bottomSheet: BottomSheet(
        clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          onClosing: () {},
          builder: (_) => ManagerInterface(),)
    ),
  );
}