import 'package:flutter/material.dart';
import 'package:fit_tracker/app/home/models/workout.dart';

class WorkoutListTile extends StatelessWidget {
  const WorkoutListTile({Key? key, required this.workout, this.onTap})
      : super(key: key);
  final Workout workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(workout.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
