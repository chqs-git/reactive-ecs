
import 'package:fleet_management_app/ecs/components/fuel.dart';
import 'package:flutter/material.dart';

class FuelView extends StatelessWidget {
  final Fuel fuel;
  const FuelView({super.key, required this.fuel});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 80,
    height: 10,
    child: LinearProgressIndicator(
      value: fuel.level / fuel.maxCapacity,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
      backgroundColor: Colors.grey,
    )
  );
}