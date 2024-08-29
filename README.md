# Reactive Entity Component System (RECS)

RECS is a fast & lightweight Reactive Entity Component System pattern for Dart and Flutter, targeted at Widgets and
state management. This project is Open Source and is under the MIT License.

First of all, **what is the ECS paradigm**?
A Entity Component System is a pattern that **separates state from behaviour**. It is composed by 3 main parts:
// image here

## Todo List

1. Complex example; [X]
2. Match groups with relationships;
3. Add details (prev and next) info to reactive systems; [X]
4. Add systems to already existing behaviors; [X] (Not necessary actually)
5. Update entities when a change occurs in one of the entities that it depends on; [X] (Not necessary actually)
6. Tests; 
7. Documentation;
8. FAQ:
    - Inconsistent context;

## In-Development

- **Entities**;
- **Components**;
- **Unique Components**;
- **Systems**;
- **Groups**;
- **Listenable**;
- **Widgets**;
- **Maps**;
- **Relationships** (Beta - Cannot match groups with relationships);
- **Tests** (Incomplete);
- **Examples** (Incomplete);
- **Documentation & Comments** (Incomplete);
- **Web Inspector** (Future);
- **Query** (Future);

## Usage

To use this package, add `reactive-ecs` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```yaml
dependencies:
  reactive-ecs:
      git: https://github.com/chqs-git/reactive-ecs.git
```