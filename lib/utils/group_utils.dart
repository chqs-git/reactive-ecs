
import '../group.dart';
import '../state.dart';

extension GroupUtils on Group {
  /// Get the length of the group.
  int get length => entities.length;

  /// Check if the group is empty.
  bool get isEmpty => entities.isEmpty;

  /// Check if the group is not empty.
  bool get isNotEmpty => entities.isNotEmpty;

  /// Execute a function for each entity in the group.
  void forEach(void Function(Entity entity) f) {
    for (final entity in entities) {
      f(entity);
    }
  }

  /// Get the entities in the group.
  List<Entity> get entities => data.dense;

  /// Check if the group contains the specified entity.
  bool contains(Entity entity) => data.sparse.containsKey(entity.index);
}