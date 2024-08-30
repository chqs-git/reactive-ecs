import 'package:reactive_ecs/state.dart';

class ShoppingItem extends Component {
  final String id;

  ShoppingItem(this.id);
}

class Price extends Component {
  final double value;

  Price(this.value);
}

class Category extends Component {
  final String name;
  // constructor
  Category(this.name);
}

class Sale extends Component {
  final double discount; // %

  Sale(this.discount);
}

class ShopService extends UniqueComponent {
  double? buyItem(Entity entity) {
    if (!entity.hasAll([ShoppingItem, Price])) return null;

    final _ = entity.get<ShoppingItem>();
    final price = entity.get<Price>();
    final sale = entity.getOrNull<Sale>();

    return sale != null ? price.value * (1 - sale.discount / 100) : price.value;
  }
}
