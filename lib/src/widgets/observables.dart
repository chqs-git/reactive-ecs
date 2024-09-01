import 'package:flutter/cupertino.dart';
import '../../reactive_ecs.dart';

/// Widget which observes an [Entity] instance and rebuilds when it changes.
///
/// The __child__ widget will not be rebuilt when changes occur.
/// The __onMissingEntity__ widget will be shown when the entity is not found.
class EntityObservingWidget extends StatelessWidget {
  final Entity? Function(EntityManager em) provider;
  final Widget Function(BuildContext context, Entity entity, Widget? child) builder;
  final Widget? child;
  final Widget onMissingEntity;
  // constructor
  const EntityObservingWidget({super.key, required this.builder, required this.provider, this.child, this.onMissingEntity = const SizedBox()});

  @override
  Widget build(BuildContext context) {
    final entity = provider(context.entityManager);
    return entity == null ? onMissingEntity : ListenableBuilder(
      listenable: entity,
      builder: (context, childWidget) => builder(context, entity, childWidget),
      child: child,
    );
  }
}

/// Widget which observes a [Group] instance and rebuilds when it changes.
///
/// The __child__ widget will not be rebuilt when changes occur.
class GroupObservingWidget extends StatefulWidget {
  /// The [GroupMatcher] describes the criteria for the group this system will react to.
  final GroupMatcher matcher;
  final Widget Function(BuildContext context, Group group, Widget? child) builder;
  final Widget? child;
  // constructor
  const GroupObservingWidget({super.key, required this.matcher, required this.builder, this.child});

  @override
  State<StatefulWidget> createState() => GroupObservingWidgetState();
}

class GroupObservingWidgetState extends State<GroupObservingWidget> {
  // get (or create) group from EntityManager once when widget is initialized
  late final Group group = context.entityManager.group(widget.matcher);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: group,
    builder: (context, childWidget) => widget.builder(context, group, childWidget),
    child: widget.child,
  );
}

typedef EntityMapBackedWidgetBuilder<A extends EntityAttribute, K> = Widget Function(EntityMultiMap<A, K> map, BuildContext context);
typedef EntityMapProvider<A extends EntityAttribute, K> = EntityMultiMap<A, K> Function(EntityManager entityManager);

class EntityMapObservingWidget<A extends EntityAttribute, K> extends StatefulWidget {
  final EntityMapProvider<A, K> provider;
  final EntityMapBackedWidgetBuilder<A, K> builder;

  const EntityMapObservingWidget({super.key, required this.provider, required this.builder});

  @override
  EntityMapObservingWidgetState<A, K> createState() => EntityMapObservingWidgetState();
}

class EntityMapObservingWidgetState<A extends EntityAttribute, K> extends State<EntityMapObservingWidget<A, K>>{
  late final EntityMultiMap<A, K> map = widget.provider(context.entityManager);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: map,
    builder: (context, childWidget) => widget.builder(map, context),
  );
}