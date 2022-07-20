import 'package:email_password_sign_in_ui/email_password_sign_in_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fit_tracker/app/home/workout_entries/entry_page.dart';
import 'package:fit_tracker/app/home/workouts/edit_workout_page.dart';
import 'package:fit_tracker/app/home/models/entry.dart';
import 'package:fit_tracker/app/home/models/workout.dart';

class AppRoutes {
  static const emailPasswordSignInPage = '/email-password-sign-in-page';
  static const editWorkoutPage = '/edit-workout-page';
  static const entryPage = '/entry-page';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(
      RouteSettings settings, FirebaseAuth firebaseAuth) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.emailPasswordSignInPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EmailPasswordSignInPage.withFirebaseAuth(firebaseAuth,
              onSignedIn: args as void Function()),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.editWorkoutPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EditWorkoutPage(workout: args as Workout?),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.entryPage:
        final mapArgs = args as Map<String, dynamic>;
        final workout = mapArgs['workout'] as Workout;
        final entry = mapArgs['entry'] as Entry?;
        return MaterialPageRoute<dynamic>(
          builder: (_) => EntryPage(workout: workout, entry: entry),
          settings: settings,
          fullscreenDialog: true,
        );
      default:
        // TODO: Throw
        return null;
    }
  }
}
