import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// Application name shown in the OS task switcher.
  ///
  /// In en, this message translates to:
  /// **'YiChinese'**
  String get appTitle;

  /// Home destination label.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Books destination label.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get navBooks;

  /// Title of the login screen.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// Label for the username field on the login screen.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginUsernameLabel;

  /// Label for the password field on the login screen.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Label of the login submit button.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSubmit;

  /// Validation message shown under an empty required field.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get loginFieldRequired;

  /// Generic error shown when login fails.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get loginFailed;

  /// Greeting on the home screen when the username is known.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(String name);

  /// Greeting on the home screen when the username is not available.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeGreetingGeneric;

  /// Uppercase kicker label on the current-lesson card.
  ///
  /// In en, this message translates to:
  /// **'Current Lesson'**
  String get homeCurrentLessonKicker;

  /// Title of the resume-lesson card.
  ///
  /// In en, this message translates to:
  /// **'Recent Lesson'**
  String get homeContinueTitle;

  /// Subtitle of the resume-lesson card describing the lesson.
  ///
  /// In en, this message translates to:
  /// **'{hskLevel} · Lesson {lesson} · Part {part}'**
  String homeContinueSubtitle(String hskLevel, int lesson, int part);

  /// CTA button label on the recent lesson panel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeContinueButton;

  /// Empty-state title when there is no recent lesson.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t started a lesson yet.'**
  String get homeNoRecentTitle;

  /// Empty-state message when there is no recent lesson.
  ///
  /// In en, this message translates to:
  /// **'Open the Books section to pick a lesson.'**
  String get homeNoRecentMessage;

  /// Label of the entry point to the Books list.
  ///
  /// In en, this message translates to:
  /// **'Browse Books'**
  String get homeBrowseBooks;

  /// Error shown when the dashboard fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your dashboard.'**
  String get homeError;

  /// Generic retry button label.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Generic close button label.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Tooltip for the sign-out action.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutTooltip;

  /// Title of the books list screen.
  ///
  /// In en, this message translates to:
  /// **'Select Book'**
  String get booksTitle;

  /// Subtitle under the books list title.
  ///
  /// In en, this message translates to:
  /// **'Choose a book to view its lessons'**
  String get booksSubtitle;

  /// Back link label from book detail to books list.
  ///
  /// In en, this message translates to:
  /// **'Back to Books'**
  String get booksBackToBooks;

  /// Empty state when there are no books.
  ///
  /// In en, this message translates to:
  /// **'No books yet.'**
  String get booksEmpty;

  /// Error shown when the books list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load books.'**
  String get booksError;

  /// Lesson count for a book.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson} other{{count} lessons}}'**
  String booksLessonsCount(int count);

  /// Part count for a book or lesson.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 part} other{{count} parts}}'**
  String booksPartsCount(int count);

  /// Completed badge text on a finished book part.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get booksCompleted;

  /// Error shown when a book's lessons fail to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load lessons.'**
  String get bookError;

  /// Label for a lesson in a book.
  ///
  /// In en, this message translates to:
  /// **'Lesson {lesson}'**
  String lessonLabel(String lesson);

  /// Label for a part within a lesson.
  ///
  /// In en, this message translates to:
  /// **'Part {part}'**
  String partLabel(String part);

  /// Error shown when a passage fails to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load passage.'**
  String get studyError;

  /// Empty state when a passage has no lines.
  ///
  /// In en, this message translates to:
  /// **'No lines found for this lesson part.'**
  String get studyEmpty;

  /// Toolbar button label to auto-play passage lines.
  ///
  /// In en, this message translates to:
  /// **'Auto Play'**
  String get studyAutoPlay;

  /// Toggle label to reveal pinyin.
  ///
  /// In en, this message translates to:
  /// **'Show Pinyin'**
  String get studyShowPinyin;

  /// Toggle label to hide pinyin.
  ///
  /// In en, this message translates to:
  /// **'Hide Pinyin'**
  String get studyHidePinyin;

  /// Toggle label to reveal translations.
  ///
  /// In en, this message translates to:
  /// **'Show Meaning'**
  String get studyShowMeaning;

  /// Toggle label to hide translations.
  ///
  /// In en, this message translates to:
  /// **'Hide Meaning'**
  String get studyHideMeaning;

  /// Shown in the word popup when a word has no vocab entry.
  ///
  /// In en, this message translates to:
  /// **'Not in vocabulary'**
  String get wordNotFound;

  /// Word popup button to play the word audio.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get wordListen;

  /// Word popup button to show stroke order.
  ///
  /// In en, this message translates to:
  /// **'Stroke'**
  String get wordStroke;

  /// Message for features not yet wired (audio, stroke order).
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
