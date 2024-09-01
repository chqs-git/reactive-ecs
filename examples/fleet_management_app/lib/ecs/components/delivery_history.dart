import 'package:reactive_ecs/reactive_ecs.dart';

class DeliveryInfo {
  final String destiny;
  final String distance;
  final int cargoQuantity;
  // constructor
  DeliveryInfo({required this.destiny, required this.distance, required this.cargoQuantity});}

class DeliveryHistory extends Component {
  final List<DeliveryInfo> deliveries;
  // constructor
  DeliveryHistory({required this.deliveries});

  DeliveryHistory addDelivery(DeliveryInfo delivery) => DeliveryHistory(deliveries: [...deliveries, delivery]);
}