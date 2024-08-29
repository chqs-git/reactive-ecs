import 'package:fleet_management_app/ecs/components/route.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

class Vehicle extends Component {
  final Position position;
  final double rotation;
  // constructor
  Vehicle({required this.position, required this.rotation});
}