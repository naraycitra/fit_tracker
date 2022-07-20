import 'package:rxdart/rxdart.dart';
import 'package:fit_tracker/app/home/entries/daily_workouts_details.dart';
import 'package:fit_tracker/app/home/entries/entries_list_tile.dart';
import 'package:fit_tracker/app/home/entries/entry_workout.dart';
import 'package:fit_tracker/app/home/workout_entries/format.dart';
import 'package:fit_tracker/app/home/models/entry.dart';
import 'package:fit_tracker/app/home/models/workout.dart';
import 'package:fit_tracker/services/firestore_database.dart';

class EntriesViewModel {
  EntriesViewModel({required this.database});
  final FirestoreDatabase database;

  /// combine List<Workout>, List<Entry> into List<EntryWorkout>
  Stream<List<EntryWorkout>> get _allEntriesStream =>
      CombineLatestStream.combine2(
        database.entriesStream(),
        database.workoutsStream(),
        _entriesWorkoutsCombiner,
      );

  static List<EntryWorkout> _entriesWorkoutsCombiner(
      List<Entry> entries, List<Workout> workouts) {
    return entries.map((entry) {
      final workout =
          workouts.firstWhere((workout) => workout.id == entry.workoutId);
      return EntryWorkout(entry, workout);
    }).toList();
  }

  /// Output stream
  Stream<List<EntriesListTileModel>> get entriesTileModelStream =>
      _allEntriesStream.map(_createModels);

  static List<EntriesListTileModel> _createModels(
      List<EntryWorkout> allEntries) {
    if (allEntries.isEmpty) {
      return [];
    }
    final allDailyWorkoutsDetails = DailyWorkoutsDetails.all(allEntries);

    // total duration across all workouts
    final totalDuration = allDailyWorkoutsDetails
        .map((dateWorkoutsDuration) => dateWorkoutsDuration.duration)
        .reduce((value, element) => value + element);

    // total calories across all workouts
    final totalCalories = allDailyWorkoutsDetails
        .map((dateWorkoutsDuration) => dateWorkoutsDuration.calories)
        .reduce((value, element) => value + element);

    return <EntriesListTileModel>[
      EntriesListTileModel(
        leadingText: 'All Entries',
        middleText: Format.calories(totalCalories),
        trailingText: Format.hours(totalDuration),
      ),
      for (DailyWorkoutsDetails dailyWorkoutsDetails
          in allDailyWorkoutsDetails) ...[
        EntriesListTileModel(
          isHeader: true,
          leadingText: Format.date(dailyWorkoutsDetails.date),
          middleText: Format.calories(dailyWorkoutsDetails.calories),
          trailingText: Format.hours(dailyWorkoutsDetails.duration),
        ),
        for (WorkoutDetails workoutDuration
            in dailyWorkoutsDetails.workoutsDetails)
          EntriesListTileModel(
            leadingText: workoutDuration.name,
            middleText: Format.calories(workoutDuration.calories),
            trailingText: Format.hours(workoutDuration.durationInHours),
          ),
      ]
    ];
  }
}
