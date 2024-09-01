

import 'package:reactive_ecs/reactive_ecs.dart';

enum Role {
  driver,
  passenger,
  mechanic,
}

/// This relationship can be placed on other entities to represent that they
/// are assigned to a boat or a station as the given [Role].
///
/// Say we have a boat and a person entity:
/// ```dart
/// final boat = ...; // entity
/// final person = ...; // entity
/// // person == AssignedTo(Role.driver) ==> boat
/// person.addRelationship(AssignedTo(role: Role.driver), boat);
/// ```
class AssignedTo extends Relationship {
  final Role role;
  // constructor
  AssignedTo({required this.role});
}