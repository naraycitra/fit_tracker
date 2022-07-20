class FirestorePath {
  static String workout(String uid, String workoutId) =>
      'users/$uid/workouts/$workoutId';
  static String workouts(String uid) => 'users/$uid/workouts';
  static String entry(String uid, String entryId) =>
      'users/$uid/entries/$entryId';
  static String entries(String uid) => 'users/$uid/entries';
}
