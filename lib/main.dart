//import 'package:auth_widget_builder/auth_widget_builder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker/app/auth_widget.dart';
import 'package:fit_tracker/app/home/home_page.dart';
import 'package:fit_tracker/app/onboarding/onboarding_page.dart';
import 'package:fit_tracker/app/onboarding/onboarding_view_model.dart';
import 'package:fit_tracker/app/top_level_providers.dart';
import 'package:fit_tracker/app/sign_in/sign_in_page.dart';
import 'package:fit_tracker/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/services/shared_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        SharedPreferencesService(sharedPreferences),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: AuthWidget(
        nonSignedInBuilder: (_) => Consumer(
          builder: (context, ref, _) {
            final didCompleteOnboarding =
                ref.watch(onboardingViewModelProvider);
            return didCompleteOnboarding ? SignInPage() : OnboardingPage();
          },
        ),
        signedInBuilder: (_) => HomePage(),
      ),
      onGenerateRoute: (settings) =>
          AppRouter.onGenerateRoute(settings, firebaseAuth),
    );
  }
}
