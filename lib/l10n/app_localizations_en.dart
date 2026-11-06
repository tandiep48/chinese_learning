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
  String get loginTitle => 'Sign In';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Sign In';

  @override
  String get loginFieldRequired => 'Please fill in all fields';

  @override
  String get loginFailed => 'Invalid username or password';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeGreetingGeneric => 'Welcome back';

  @override
  String get homeCurrentLessonKicker => 'Current Lesson';

  @override
  String get homeContinueTitle => 'Recent Lesson';

  @override
  String homeContinueSubtitle(String hskLevel, int lesson, int part) {
    return '$hskLevel · Lesson $lesson · Part $part';
  }

  @override
  String get homeContinueButton => 'Continue';

  @override
  String get homeNoRecentTitle => 'You haven\'t started a lesson yet.';

  @override
  String get homeNoRecentMessage => 'Open the Books section to pick a lesson.';

  @override
  String get homeBrowseBooks => 'Browse Books';

  @override
  String get homeError => 'Couldn\'t load your dashboard.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get logoutTooltip => 'Sign Out';

  @override
  String get booksTitle => 'Select Book';

  @override
  String get booksSubtitle => 'Choose a book to view its lessons';

  @override
  String get booksBackToBooks => 'Back to Books';

  @override
  String get booksEmpty => 'No books yet.';

  @override
  String get booksError => 'Failed to load books.';

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
  String get booksCompleted => 'Completed';

  @override
  String get bookError => 'Failed to load lessons.';

  @override
  String lessonLabel(String lesson) {
    return 'Lesson $lesson';
  }

  @override
  String partLabel(String part) {
    return 'Part $part';
  }

  @override
  String get studyError => 'Failed to load passage.';

  @override
  String get studyEmpty => 'No lines found for this lesson part.';

  @override
  String get studyAutoPlay => 'Auto Play';

  @override
  String get studyShowPinyin => 'Show Pinyin';

  @override
  String get studyHidePinyin => 'Hide Pinyin';

  @override
  String get studyShowMeaning => 'Show Meaning';

  @override
  String get studyHideMeaning => 'Hide Meaning';

  @override
  String get wordNotFound => 'Not in vocabulary';

  @override
  String get wordListen => 'Listen';

  @override
  String get wordStroke => 'Stroke';

  @override
  String get comingSoon => 'Coming soon';
}
