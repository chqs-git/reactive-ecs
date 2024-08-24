
import '../group.dart';
import '../state.dart';

extension GroupUtils on Group {
  int get length => entities.length;
  bool get isEmpty => entities.isEmpty;
  bool get isNotEmpty => entities.isNotEmpty;

  void forEach(void Function(Entity entity) f) {
    for (final entity in entities) {
      f(entity);
    }
  }

  List<Entity> get entities => data.dense;

  bool contains(Entity entity) => data.sparse.containsKey(entity.index);
}