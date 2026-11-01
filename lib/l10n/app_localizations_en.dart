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

  @override
  String get booksTitle => 'Books';

  @override
  String get booksSubtitle => 'Choose a book to study';

  @override
  String get booksEmpty => 'No books found';

  @override
  String get booksError => 'Couldn\'t load books.';

  @override
  String booksLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$_temp0';
  }

  @override
  String booksPartsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parts',
      one: '1 part',
    );
    return '$_temp0';
  }

  @override
  String get bookError => 'Couldn\'t load lessons.';

  @override
  String lessonLabel(String lesson) {
    return 'Lesson $lesson';
  }

  @override
  String partLabel(String part) {
    return 'Part $part';
  }

  @override
  String get studyError => 'Couldn\'t load the passage.';

  @override
  String get studyEmpty => 'No lines in this passage.';

  @override
  String get studyShowPinyin => 'Show pinyin';

  @override
  String get studyHidePinyin => 'Hide pinyin';

  @override
  String get studyShowMeaning => 'Show meaning';

  @override
  String get studyHideMeaning => 'Hide meaning';

  @override
  String get wordNotFound => 'Not in this lesson\'s vocabulary.';

  @override
  String get wordListen => 'Listen';

  @override
  String get wordStroke => 'Strokes';

  @override
  String get comingSoon => 'Coming soon';
}
