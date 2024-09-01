void assertRecs(bool condition, String message) {
  assert(condition, "RECS error: $message");
}
// Improved error messages
String componentOrRelationshipIsNull(Type C) => 'Component or Relationship of type $C is not present in Entity.';
String addOnDestroyed() => 'Attempted to add a [EntityAttribute] to a destroyed entity.';
String uniqueNotFound(Type C) => 'No entity found with the unique component of type $C.';
String uniqueRestraint(Type C) =>
    'Cannot add a unique component of type $C because an entity with this component already exists.';
String mappedRestraint(Type C) =>
    'Cannot add a component of type $C with the given key because this key already exists in the map.';