
import 'package:fleet_management_app/ecs/components/cargo.dart';
import 'package:fleet_management_app/ecs/components/route.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

class Station extends Component {
  final Position position;
  final CargoType producesType;
  // constructor
  Station({required this.position, required this.producesType});
}