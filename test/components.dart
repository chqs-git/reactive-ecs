import 'package:reactive_ecs/state.dart';

class ShoppingItem implements Component {
  final String id;

  ShoppingItem(this.id);
}

class Price implements Component {
  final double value;

  Price(this.value);
}

class Category implements Component {
  final String name;
  // constructor
  Category(this.name);
}

class Sale implements Component {
  final double discount; // %

  Sale(this.discount);
}

class ShopService implements UniqueComponent {
  double? buyItem(Entity entity) {
    if (!entity.hasAll([ShoppingItem, Price])) return null;

    final _ = entity.get<ShoppingItem>();
    final price = entity.get<Price>();
    final sale = entity.getOrNull<Sale>();

    return sale != null ? price.value * (1 - sale.discount / 100) : price.value;
  }
}
