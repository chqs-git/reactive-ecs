
import 'package:reactive_ecs/reactive_ecs.dart';

enum CargoType {
  A,
  B,
  C
}

class Cargo extends Component {
  final CargoType type;
  final int amount;
  // constructor
  Cargo({required this.type, required this.amount});
}