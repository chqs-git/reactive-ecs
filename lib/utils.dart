import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/widget.dart';
import 'entity_manager.dart';

extension EntityManagerUtils on BuildContext {
  EntityManager get entityManager => EntityManagerProvider.of(this);
}