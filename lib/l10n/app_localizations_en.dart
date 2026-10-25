// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'YiChinese';

  @override
  String get navHome => 'Home';

  @override
  String get navBooks => 'Books';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginFieldRequired => 'Required';

  @override
  String get loginFailed => 'Sign in failed. Check your username and password.';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeGreetingGeneric => 'Welcome back';

  @override
  String get homeContinueTitle => 'Continue where you left off';

  @override
  String homeContinueSubtitle(String hskLevel, int lesson, int part) {
    return '$hskLevel · Lesson $lesson · Part $part';
  }

  @override
  String get homeNoRecentTitle => 'No lessons yet';

  @override
  String get homeNoRecentMessage => 'Open the Books tab to pick a lesson.';

  @override
  String get homeBrowseBooks => 'Browse books';

  @override
  String get homeError => 'Couldn\'t load your dashboard.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get logoutTooltip => 'Sign out';
}
