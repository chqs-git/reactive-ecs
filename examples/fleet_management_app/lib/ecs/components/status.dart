
import 'package:reactive_ecs/state.dart';

enum StatusState {
  idle,
  transit,
  fueling
}

class Status extends Component {
  final StatusState state;
  // constructor
  Status({required this.state});
}