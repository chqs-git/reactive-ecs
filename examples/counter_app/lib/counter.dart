import 'package:reactive_ecs/reactive_ecs.dart';

class Counter extends UniqueComponent {
  final int value;
  Counter(this.value);

  Counter increment() => Counter(value + 1);
}