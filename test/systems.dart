import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_ecs/reactive_ecs.dart';

class Place extends Component {
  final int index;
  final String name;
  Place({required this.index, required this.name});
}

class PlaceRating extends Component {
  final double rating;
  final int numberOfRatings;
  PlaceRating({required this.rating, required this.numberOfRatings});
}

class UserRating extends Component {
  final int placeIndex;
  final int rating;
  final String comment;
  UserRating({required this.rating, required this.placeIndex, required this.comment});
}

class Logger extends UniqueComponent {
  final List<String> log;
  Logger({required this.log});

  static void logMsg(Entity e, String msg) {
    final logger = e.get<Logger>();
    e + Logger(log: [...logger.log, msg]);
  }
}

class FetchPlaces extends EntityManagerSystem implements InitSystem {
  @override
  void init(void Function() notifyWidgets) async {
    /// "Fetch places"
    entityManager.createEntity() + Logger(log: ["Fetching Places..."]);
    entityManager.createEntity()
        ..add(Place(index: 0, name: "Water Park Gerês"))
        ..add(PlaceRating(rating: 4.0, numberOfRatings: 1));
    entityManager.createEntity()
        ..add(Place(index: 1, name: "Parque das Nações"))
        ..add(PlaceRating(rating: 4.6, numberOfRatings: 3));
    entityManager.createEntity()
        ..add(Place(index: 2, name: "Arco da Rua Augusta"))
        ..add(PlaceRating(rating: 4.7, numberOfRatings: 5));
  }
}

class RatingSystem extends ReactiveSystem {

  @override
  GroupMatcher get matcher => GroupMatcher(all: [UserRating]);

  @override
  GroupEventType get event => GroupEventType.added;

  @override
  void execute(Entity entity, ChangeDetails details) {
    final logger = entityManager.getUniqueEntity<Logger>();
    Logger.logMsg(logger, "->Entered Rating System");
    final rating = entity.get<UserRating>();
    final group = entityManager.group(GroupMatcher(all: [Place, PlaceRating]));
    final placeEntity = group.entities[rating.placeIndex];
    final placeRating = placeEntity.get<PlaceRating>();
    final newRating = PlaceRating(
        rating: (placeRating.rating * placeRating.numberOfRatings + rating.rating) / (placeRating.numberOfRatings + 1),
        numberOfRatings: placeRating.numberOfRatings + 1
    );

    placeEntity + newRating; // update place ratings...
    Logger.logMsg(logger, "->Exited Rating System");
  }
}

class PlaceLoggingSystem extends ReactiveSystem {
  @override
  GroupMatcher get matcher => GroupMatcher(all: [Place, PlaceRating]);

  @override
  GroupEventType get event => GroupEventType.addedOrUpdated;

  @override
  void execute(Entity entity, ChangeDetails details) {
    final logger = entityManager.getUniqueEntity<Logger>();
    Logger.logMsg(logger, "->Entered Place Logging System");
    final place = entity.get<Place>();
    final rating = entity.get<PlaceRating>();
    Logger.logMsg(logger, "Place: ${place.name} Rating: ${rating.rating}");
    Logger.logMsg(logger, "->Exited Place Logging System");
  }
}

void main() {
  test('fetch places at system initialization', () {
    final em = EntityManager();
    Behaviour behaviour = Behaviour(initSystems: [FetchPlaces()], entityManager: em); // create system
    behaviour.init();
    expect(em.entities.dense.length, 4); // 3 places and one logger entity
    expect(em.group(GroupMatcher(all: [Place, PlaceRating])).length, 3); // 3 places with ratings
  });
  
  test('automatic update of ratings by reactive system', () {
    final em = EntityManager();
    Behaviour behaviour = Behaviour(initSystems: [FetchPlaces()], entityManager: em); // create system
    behaviour.init();
    final group = em.group(GroupMatcher(all: [Place, PlaceRating]));
    expect(em.entities.dense.length, 4); // 3 places and one logger entity
    expect(group.length, 3); // 3 places with ratings
    
    final reactiveBehaviour = ReactiveBehaviour(systems: [RatingSystem()], entityManager: em);
    reactiveBehaviour.init();
    // create rating
    em.createEntity()
      .add(UserRating(placeIndex: 0, rating: 5, comment: "Great place!"));
    // check automatic updates
    expect(group.entities[0].get<PlaceRating>().numberOfRatings, 2);
    expect(group.entities[0].get<PlaceRating>().rating, 4.5);
  });
  
  test('check concurrency and cascade of reactive systems via logging component when it is not allowed', () {
    final em = EntityManager();
    Behaviour behaviour = Behaviour(initSystems: [FetchPlaces()], entityManager: em); // create system
    behaviour.init();

    final reactiveBehaviour = ReactiveBehaviour(systems: [RatingSystem(), PlaceLoggingSystem()], entityManager: em);
    reactiveBehaviour.init();
    // create rating
    em.createEntity()
        .add(UserRating(placeIndex: 0, rating: 5, comment: "Great place!"));
    
    final logger = em.getUnique<Logger>();
    expect(logger.log.length, 6);
    expect(logger.log[0], "Fetching Places...");
    expect(logger.log[1], "->Entered Rating System");
    expect(logger.log[2], "->Exited Rating System");
    expect(logger.log[3], "->Entered Place Logging System");
    expect(logger.log[4], "Place: Water Park Gerês Rating: 4.5");
    expect(logger.log[5], "->Exited Place Logging System");
  });

  test('check concurrency and cascade of reactive systems via logging component when it is allowed', () {
    final em = EntityManager();
    Behaviour behaviour = Behaviour(initSystems: [FetchPlaces()], entityManager: em); // create system
    behaviour.init();

    final reactiveBehaviour = ReactiveBehaviour(systems: [RatingSystem(), PlaceLoggingSystem()], allowConcurrentExecution: true, entityManager: em);
    reactiveBehaviour.init();
    // create rating
    em.createEntity()
        .add(UserRating(placeIndex: 0, rating: 5, comment: "Great place!"));

    final logger = em.getUnique<Logger>();
    expect(logger.log.length, 6);
    expect(logger.log[0], "Fetching Places...");
    expect(logger.log[1], "->Entered Rating System");
    expect(logger.log[2], "->Entered Place Logging System");
    expect(logger.log[3], "Place: Water Park Gerês Rating: 4.5");
    expect(logger.log[4], "->Exited Place Logging System");
    expect(logger.log[5], "->Exited Rating System");
  });
}