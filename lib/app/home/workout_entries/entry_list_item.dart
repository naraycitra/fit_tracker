import 'package:flutter/material.dart';
import 'package:fit_tracker/app/home/workout_entries/format.dart';
import 'package:fit_tracker/app/home/models/entry.dart';
import 'package:fit_tracker/app/home/models/workout.dart';

class EntryListItem extends StatelessWidget {
  const EntryListItem({
    required this.entry,
    required this.workout,
    this.onTap,
  });

  final Entry entry;
  final Workout workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _buildContents(context),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final dayOfWeek = Format.dayOfWeek(entry.start);
    final startDate = Format.date(entry.start);
    final startTime = TimeOfDay.fromDateTime(entry.start).format(context);
    final endTime = TimeOfDay.fromDateTime(entry.end).format(context);
    final durationFormatted = Format.hours(entry.durationInHours);

    final calories = workout.caloriesPerHour * entry.durationInHours;
    final caloriesFormatted = Format.calories(calories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[
          Text(dayOfWeek,
              style: const TextStyle(fontSize: 18.0, color: Colors.grey)),
          const SizedBox(width: 15.0),
          Text(startDate, style: const TextStyle(fontSize: 18.0)),
          if (workout.caloriesPerHour > 0.0) ...<Widget>[
            Expanded(child: Container()),
            Text(
              caloriesFormatted,
              style: TextStyle(fontSize: 16.0, color: Colors.green[700]),
            ),
          ],
        ]),
        Row(children: <Widget>[
          Text('$startTime - $endTime', style: const TextStyle(fontSize: 16.0)),
          Expanded(child: Container()),
          Text(durationFormatted, style: const TextStyle(fontSize: 16.0)),
        ]),
        if (entry.comment.isNotEmpty)
          Text(
            entry.comment,
            style: const TextStyle(fontSize: 12.0),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }
}

class DismissibleEntryListItem extends StatelessWidget {
  const DismissibleEntryListItem({
    required this.dismissibleKey,
    required this.entry,
    required this.workout,
    this.onDismissed,
    this.onTap,
  });

  final Key dismissibleKey;
  final Entry entry;
  final Workout workout;
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: dismissibleKey,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismissed?.call(),
      child: EntryListItem(
        entry: entry,
        workout: workout,
        onTap: onTap,
      ),
    );
  }
}
