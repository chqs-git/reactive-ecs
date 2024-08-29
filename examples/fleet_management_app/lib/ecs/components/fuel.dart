
import 'package:reactive_ecs/state.dart';

class Fuel extends Component {
  final double maxCapacity;
  final double level;

  Fuel({required this.maxCapacity, required this.level});

  Fuel addFuel(double amount) {
    final newLevel = level + amount;
    return Fuel(maxCapacity: maxCapacity, level: newLevel > maxCapacity ? maxCapacity : newLevel);
  }
}