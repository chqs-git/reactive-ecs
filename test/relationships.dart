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

class User extends Component {}

class Owner extends Relationship {}

void main() {
  test('Add Relationship between place ratings and user ratings', () {
    final em = EntityManager();
    final place = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));

    final rating = em.createEntity()
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Great place"), place);

    expect(rating.hasRelationship<RatingOfPlace>(), true);
    expect(rating.hasRelationship<Owner>(), false);
    expect(rating.getRelationship<RatingOfPlace>().rating, 5);
    expect(rating.getRelationshipEntity<RatingOfPlace>().get<Rating>().numberOfRatings, 229);
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

    expect(place.getOrNullRelationshipEntity<RatingOfPlace>(), null);
    expect(rating_1.getRelationshipEntity<RatingOfPlace>().get<Place>().name, rating_3.getRelationshipEntity<RatingOfPlace>().get<Place>().name);
    expect(rating_2.getRelationship<RatingOfPlace>().rating, 3);

    // get all entities that have a relationship to => [place]
    final userRatings = place.getAllEntitiesWithRelationship<RatingOfPlace>();
    expect(userRatings.length, 3);
    expect(userRatings[0].getRelationship<RatingOfPlace>().rating, 5);
  });

  test('listen to changes in group of entities with relationships', () {
    final em = EntityManager();
    final place = em.createEntity()
      ..add(Place(name: "Water Park Gerês"))
      ..add(Rating(rating: 4.0, numberOfRatings: 229));

    final rating_1 = em.createEntity()
      ..add(User())
      ..addRelationship(RatingOfPlace(rating: 5, comment: "Loved the food and everyone was nice"), place);

    final rating_2 = em.createEntity()
      ..add(User())
      ..addRelationship(RatingOfPlace(rating: 3, comment: "Food took too long"), place);

    final group = em.group(GroupMatcher(all: [User]));
    expect(group.length, 2);
    expect(group.entities[0].getRelationship<RatingOfPlace>().rating, 5);

    final rating_3 = em.createEntity()
      ..add(User())
      ..addRelationship(RatingOfPlace(rating: 4, comment: "Great location and prices"), place);

    expect(group.length, 3);
    expect(group.entities[3].getRelationship<RatingOfPlace>().rating, 4);
  });
}