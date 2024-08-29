
import 'package:fleet_management_app/ecs/components/route.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

class Camera extends UniqueComponent {
  final Position position;

  Camera({required this.position});
}