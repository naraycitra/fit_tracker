import 'dart:async';

import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedantic/pedantic.dart';
import 'package:fit_tracker/app/home/workout_entries/entry_list_item.dart';
import 'package:fit_tracker/app/home/workout_entries/entry_page.dart';
import 'package:fit_tracker/app/home/workouts/edit_workout_page.dart';
import 'package:fit_tracker/app/home/workouts/list_items_builder.dart';
import 'package:fit_tracker/app/home/models/entry.dart';
import 'package:fit_tracker/app/home/models/workout.dart';
import 'package:fit_tracker/app/top_level_providers.dart';
import 'package:fit_tracker/routing/cupertino_tab_view_router.dart';

class WorkoutEntriesPage extends StatelessWidget {
  const WorkoutEntriesPage({required this.workout});
  final Workout workout;

  static Future<void> show(BuildContext context, Workout workout) async {
    await Navigator.of(context).pushNamed(
      CupertinoTabViewRoutes.workoutEntriesPage,
      arguments: workout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: WorkoutEntriesAppBarTitle(workout: workout),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => EditWorkoutPage.show(
              context,
              workout: workout,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => EntryPage.show(
              context: context,
              workout: workout,
            ),
          ),
        ],
      ),
      body: WorkoutEntriesContents(workout: workout),
    );
  }
}

final workoutStreamProvider =
    StreamProvider.autoDispose.family<Workout, String>((ref, workoutId) {
  final database = ref.watch(databaseProvider)!;
  return database.workoutStream(workoutId: workoutId);
});

class WorkoutEntriesAppBarTitle extends ConsumerWidget {
  const WorkoutEntriesAppBarTitle({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsyncValue = ref.watch(workoutStreamProvider(workout.id));
    return workoutAsyncValue.when(
      data: (workout) => Text(workout.name),
      loading: () => Container(),
      error: (_, __) => Container(),
    );
  }
}

final workoutEntriesStreamProvider =
    StreamProvider.autoDispose.family<List<Entry>, Workout>((ref, workout) {
  final database = ref.watch(databaseProvider)!;
  return database.entriesStream(workout: workout);
});

class WorkoutEntriesContents extends ConsumerWidget {
  final Workout workout;
  const WorkoutEntriesContents({required this.workout});

  Future<void> _deleteEntry(
      BuildContext context, WidgetRef ref, Entry entry) async {
    try {
      final database = ref.read(databaseProvider)!;
      await database.deleteEntry(entry);
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
    final entriesStream = ref.watch(workoutEntriesStreamProvider(workout));
    return ListItemsBuilder<Entry>(
      data: entriesStream,
      itemBuilder: (context, entry) {
        return DismissibleEntryListItem(
          dismissibleKey: Key('entry-${entry.id}'),
          entry: entry,
          workout: workout,
          onDismissed: () => _deleteEntry(context, ref, entry),
          onTap: () => EntryPage.show(
            context: context,
            workout: workout,
            entry: entry,
          ),
        );
      },
    );
  }
}
