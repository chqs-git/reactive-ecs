import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_ecs/reactive_ecs.dart';
import 'package:reactive_ecs/relationship.dart';

class Place extends Component {
  final String name;
  Place({required this.name});
}

class Rating extends Component {
  final double rating;
  final int numberOfRatings;
  Rating({required this.rating, required this.numberOfRatings});
}

class RatingOfPlace extends Relationship {
  final int rating;
  final String comment;
  RatingOfPlace({required this.rating, required this.comment});
}

class Owner extends Relationship {}

void main() {
  test('Add Relationship between place ratings and user ratings', () {
    final em = EntityManager();
    final place = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));

    final rating = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Great place"), place);

    expect(rating.has<RatingOfPlace>(), true);
    expect(rating.has<Owner>(), false);
    expect(rating.get<RatingOfPlace>().rating, 5);
    expect(rating.getRelationship<RatingOfPlace>().$1.get<Rating>().numberOfRatings, 229);
  });

  test('One-to-Many Relationships', () {
    final em = EntityManager();
    final place = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));

    final rating_1 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Loved the food and everyone was nice"), place);

    final rating_2 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 3, comment: "Food took too long"), place);

    final rating_3 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 4, comment: "Great location and prices"), place);

    expect(place.getOrNull<RatingOfPlace>(), null);
    expect(rating_1.getRelationship<RatingOfPlace>().$1.get<Place>().name, rating_3.getRelationship<RatingOfPlace>().$1.get<Place>().name);
    expect(rating_2.get<RatingOfPlace>().rating, 3);

    // get all entities that have a relationship to => [place]
    final userRatings = place.getAllEntitiesWithRelationship<RatingOfPlace>();
    expect(userRatings.length, 3);
    expect(userRatings[0].get<RatingOfPlace>().rating, 5);
  });

  test('listen to changes in group of entities with relationships', () {
    final em = EntityManager();
    final place = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));

    final rating_1 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Loved the food and everyone was nice"), place);

    final rating_2 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 3, comment: "Food took too long"), place);

    final group = em.group(GroupMatcher(all: [RatingOfPlace]));
    expect(group.length, 2);
    expect(group.entities[0].get<RatingOfPlace>().rating, 5);

    final rating_3 = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 4, comment: "Great location and prices"), place);

    expect(group.length, 3);
    expect(group.entities[2].get<RatingOfPlace>().rating, 4);
  });

  test('Invalid getRelationship operation on entity that does not contain desired relationship', () {
    final em = EntityManager();
    final place = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));

    expect(() => place.getRelationship<RatingOfPlace>(), throwsAssertionError);
  });

  test('Invalid addRelationship operation on destroyed entity', () {
    final em = EntityManager();
    final place = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));

    final rating = em.createEntity();

    rating.destroy();

    expect(() => rating.addRelationship(RatingOfPlace(rating: 5, comment: ''), place), throwsAssertionError);
  });

  test('Update relationship value on entity with add', () {
    final em = EntityManager();
    final place1 = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));
    final place2 = em.createEntity()
      ..add(Place(name: "Disney World"))
      ..add(Rating(rating: 4.0, numberOfRatings: 1229));

    final rating = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Great place"), place1);

    expect(rating.getRelationship<RatingOfPlace>().$1.get<Place>().name, "Water Park Gerês");
    expect(rating.get<RatingOfPlace>().rating, 5);

    rating.addRelationship(RatingOfPlace(rating: 3, comment: "Too expensive"), place2);

    expect(rating.getRelationship<RatingOfPlace>().$1.get<Place>().name, "Disney World");
    expect(rating.get<RatingOfPlace>().rating, 3);
  });
}