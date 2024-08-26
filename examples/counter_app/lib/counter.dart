import 'package:reactive_ecs/state.dart';

class Counter extends UniqueComponent {
  final int value;
  Counter(this.value);

  Counter increment() => Counter(value + 1);
}