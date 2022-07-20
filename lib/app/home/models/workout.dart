import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Workout extends Equatable {
  const Workout(
      {required this.id, required this.name, required this.caloriesPerHour});
  final String id;
  final String name;
  final int caloriesPerHour;

  @override
  List<Object> get props => [id, name, caloriesPerHour];

  @override
  bool get stringify => true;

  factory Workout.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for workoutId: $documentId');
    }
    final name = data['name'] as String?;
    if (name == null) {
      throw StateError('missing name for workoutId: $documentId');
    }
    final caloriesPerHour = data['caloriesPerHour'] as int;
    return Workout(
        id: documentId, name: name, caloriesPerHour: caloriesPerHour);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'caloriesPerHour': caloriesPerHour,
    };
  }
}
