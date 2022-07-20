import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/app/home/models/workout.dart';
import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:fit_tracker/app/top_level_providers.dart';
import 'package:fit_tracker/routing/app_router.dart';
import 'package:fit_tracker/services/firestore_database.dart';
import 'package:pedantic/pedantic.dart';

class EditWorkoutPage extends ConsumerStatefulWidget {
  const EditWorkoutPage({Key? key, this.workout}) : super(key: key);
  final Workout? workout;

  static Future<void> show(BuildContext context, {Workout? workout}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.editWorkoutPage,
      arguments: workout,
    );
  }

  @override
  _EditWorkoutPageState createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends ConsumerState<EditWorkoutPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  int? _caloriesPerHour;

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _name = widget.workout?.name;
      _caloriesPerHour = widget.workout?.caloriesPerHour;
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        final database = ref.read<FirestoreDatabase?>(databaseProvider)!;
        final workouts = await database.workoutsStream().first;
        final allLowerCaseNames =
            workouts.map((workout) => workout.name.toLowerCase()).toList();
        if (widget.workout != null) {
          allLowerCaseNames.remove(widget.workout!.name.toLowerCase());
        }
        if (allLowerCaseNames.contains(_name?.toLowerCase())) {
          unawaited(showAlertDialog(
            context: context,
            title: 'Name already used',
            content: 'Please choose a different workout name',
            defaultActionText: 'OK',
          ));
        } else {
          final id = widget.workout?.id ?? documentIdFromCurrentDate();
          final workout = Workout(
              id: id,
              name: _name ?? '',
              caloriesPerHour: _caloriesPerHour ?? 0);
          await database.setWorkout(workout);
          Navigator.of(context).pop();
        }
      } catch (e) {
        unawaited(showExceptionAlertDialog(
          context: context,
          title: 'Operation failed',
          exception: e,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.workout == null ? 'New Workout' : 'Edit Workout'),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onPressed: () => _submit(),
          ),
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Workout name'),
        keyboardAppearance: Brightness.light,
        initialValue: _name,
        validator: (value) =>
            (value ?? '').isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Calories per hour'),
        keyboardAppearance: Brightness.light,
        initialValue: _caloriesPerHour != null ? '$_caloriesPerHour' : null,
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        onSaved: (value) => _caloriesPerHour = int.tryParse(value ?? '') ?? 0,
      ),
    ];
  }
}
