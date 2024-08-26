import 'package:flutter/material.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

import 'counter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: EntityManagerProvider(
          entityManager: EntityManager()
            ..createEntity().add(Counter(0)), // Add the Counter component to the entity
          systems: const [],
          child: const HomePage(title: 'Flutter Counter App')
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;
  const HomePage({super.key, required this.title});

  void incrementCounter(BuildContext context) {
    final entityManager = context.entityManager;
    final counter = entityManager.getUniqueEntity<Counter>();
    counter + counter.get<Counter>().increment(); // increment
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            EntityObservingWidget(
                provider: (em) => em.getUniqueEntity<Counter>(),
                builder: (context, entity, _) => Text(
                '${entity.get<Counter>().value}',
                style: Theme.of(context).textTheme.headlineMedium,
              )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => incrementCounter(context),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}