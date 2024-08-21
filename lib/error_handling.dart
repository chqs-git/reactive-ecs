void assertRecs(bool condition, String message) {
  assert(condition, "RECS error: $message");
}

// error messages
String addOnDestroyed() => 'You cannot add a component to a destroyed entity.';
String uniqueNotFound(Type C) => 'Entity with unique Component: $C does not exist.';
String uniqueRestraint(Type C) =>
    'You cannot add a Unique Component ($C) because an entity with this Unique Component already exists.';
