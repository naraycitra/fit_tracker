import 'package:fit_tracker/app/home/entries/entry_workout.dart';
import 'package:fit_tracker/app/home/models/workout.dart';

/// Temporary model class to store the time tracked and calories for a workout
class WorkoutDetails {
  WorkoutDetails({
    required this.name,
    required this.durationInHours,
    required this.calories,
  });
  final String name;
  double durationInHours;
  double calories;
}

/// Groups together all workouts/entries on a given day
class DailyWorkoutsDetails {
  DailyWorkoutsDetails({required this.date, required this.workoutsDetails});
  final DateTime date;
  final List<WorkoutDetails> workoutsDetails;

  double get calories => workoutsDetails
      .map((workoutDuration) => workoutDuration.calories)
      .reduce((value, element) => value + element);

  double get duration => workoutsDetails
      .map((workoutDuration) => workoutDuration.durationInHours)
      .reduce((value, element) => value + element);

  /// splits all entries into separate groups by date
  static Map<DateTime, List<EntryWorkout>> _entriesByDate(
      List<EntryWorkout> entries) {
    final Map<DateTime, List<EntryWorkout>> map = {};
    for (final entryWorkout in entries) {
      final entryDayStart = DateTime(entryWorkout.entry.start.year,
          entryWorkout.entry.start.month, entryWorkout.entry.start.day);
      if (map[entryDayStart] == null) {
        map[entryDayStart] = [entryWorkout];
      } else {
        map[entryDayStart]!.add(entryWorkout);
      }
    }
    return map;
  }

  /// maps an unordered list of EntryWorkout into a list of DailyWorkoutsDetails with date information
  static List<DailyWorkoutsDetails> all(List<EntryWorkout> entries) {
    final byDate = _entriesByDate(entries);
    final List<DailyWorkoutsDetails> list = [];
    for (final pair in byDate.entries) {
      final date = pair.key;
      final entriesByDate = pair.value;
      final byWorkout = _workoutsDetails(entriesByDate);
      list.add(DailyWorkoutsDetails(date: date, workoutsDetails: byWorkout));
    }
    return list.toList();
  }

  /// groups entries by workout
  static List<WorkoutDetails> _workoutsDetails(List<EntryWorkout> entries) {
    final Map<String, WorkoutDetails> workoutDuration = {};
    for (final entryWorkout in entries) {
      final entry = entryWorkout.entry;
      final calories =
          entry.durationInHours * entryWorkout.workout.caloriesPerHour;
      if (workoutDuration[entry.workoutId] == null) {
        workoutDuration[entry.workoutId] = WorkoutDetails(
          name: entryWorkout.workout.name,
          durationInHours: entry.durationInHours,
          calories: calories,
        );
      } else {
        workoutDuration[entry.workoutId]!.calories += calories;
        workoutDuration[entry.workoutId]!.durationInHours +=
            entry.durationInHours;
      }
    }
    return workoutDuration.values.toList();
  }
}
