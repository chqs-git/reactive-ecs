import 'package:flutter/cupertino.dart';
import 'package:reactive_ecs/entity_manager.dart';
import 'package:reactive_ecs/group.dart';
import 'package:reactive_ecs/state.dart';
import 'package:reactive_ecs/widgets/entity_manager_provider.dart';

class EntityObservingWidget extends StatelessWidget {
  final Entity Function(EntityManager em) provider;
  final Widget Function(BuildContext context, Entity entity, Widget? child) builder;
  final Widget? child;
  // constructor
  const EntityObservingWidget({super.key, required this.builder, required this.provider, this.child});

  @override
  Widget build(BuildContext context) {
    final em = context.entityManager;
    final entity = provider(context.entityManager);
    return ListenableBuilder(
      listenable: entity,
      builder: (context, childWidget) => builder(context, entity, childWidget),
      child: child,
    );
  }
}

class GroupObservingWidget extends StatefulWidget {
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