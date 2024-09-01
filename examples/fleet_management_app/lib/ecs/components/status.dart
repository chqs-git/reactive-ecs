import 'package:reactive_ecs/reactive_ecs.dart';

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