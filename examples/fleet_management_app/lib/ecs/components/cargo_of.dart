import 'package:reactive_ecs/reactive_ecs.dart';

/// This relationship can be placed on other entities to represent that they
/// are cargo of another entity.
///
/// Say we have a truck and box entity:
///
/// ```dart
/// final truck = ...; // entity
/// final box = ...; // entity
/// // box == CargoOf ==> Truck
/// box.addRelationship(CargoOf(), truck);
/// ```
///
class CargoOf extends Relationship {}