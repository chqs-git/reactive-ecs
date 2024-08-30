# Reactive Entity Component System (RECS)

RECS is a fast & lightweight Reactive Entity Component System pattern for Dart and Flutter, targeted at Widgets and
state management. This project is Open Source and is under the MIT License.

First of all, **what is the ECS paradigm**?

A Entity Component System is a pattern that **separates state from behaviour**. It is composed by 3 main parts:
- Entities: A unique identifier that groups components (and relationships);
- Components: Data that represents the state of an entity;
- Systems: Logic that operates on entities with specific components;

## Usage

To use this package, add `reactive-ecs` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```yaml
dependencies:
  reactive-ecs:
      git: https://github.com/chqs-git/reactive-ecs.git
```

#### Code Example

```dart
final max = entityManager.createEntity()
    ..add(Self())
    ..add(Name(value: "Max"))
    ..add(PersonalDetails(hobby: 'Drawing', favoriteColor: Colors.green))
    ..addRelationship(ChildOf(order: 0), parentEntity)
    ..addRelationship(EmployeeOf(position: JobPosition.programmer), jobEntity);

@override
Widget build(BuildContext context) => EntityObservingWidget(
    provider: (em) => em.getUniqueComponent<Self>(),
    builder: (context, entity, _) => Column(
        children: [
            Text(entity.get<Name>().value),
            Row(
                children: [
                    Text(entity.get<PersonalDetails>().hobby),
                    Color(entity.get<PersonalDetails>().favoriteColor),
                ]
            ),
            Text('Parent: ${entity.getRelationship<ChildOf>().$1.get<Name>().value}')
        ]
    )
);
```

## Features

- **Entities, components & systems**;
- **Unique Components**;
- **Groups**;
- **Listenable**;
- **Widgets**;
- **Maps**;
- **Relationships**;
- **Web Inspector** (Future);

## Support

For contact information use: franciscobarreiras.fb@gmail.com.

To Support:
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Y8Y312MBRY)

## Acknowledgements
> Other works that inspired and contributed to this package. (thank you)
- [entitas_ff](https://github.com/mzaks/entitas_ff)
- [flecs](https://github.com/SanderMertens/flecs)
- [seecs](https://github.com/chrischristakis/seecs)
