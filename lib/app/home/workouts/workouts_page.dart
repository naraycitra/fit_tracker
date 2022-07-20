import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/app/home/workout_entries/workout_entries_page.dart';
import 'package:fit_tracker/app/home/workouts/edit_workout_page.dart';
import 'package:fit_tracker/app/home/workouts/workout_list_tile.dart';
import 'package:fit_tracker/app/home/workouts/list_items_builder.dart';
import 'package:fit_tracker/app/home/models/workout.dart';
import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:fit_tracker/app/top_level_providers.dart';
import 'package:fit_tracker/constants/strings.dart';
import 'package:pedantic/pedantic.dart';
import 'package:fit_tracker/services/firestore_database.dart';

final workoutsStreamProvider = StreamProvider.autoDispose<List<Workout>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return database.workoutsStream();
});

// watch database
class WorkoutPage extends ConsumerWidget {
  Future<void> _delete(
      BuildContext context, WidgetRef ref, Workout workout) async {
    try {
      final database = ref.read<FirestoreDatabase?>(databaseProvider)!;
      await database.deleteWorkout(workout);
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.workouts),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => EditWorkoutPage.show(context),
          ),
        ],
      ),
      body: _buildContents(context, ref),
    );
  }

  Widget _buildContents(BuildContext context, WidgetRef ref) {
    final workoutsAsyncValue = ref.watch(workoutsStreamProvider);
    return ListItemsBuilder<Workout>(
      data: workoutsAsyncValue,
      itemBuilder: (context, workout) => Dismissible(
        key: Key('workout-${workout.id}'),
        background: Container(color: Colors.red),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => _delete(context, ref, workout),
        child: WorkoutListTile(
          workout: workout,
          onTap: () => WorkoutEntriesPage.show(context, workout),
        ),
      ),
    );
  }
}
