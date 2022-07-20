import 'dart:async';

import 'package:firestore_service/firestore_service.dart';
import 'package:fit_tracker/app/home/models/entry.dart';
import 'package:fit_tracker/app/home/models/workout.dart';
import 'package:fit_tracker/services/firestore_path.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  FirestoreDatabase({required this.uid});
  final String uid;

  final _service = FirestoreService.instance;

  Future<void> setWorkout(Workout workout) => _service.setData(
        path: FirestorePath.workout(uid, workout.id),
        data: workout.toMap(),
      );

  Future<void> deleteWorkout(Workout workout) async {
    // delete where entry.workoutId == workout.workoutId
    final allEntries = await entriesStream(workout: workout).first;
    for (final entry in allEntries) {
      if (entry.workoutId == workout.id) {
        await deleteEntry(entry);
      }
    }
    // delete workout
    await _service.deleteData(path: FirestorePath.workout(uid, workout.id));
  }

  Stream<Workout> workoutStream({required String workoutId}) =>
      _service.documentStream(
        path: FirestorePath.workout(uid, workoutId),
        builder: (data, documentId) => Workout.fromMap(data, documentId),
      );

  Stream<List<Workout>> workoutsStream() => _service.collectionStream(
        path: FirestorePath.workouts(uid),
        builder: (data, documentId) => Workout.fromMap(data, documentId),
      );

  Future<void> setEntry(Entry entry) => _service.setData(
        path: FirestorePath.entry(uid, entry.id),
        data: entry.toMap(),
      );

  Future<void> deleteEntry(Entry entry) =>
      _service.deleteData(path: FirestorePath.entry(uid, entry.id));

  Stream<List<Entry>> entriesStream({Workout? workout}) =>
      _service.collectionStream<Entry>(
        path: FirestorePath.entries(uid),
        queryBuilder: workout != null
            ? (query) => query.where('workoutId', isEqualTo: workout.id)
            : null,
        builder: (data, documentID) => Entry.fromMap(data, documentID),
        sort: (lhs, rhs) => rhs.start.compareTo(lhs.start),
      );
}
