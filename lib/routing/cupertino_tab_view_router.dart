import 'package:fit_tracker/app/home/workout_entries/workout_entries_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:fit_tracker/app/home/models/workout.dart';

class CupertinoTabViewRoutes {
  static const workoutEntriesPage = '/workout-entries-page';
}

class CupertinoTabViewRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case CupertinoTabViewRoutes.workoutEntriesPage:
        final workout = settings.arguments as Workout;
        return CupertinoPageRoute(
          builder: (_) => WorkoutEntriesPage(workout: workout),
          settings: settings,
          fullscreenDialog: false,
        );
    }
    return null;
  }
}
