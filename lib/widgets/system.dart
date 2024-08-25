import 'package:flutter/cupertino.dart';
import '../system.dart';

class BehaviourManager extends StatefulWidget {
  final Behaviour behaviour;
  final ReactiveBehaviour reactiveBehaviour;
  final Widget child;
  const BehaviourManager({super.key, required this.behaviour, required this.child, required this.reactiveBehaviour});

  @override
  State<StatefulWidget> createState() => BehaviourManagerState();
}

class BehaviourManagerState extends State<BehaviourManager> {
  @override
  void initState() {
    super.initState();
    widget.behaviour.init(setState: () => setState(() {}));
    widget.reactiveBehaviour.init();
  }

  @override
  void dispose() {
    widget.reactiveBehaviour.dispose();
    widget.behaviour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
