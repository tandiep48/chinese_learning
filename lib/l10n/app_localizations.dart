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

  /// Navigation drawer label for the home/dashboard destination.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Navigation drawer label for the HSK/Books library destination (web nav.hsk).
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Navigation drawer label for the vocabulary destination (disabled until its slice ships).
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get navVocabulary;

  /// Navigation drawer label for the recommended-practice destination (disabled until its slice ships).
  ///
  /// In en, this message translates to:
  /// **'Recommend'**
  String get navRecommend;

  /// Navigation drawer label for the settings action.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Navigation drawer label for the logout action.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get navLogout;

  /// Settings field label for the UI language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Settings field label for the hanzi script (simplified/traditional).
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get settingsScript;

  /// Settings field label for the hanzi font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get settingsFont;

  /// Language option: Vietnamese (shown in its own language).
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get settingsLangVi;

  /// Language option: English (shown in its own language).
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLangEn;

  /// Hanzi script option: simplified.
  ///
  /// In en, this message translates to:
  /// **'简体 Simplified'**
  String get settingsScriptSimplified;

  /// Hanzi script option: traditional.
  ///
  /// In en, this message translates to:
  /// **'繁體 Traditional'**
  String get settingsScriptTraditional;

  /// Note that the hanzi script/font preference is saved but not yet rendered.
  ///
  /// In en, this message translates to:
  /// **'Chinese text styling will apply in a future update.'**
  String get settingsHanziNote;

  /// Error shown when saving a settings preference fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your preference.'**
  String get settingsSaveError;

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

  /// Title of the register screen.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// Label for the email field on the register screen.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// Label of the register submit button.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerSubmit;

  /// Validation message when the chosen password is too short.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get registerPasswordHint;

  /// Generic error shown when registration fails.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// Prompt on the login screen before the register link.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// Link on the login screen to the register screen.
  ///
  /// In en, this message translates to:
  /// **'Register here'**
  String get registerHere;

  /// Prompt on the register screen before the login link.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccountPrompt;

  /// Link on the register screen back to the login screen.
  ///
  /// In en, this message translates to:
  /// **'Log in here'**
  String get loginHere;

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

  /// Label of the entry point to the HSK level picker.
  ///
  /// In en, this message translates to:
  /// **'Browse by HSK level'**
  String get homeBrowseHsk;

  /// Dashboard tab label for the lesson activity.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get homeTabLesson;

  /// Dashboard tab label for the vocabulary review activity.
  ///
  /// In en, this message translates to:
  /// **'Word Review'**
  String get homeTabReview;

  /// Dashboard tab label for the recommended-practice activity.
  ///
  /// In en, this message translates to:
  /// **'Recommend'**
  String get homeTabRecommend;

  /// Placeholder message on the Review tab until the SRS slice ships.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary review is coming soon.'**
  String get homeReviewStub;

  /// Placeholder message on the Recommend tab until the practice slice ships.
  ///
  /// In en, this message translates to:
  /// **'Recommended practice is coming soon.'**
  String get homeRecommendStub;

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

  /// Library tab label for the HSK level browse path.
  ///
  /// In en, this message translates to:
  /// **'HSK'**
  String get libraryTabHsk;

  /// Title of the HSK level picker.
  ///
  /// In en, this message translates to:
  /// **'Select HSK Level'**
  String get hskSelectLevelTitle;

  /// Subtitle under the HSK level picker title.
  ///
  /// In en, this message translates to:
  /// **'Choose a level to see its lessons'**
  String get hskSelectLevelSubtitle;

  /// Title of the lesson picker within an HSK level.
  ///
  /// In en, this message translates to:
  /// **'Select Lesson'**
  String get hskSelectLessonTitle;

  /// Count of lessons available in an HSK level.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson available} other{{count} lessons available}}'**
  String hskLessonsAvailable(int count);

  /// Placeholder for the lesson search field in the HSK picker.
  ///
  /// In en, this message translates to:
  /// **'Search lessons'**
  String get hskSearchPlaceholder;

  /// Empty state when an HSK level has no lessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons found for this level.'**
  String get hskNoLessons;

  /// Empty state when a lesson search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'No lessons match your search.'**
  String get hskNoMatch;

  /// Heading for passages that do not belong to a numbered lesson.
  ///
  /// In en, this message translates to:
  /// **'Other Passages'**
  String get hskOtherPassages;

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

  /// Stroke-order panel: animate the strokes step by step.
  ///
  /// In en, this message translates to:
  /// **'Animate'**
  String get strokeAnimate;

  /// Stroke-order panel: practice (quiz) writing the character.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get strokePractice;

  /// Stroke-order panel: reset the animation or quiz.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get strokeReset;

  /// Stroke-order panel error when the character data fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load stroke order.'**
  String get strokeLoadError;

  /// No description provided for @practiceLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading practice…'**
  String get practiceLoading;

  /// No description provided for @practiceLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load practice data.'**
  String get practiceLoadFailed;

  /// No description provided for @practiceCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Complete!'**
  String get practiceCompleteTitle;

  /// No description provided for @practiceSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Practice Set'**
  String get practiceSetLabel;

  /// No description provided for @practiceCorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get practiceCorrectAnswers;

  /// No description provided for @practiceRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get practiceRetry;

  /// No description provided for @practiceCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get practiceCheck;

  /// No description provided for @practiceSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get practiceSkip;

  /// No description provided for @practicePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get practicePrevious;

  /// No description provided for @practiceSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get practiceSubmitting;

  /// No description provided for @practiceFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get practiceFinish;

  /// No description provided for @practiceBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get practiceBack;

  /// No description provided for @practiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get practiceListening;

  /// No description provided for @practiceReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get practiceReading;

  /// No description provided for @practiceTrueLabel.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get practiceTrueLabel;

  /// No description provided for @practiceFalseLabel.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get practiceFalseLabel;

  /// No description provided for @practiceYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Your order (click to place):'**
  String get practiceYourOrder;

  /// No description provided for @practiceSentencesClickAdd.
  ///
  /// In en, this message translates to:
  /// **'Sentences (click to add):'**
  String get practiceSentencesClickAdd;

  /// No description provided for @practiceChooseFromOptions.
  ///
  /// In en, this message translates to:
  /// **'Choose from options:'**
  String get practiceChooseFromOptions;

  /// No description provided for @practiceChooseImagePerSentence.
  ///
  /// In en, this message translates to:
  /// **'Choose the matching image for each sentence.'**
  String get practiceChooseImagePerSentence;

  /// No description provided for @practiceChooseAnswerPerSentence.
  ///
  /// In en, this message translates to:
  /// **'Choose the answer that matches each sentence below.'**
  String get practiceChooseAnswerPerSentence;

  /// No description provided for @practiceChooseImageForAudio.
  ///
  /// In en, this message translates to:
  /// **'Listen to the conversation and choose the appropriate image.'**
  String get practiceChooseImageForAudio;

  /// No description provided for @practicePlayPassage.
  ///
  /// In en, this message translates to:
  /// **'Play Passage'**
  String get practicePlayPassage;

  /// No description provided for @practiceCorrectExclaim.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get practiceCorrectExclaim;

  /// No description provided for @practiceBack5.
  ///
  /// In en, this message translates to:
  /// **'Back 5 seconds'**
  String get practiceBack5;

  /// No description provided for @practiceForward5.
  ///
  /// In en, this message translates to:
  /// **'Forward 5 seconds'**
  String get practiceForward5;

  /// No description provided for @practiceStopAudio.
  ///
  /// In en, this message translates to:
  /// **'Stop audio'**
  String get practiceStopAudio;

  /// No description provided for @practiceSeekSlider.
  ///
  /// In en, this message translates to:
  /// **'Seek audio position'**
  String get practiceSeekSlider;

  /// No description provided for @practiceAudioFallback.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get practiceAudioFallback;

  /// No description provided for @practiceQuestionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {n}'**
  String practiceQuestionNumber(int n);

  /// No description provided for @practiceQuestionsGroup.
  ///
  /// In en, this message translates to:
  /// **'Questions {progress}'**
  String practiceQuestionsGroup(String progress);

  /// No description provided for @practiceCorrectOrder.
  ///
  /// In en, this message translates to:
  /// **'Correct order: {order}'**
  String practiceCorrectOrder(String order);

  /// No description provided for @practiceCorrectAnswerColon.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String practiceCorrectAnswerColon(String answer);

  /// No description provided for @practiceScoreCorrect.
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct'**
  String practiceScoreCorrect(int correct, int total);

  /// No description provided for @practiceAudioNumbered.
  ///
  /// In en, this message translates to:
  /// **'Audio {n}'**
  String practiceAudioNumbered(int n);

  /// No description provided for @practicePlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Play {label}'**
  String practicePlayLabel(String label);

  /// No description provided for @commonLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get commonLoadMore;

  /// No description provided for @dashboardTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get dashboardTotalTime;

  /// No description provided for @dashboardWordsMastered.
  ///
  /// In en, this message translates to:
  /// **'Words Mastered'**
  String get dashboardWordsMastered;

  /// No description provided for @dashboardTimeLearned3days.
  ///
  /// In en, this message translates to:
  /// **'Time Learned (Last 3 Days)'**
  String get dashboardTimeLearned3days;

  /// No description provided for @dashboardWordsMastered3days.
  ///
  /// In en, this message translates to:
  /// **'Words Mastered (Last 3 Days)'**
  String get dashboardWordsMastered3days;

  /// No description provided for @dashboardNoChartData.
  ///
  /// In en, this message translates to:
  /// **'No recent activity to chart yet.'**
  String get dashboardNoChartData;

  /// No description provided for @dashboardExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get dashboardExercise;

  /// No description provided for @dashboardExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get dashboardExam;

  /// No description provided for @dashboardLessonTrainer.
  ///
  /// In en, this message translates to:
  /// **'Lesson Trainer'**
  String get dashboardLessonTrainer;

  /// No description provided for @dashboardVocabTrainer.
  ///
  /// In en, this message translates to:
  /// **'Vocab Trainer'**
  String get dashboardVocabTrainer;

  /// No description provided for @dashboardLearningStatistics.
  ///
  /// In en, this message translates to:
  /// **'Learning Statistics'**
  String get dashboardLearningStatistics;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLearnedWords.
  ///
  /// In en, this message translates to:
  /// **'Learned Words'**
  String get profileLearnedWords;

  /// No description provided for @reviewHeading.
  ///
  /// In en, this message translates to:
  /// **'Your Words'**
  String get reviewHeading;

  /// No description provided for @reviewTabRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent learn word'**
  String get reviewTabRecent;

  /// No description provided for @reviewTabReview.
  ///
  /// In en, this message translates to:
  /// **'Review word'**
  String get reviewTabReview;

  /// No description provided for @reviewSubtitleRecent.
  ///
  /// In en, this message translates to:
  /// **'The words you\'ve mastered most recently.'**
  String get reviewSubtitleRecent;

  /// No description provided for @reviewSubtitleReview.
  ///
  /// In en, this message translates to:
  /// **'Words to revisit — not yet mastered, or answered slowly.'**
  String get reviewSubtitleReview;

  /// No description provided for @reviewEmptyRecent.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t mastered any words yet.'**
  String get reviewEmptyRecent;

  /// No description provided for @reviewEmptyReview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review right now.'**
  String get reviewEmptyReview;

  /// Profile review: loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your history…'**
  String get reviewLoading;

  /// No description provided for @reviewLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your words. Please try again.'**
  String get reviewLoadFailed;

  /// No description provided for @reviewPrevPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get reviewPrevPage;

  /// No description provided for @reviewNextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get reviewNextPage;

  /// No description provided for @reviewPageRange.
  ///
  /// In en, this message translates to:
  /// **'{start}-{end} of {total}'**
  String reviewPageRange(int start, int end, int total);

  /// No description provided for @recommendFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding recommendations…'**
  String get recommendFinding;

  /// No description provided for @recommendAnalysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing your vocabulary progress.'**
  String get recommendAnalysing;

  /// No description provided for @recommendErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get recommendErrorTitle;

  /// No description provided for @recommendConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get recommendConnectFailed;

  /// No description provided for @recommendFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recommendations.'**
  String get recommendFailedLoad;

  /// No description provided for @recommendEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recommendations yet'**
  String get recommendEmptyTitle;

  /// No description provided for @recommendEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Keep learning vocabulary to unlock recommended practice groups!'**
  String get recommendEmptySub;

  /// No description provided for @recommendNewUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome! You\'re just getting started.'**
  String get recommendNewUserTitle;

  /// No description provided for @recommendNewUserSub.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t practiced any vocabulary yet. Recommended lessons unlock automatically as you learn words — start with the Vocabulary Trainer!'**
  String get recommendNewUserSub;

  /// No description provided for @recommendStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get recommendStart;

  /// No description provided for @recommendLessonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get recommendLessonPrefix;

  /// No description provided for @recommendStatusNotStart.
  ///
  /// In en, this message translates to:
  /// **'Not start'**
  String get recommendStatusNotStart;

  /// No description provided for @recommendStatusFinishSuccess.
  ///
  /// In en, this message translates to:
  /// **'Finish and success'**
  String get recommendStatusFinishSuccess;

  /// No description provided for @recommendStatusFinishFail.
  ///
  /// In en, this message translates to:
  /// **'Finish and fail'**
  String get recommendStatusFinishFail;

  /// No description provided for @recommendGroupsFound.
  ///
  /// In en, this message translates to:
  /// **'Found {count} question group(s) ready to practice.'**
  String recommendGroupsFound(int count);

  /// No description provided for @recommendQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} question(s)'**
  String recommendQuestionCount(int count);

  /// No description provided for @recommendQuestionSingle.
  ///
  /// In en, this message translates to:
  /// **'Question {n}'**
  String recommendQuestionSingle(String n);

  /// No description provided for @recommendQuestionsRange.
  ///
  /// In en, this message translates to:
  /// **'Questions {a}–{b}'**
  String recommendQuestionsRange(String a, String b);

  /// No description provided for @recommendNewFocus.
  ///
  /// In en, this message translates to:
  /// **'New focus: {words}'**
  String recommendNewFocus(String words);

  /// No description provided for @grammarTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get grammarTitle;

  /// No description provided for @grammarErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading grammar.'**
  String get grammarErrorLoading;

  /// No description provided for @grammarNoRules.
  ///
  /// In en, this message translates to:
  /// **'No grammar rules for this passage.'**
  String get grammarNoRules;

  /// No description provided for @translationTitle.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translationTitle;

  /// No description provided for @translationFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load translations.'**
  String get translationFailedLoad;

  /// No description provided for @translationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No translations found for this lesson.'**
  String get translationEmpty;

  /// No description provided for @translationInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type the Chinese here'**
  String get translationInputPlaceholder;

  /// No description provided for @translationReveal.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get translationReveal;

  /// No description provided for @translationHide.
  ///
  /// In en, this message translates to:
  /// **'Hide answer'**
  String get translationHide;

  /// No description provided for @translationShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get translationShuffle;

  /// No description provided for @translationPrev.
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get translationPrev;

  /// No description provided for @translationNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get translationNext;

  /// No description provided for @examChooseLevel.
  ///
  /// In en, this message translates to:
  /// **'Choose an HSK set to begin your exam.'**
  String get examChooseLevel;

  /// No description provided for @examChooseLesson.
  ///
  /// In en, this message translates to:
  /// **'Choose a lesson to begin your exam.'**
  String get examChooseLesson;

  /// No description provided for @examNoLessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons found.'**
  String get examNoLessons;

  /// No description provided for @examListeningReading.
  ///
  /// In en, this message translates to:
  /// **'Listening & Reading'**
  String get examListeningReading;

  /// No description provided for @examLessonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get examLessonPrefix;

  /// No description provided for @libraryTabPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get libraryTabPractice;

  /// No description provided for @practiceChooseLevel.
  ///
  /// In en, this message translates to:
  /// **'Choose an HSK set to practice.'**
  String get practiceChooseLevel;

  /// No description provided for @practiceChooseLesson.
  ///
  /// In en, this message translates to:
  /// **'Choose a lesson to practice.'**
  String get practiceChooseLesson;

  /// No description provided for @practiceLessonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get practiceLessonPrefix;

  /// No description provided for @practiceNoLessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons found.'**
  String get practiceNoLessons;

  /// No description provided for @vocabTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabTitle;

  /// No description provided for @vocabSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search words, pinyin, meaning…'**
  String get vocabSearchPlaceholder;

  /// No description provided for @vocabModeFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get vocabModeFree;

  /// No description provided for @vocabModeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get vocabModeStandard;

  /// No description provided for @vocabModeBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get vocabModeBook;

  /// No description provided for @vocabModeUnsure.
  ///
  /// In en, this message translates to:
  /// **'Unsure'**
  String get vocabModeUnsure;

  /// No description provided for @vocabModeUnlearn.
  ///
  /// In en, this message translates to:
  /// **'Not learned'**
  String get vocabModeUnlearn;

  /// No description provided for @vocabModeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get vocabModeRecent;

  /// No description provided for @vocabHskLabel.
  ///
  /// In en, this message translates to:
  /// **'HSK level'**
  String get vocabHskLabel;

  /// No description provided for @vocabSelectHsk.
  ///
  /// In en, this message translates to:
  /// **'Select HSK level'**
  String get vocabSelectHsk;

  /// No description provided for @vocabBookLabel.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get vocabBookLabel;

  /// No description provided for @vocabSelectBook.
  ///
  /// In en, this message translates to:
  /// **'Select a book'**
  String get vocabSelectBook;

  /// No description provided for @vocabLessonLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get vocabLessonLabel;

  /// No description provided for @vocabPartLabel.
  ///
  /// In en, this message translates to:
  /// **'Part'**
  String get vocabPartLabel;

  /// No description provided for @vocabSelectLesson.
  ///
  /// In en, this message translates to:
  /// **'Select lessons'**
  String get vocabSelectLesson;

  /// No description provided for @vocabSelectPart.
  ///
  /// In en, this message translates to:
  /// **'Select parts'**
  String get vocabSelectPart;

  /// No description provided for @vocabSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get vocabSelectAll;

  /// No description provided for @vocabDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get vocabDone;

  /// No description provided for @vocabNSelected.
  ///
  /// In en, this message translates to:
  /// **'{n} selected'**
  String vocabNSelected(Object n);

  /// No description provided for @vocabPageSize.
  ///
  /// In en, this message translates to:
  /// **'Per page'**
  String get vocabPageSize;

  /// No description provided for @vocabFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flash Cards'**
  String get vocabFlashcards;

  /// No description provided for @vocabStartTraining.
  ///
  /// In en, this message translates to:
  /// **'Start Training'**
  String get vocabStartTraining;

  /// No description provided for @vocabFlashcardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flash Cards'**
  String get vocabFlashcardsTitle;

  /// No description provided for @vocabTapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get vocabTapToReveal;

  /// No description provided for @vocabPageStatus.
  ///
  /// In en, this message translates to:
  /// **'Page {current}/{total}'**
  String vocabPageStatus(Object current, Object total);

  /// No description provided for @vocabLessonOptionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get vocabLessonOptionPrefix;

  /// No description provided for @vocabPartOptionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Part'**
  String get vocabPartOptionPrefix;

  /// No description provided for @vocabOtherLabel.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get vocabOtherLabel;

  /// No description provided for @vocabChooseFilters.
  ///
  /// In en, this message translates to:
  /// **'Choose filters to see words.'**
  String get vocabChooseFilters;

  /// No description provided for @vocabChooseBook.
  ///
  /// In en, this message translates to:
  /// **'Choose a book.'**
  String get vocabChooseBook;

  /// No description provided for @vocabChooseLessonAndPart.
  ///
  /// In en, this message translates to:
  /// **'Choose a lesson and part.'**
  String get vocabChooseLessonAndPart;

  /// No description provided for @vocabChooseHskLessonPart.
  ///
  /// In en, this message translates to:
  /// **'Choose an HSK level, lesson and part.'**
  String get vocabChooseHskLessonPart;

  /// No description provided for @vocabChooseHskOnly.
  ///
  /// In en, this message translates to:
  /// **'Choose an HSK level.'**
  String get vocabChooseHskOnly;

  /// No description provided for @vocabChooseAPart.
  ///
  /// In en, this message translates to:
  /// **'Choose a part.'**
  String get vocabChooseAPart;

  /// No description provided for @vocabNoVocabFound.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary found.'**
  String get vocabNoVocabFound;

  /// No description provided for @vocabLoadingVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Loading vocabulary…'**
  String get vocabLoadingVocabulary;

  /// No description provided for @vocabFailedLoadVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vocabulary.'**
  String get vocabFailedLoadVocabulary;

  /// No description provided for @vocabSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get vocabSearching;

  /// No description provided for @vocabSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed.'**
  String get vocabSearchFailed;

  /// No description provided for @vocabLoadingLessons.
  ///
  /// In en, this message translates to:
  /// **'Loading lessons…'**
  String get vocabLoadingLessons;

  /// No description provided for @vocabFailedLoadLessons.
  ///
  /// In en, this message translates to:
  /// **'Failed to load lessons.'**
  String get vocabFailedLoadLessons;

  /// No description provided for @vocabNoLessonsFound.
  ///
  /// In en, this message translates to:
  /// **'No lessons found.'**
  String get vocabNoLessonsFound;

  /// No description provided for @vocabNoSavedBooks.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved words in any book yet.'**
  String get vocabNoSavedBooks;

  /// No description provided for @vocabNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\".'**
  String vocabNoResultsFor(Object query);

  /// No description provided for @trainPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose skills to train'**
  String get trainPickerTitle;

  /// No description provided for @trainPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every skill is on by default.'**
  String get trainPickerSubtitle;

  /// No description provided for @trainPickerSkillTyping.
  ///
  /// In en, this message translates to:
  /// **'Typing'**
  String get trainPickerSkillTyping;

  /// No description provided for @trainPickerSkillListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get trainPickerSkillListening;

  /// No description provided for @trainPickerSkillReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get trainPickerSkillReading;

  /// No description provided for @trainPickerSelectOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one skill.'**
  String get trainPickerSelectOne;

  /// No description provided for @trainPickerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get trainPickerStart;

  /// No description provided for @vocabInstructionListen.
  ///
  /// In en, this message translates to:
  /// **'Listen and match each word to its meaning'**
  String get vocabInstructionListen;

  /// No description provided for @lessonInstructionListen.
  ///
  /// In en, this message translates to:
  /// **'Listen and choose the meaning of the sentence'**
  String get lessonInstructionListen;

  /// No description provided for @lessonPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get lessonPlayAudio;

  /// No description provided for @pinyinTitle.
  ///
  /// In en, this message translates to:
  /// **'Pinyin'**
  String get pinyinTitle;

  /// No description provided for @pinyinLessonHeading.
  ///
  /// In en, this message translates to:
  /// **'HSK 1 - Lesson 1'**
  String get pinyinLessonHeading;

  /// No description provided for @pinyinBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get pinyinBasic;

  /// No description provided for @pinyinAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get pinyinAdvanced;

  /// No description provided for @pinyinInitials.
  ///
  /// In en, this message translates to:
  /// **'Initials'**
  String get pinyinInitials;

  /// No description provided for @pinyinFinals.
  ///
  /// In en, this message translates to:
  /// **'Finals'**
  String get pinyinFinals;

  /// No description provided for @pinyinTones.
  ///
  /// In en, this message translates to:
  /// **'Tones'**
  String get pinyinTones;

  /// No description provided for @pinyinPronunciationFor.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation for {syllable}'**
  String pinyinPronunciationFor(String syllable);

  /// Message for features not yet wired (audio, stroke order).
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Caption under the milestone bar naming the current step.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String milestoneStepCounter(int n, int total);

  /// Milestone step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Vocab Summary'**
  String get milestoneStepVocabSummary;

  /// Milestone step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Vocab Learner'**
  String get milestoneStepVocabLearner;

  /// Milestone step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Vocab Trainer'**
  String get milestoneStepVocabTrainer;

  /// Milestone step 4 title (the reader).
  ///
  /// In en, this message translates to:
  /// **'Lesson Summary'**
  String get milestoneStepLessonSummary;

  /// Milestone step 5 title.
  ///
  /// In en, this message translates to:
  /// **'Lesson Learner'**
  String get milestoneStepLessonLearner;

  /// Milestone step 6 title.
  ///
  /// In en, this message translates to:
  /// **'Lesson Trainer'**
  String get milestoneStepLessonTrainer;

  /// Milestone runner's advance button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get milestoneContinue;

  /// Milestone runner's exit button.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get milestoneQuit;

  /// Placeholder message for a milestone step not yet built.
  ///
  /// In en, this message translates to:
  /// **'This step is coming soon.'**
  String get milestoneStepComingSoon;

  /// Lesson trainer progress counter.
  ///
  /// In en, this message translates to:
  /// **'Task {current}/{total}'**
  String trainerTaskCounter(int current, int total);

  /// Round score on the trainer recap.
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total} correct'**
  String trainerScore(int correct, int total);

  /// Skip the current trainer task.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get trainerSkip;

  /// Submit the current trainer answer.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get trainerCheck;

  /// Advance to the next trainer task.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get trainerNext;

  /// Error when the trainer session fails to start.
  ///
  /// In en, this message translates to:
  /// **'This lesson couldn\'t be loaded. Please try again.'**
  String get trainerLoadFailed;

  /// Shown when a part has no gradable tasks.
  ///
  /// In en, this message translates to:
  /// **'There are no tasks for this part yet.'**
  String get trainerNoTasks;

  /// Meaning task instruction.
  ///
  /// In en, this message translates to:
  /// **'What is the meaning of this sentence?'**
  String get lessonInstructionMeaning;

  /// Typing task instruction.
  ///
  /// In en, this message translates to:
  /// **'Type the following sentence in Chinese:'**
  String get lessonInstructionTyping;

  /// Reorder task instruction.
  ///
  /// In en, this message translates to:
  /// **'Reorder the words to form the correct sentence:'**
  String get lessonInstructionReorder;

  /// Placeholder in the typing task input.
  ///
  /// In en, this message translates to:
  /// **'Type the sentence here...'**
  String get lessonTypingPlaceholder;

  /// Label above the reorder answer row.
  ///
  /// In en, this message translates to:
  /// **'Your Sentence:'**
  String get lessonYourSentence;

  /// Label above the reorder source chips.
  ///
  /// In en, this message translates to:
  /// **'Available Words:'**
  String get lessonAvailableWords;

  /// Label before the revealed correct answer.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer:'**
  String get lessonCorrectAnswerLabel;

  /// Trainer recap heading.
  ///
  /// In en, this message translates to:
  /// **'Lesson Complete!'**
  String get lessonCompleteTitle;

  /// Trainer recap subheading.
  ///
  /// In en, this message translates to:
  /// **'You have successfully finished this practice.'**
  String get lessonCompleteBody;

  /// Heading of the missed-tasks list.
  ///
  /// In en, this message translates to:
  /// **'Missed Tasks Recap'**
  String get lessonRecapTitle;

  /// Recap row label for the learner's answer.
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get lessonTableYourAnswer;

  /// Recap row label for the correct answer.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer'**
  String get lessonTableCorrectAnswer;

  /// Perfect-round message on the trainer recap.
  ///
  /// In en, this message translates to:
  /// **'No missed tasks this round. Excellent work!'**
  String get lessonPerfect;

  /// Re-run the missed tasks.
  ///
  /// In en, this message translates to:
  /// **'Retry Missed'**
  String get lessonRetryMissed;

  /// Vocab typing activity instruction.
  ///
  /// In en, this message translates to:
  /// **'Type each word in Chinese'**
  String get vocabInstructionTyping;

  /// Vocab reading-match activity instruction.
  ///
  /// In en, this message translates to:
  /// **'Match each word to its meaning'**
  String get vocabInstructionMatch;

  /// Vocab trainer group progress counter.
  ///
  /// In en, this message translates to:
  /// **'Group {current}/{total}'**
  String vocabGroupCounter(int current, int total);

  /// Shown when a part has no vocabulary.
  ///
  /// In en, this message translates to:
  /// **'This part has no vocabulary to train.'**
  String get vocabNoWords;

  /// Vocab trainer recap heading.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Complete!'**
  String get vocabCompleteTitle;

  /// Flash card typing field hint.
  ///
  /// In en, this message translates to:
  /// **'Type character here...'**
  String get flashTypingPlaceholder;

  /// Lesson card typing field hint.
  ///
  /// In en, this message translates to:
  /// **'Type the sentence here...'**
  String get lessonCardTypingPlaceholder;

  /// Card learner control: previous card.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get cardPrev;

  /// Card learner control: next card.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get cardNext;

  /// Card learner control: play audio and reveal.
  ///
  /// In en, this message translates to:
  /// **'Audio + reveal'**
  String get cardAudioReveal;

  /// Card learner control: toggle pinyin and meaning.
  ///
  /// In en, this message translates to:
  /// **'Show/hide'**
  String get cardReveal;

  /// Card learner control: shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get cardShuffle;

  /// Card learner control: stroke order.
  ///
  /// In en, this message translates to:
  /// **'Stroke order'**
  String get cardStroke;

  /// Learn Together (competition) feature title.
  ///
  /// In en, this message translates to:
  /// **'Learn Together'**
  String get competitionTitle;

  /// Subtitle on the competition setup screen.
  ///
  /// In en, this message translates to:
  /// **'Compete with other learners in real time'**
  String get competitionSubtitle;

  /// Create-room button / heading.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get competitionCreateRoom;

  /// Host edit-settings button / heading.
  ///
  /// In en, this message translates to:
  /// **'Edit Settings'**
  String get competitionEditSettings;

  /// Room mode selector label.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get competitionMode;

  /// Vocab room mode.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get competitionModeVocab;

  /// Lesson room mode.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get competitionModeLesson;

  /// Book room mode.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get competitionModeBook;

  /// Book source picker label.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get competitionBook;

  /// Book picker placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select a book'**
  String get competitionSelectBook;

  /// Skill-type selector label.
  ///
  /// In en, this message translates to:
  /// **'Skill types'**
  String get competitionType;

  /// Type selector: all skills.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get competitionTypeAll;

  /// Skill: typing.
  ///
  /// In en, this message translates to:
  /// **'Typing'**
  String get competitionTypeTyping;

  /// Skill: listening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get competitionTypeListening;

  /// Skill: reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get competitionTypeReading;

  /// Skill: meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get competitionTypeMeaning;

  /// Skill: reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get competitionTypeReorder;

  /// Room capacity field.
  ///
  /// In en, this message translates to:
  /// **'Max learners'**
  String get competitionMaxUsers;

  /// Section timeout field.
  ///
  /// In en, this message translates to:
  /// **'Time limit'**
  String get competitionTimeLimit;

  /// A duration in minutes.
  ///
  /// In en, this message translates to:
  /// **'{n} minutes'**
  String competitionMinutes(int n);

  /// Save edited room settings.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get competitionSaveChanges;

  /// Cancel editing.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get competitionCancel;

  /// Join-room button / heading.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get competitionJoinRoom;

  /// Join-by-code field label.
  ///
  /// In en, this message translates to:
  /// **'Room code'**
  String get competitionRoomCode;

  /// Open-rooms browse heading.
  ///
  /// In en, this message translates to:
  /// **'Open Rooms'**
  String get competitionOpenRoomsTitle;

  /// Empty open-rooms list.
  ///
  /// In en, this message translates to:
  /// **'No open rooms right now.'**
  String get competitionNoOpenRooms;

  /// Open-room join button when full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get competitionRoomFull;

  /// Open-room occupancy.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} learners'**
  String competitionLearnersCount(int current, int max);

  /// Open-rooms pagination.
  ///
  /// In en, this message translates to:
  /// **'Page {current}/{total}'**
  String competitionPageStatus(int current, int total);

  /// HSK picker placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select HSK level'**
  String get competitionSelectHsk;

  /// Multi-select: select all.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get competitionSelectAll;

  /// Lesson picker placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select a lesson'**
  String get competitionSelectLesson;

  /// Part picker placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select a part'**
  String get competitionSelectPart;

  /// Lesson option prefix.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get competitionLessonPrefix;

  /// Part option prefix.
  ///
  /// In en, this message translates to:
  /// **'Part'**
  String get competitionPartPrefix;

  /// Lessonless-passage group label.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get competitionOtherLabel;

  /// Multi-select count.
  ///
  /// In en, this message translates to:
  /// **'{n} selected'**
  String competitionNSelected(int n);

  /// Multi-select confirm button.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get competitionDone;

  /// Validation when no part chosen.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one part.'**
  String get competitionSelectHskLessonPart;

  /// Lesson fetch failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load lessons.'**
  String get competitionFailedLoadLessons;

  /// No lessons under the picked sources.
  ///
  /// In en, this message translates to:
  /// **'No lessons found.'**
  String get competitionNoLessonsFound;

  /// Book mode has no saved books.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved words in any book yet.'**
  String get competitionNoSavedBooks;

  /// Room-code bar label.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get competitionRoomLabel;

  /// Leave-room button.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get competitionLeave;

  /// Lobby settings-summary heading.
  ///
  /// In en, this message translates to:
  /// **'Room Setup'**
  String get competitionRoomSetup;

  /// Lobby lesson/part counts.
  ///
  /// In en, this message translates to:
  /// **'{lessons} lessons · {parts} parts'**
  String competitionLessonsPartsCount(int lessons, int parts);

  /// Vocab room word count.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String competitionWordsCount(int count);

  /// Lesson room task count.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String competitionTasksSourceCount(int count);

  /// Book room pool note.
  ///
  /// In en, this message translates to:
  /// **'Word pool set when the session starts'**
  String get competitionBookPoolNote;

  /// Lobby member occupancy.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} learners'**
  String competitionUsersCount(int count, int max);

  /// Lobby time-limit line.
  ///
  /// In en, this message translates to:
  /// **'Limit: {n} min/section'**
  String competitionTimeLimitValue(int n);

  /// Host start-session button.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get competitionStartSession;

  /// Lobby chat heading.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get competitionChat;

  /// Chat input placeholder.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get competitionMessagePlaceholder;

  /// Chat send button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get competitionSend;

  /// Fallback chat author name.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get competitionUserFallback;

  /// Live score pill.
  ///
  /// In en, this message translates to:
  /// **'{n} pts'**
  String competitionPoints(int n);

  /// Section scoreboard heading.
  ///
  /// In en, this message translates to:
  /// **'Scoreboard'**
  String get competitionScoreboard;

  /// Empty lesson trainer.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this room.'**
  String get competitionNoTasks;

  /// Empty vocab trainer.
  ///
  /// In en, this message translates to:
  /// **'No words for this room.'**
  String get competitionNoWords;

  /// Trainer loading state.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get competitionLoading;

  /// Waiting screen heading.
  ///
  /// In en, this message translates to:
  /// **'You finished!'**
  String get competitionYouFinished;

  /// Who has finished so far.
  ///
  /// In en, this message translates to:
  /// **'Finished: {names}'**
  String competitionFinishedList(String names);

  /// Waiting screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the others to finish…'**
  String get competitionWaitingOthers;

  /// Ranking screen heading.
  ///
  /// In en, this message translates to:
  /// **'Final Ranking'**
  String get competitionRanking;

  /// Return-to-lobby button.
  ///
  /// In en, this message translates to:
  /// **'Back to Lobby'**
  String get competitionBackToLobby;

  /// Socket connect error.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get competitionServerConnectFailed;

  /// Generic socket error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get competitionErrorFallback;

  /// Room creation failed.
  ///
  /// In en, this message translates to:
  /// **'Could not create room.'**
  String get competitionCouldNotCreateRoom;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Back to Levels'**
  String get pickerBackToLevels;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Back to Lessons'**
  String get pickerBackToLessons;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Select Part'**
  String get pickerSelectPart;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get pickerNumberPart;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get pickerWordsLabel;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get pickerLessonProgressLabel;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get pickerGrammar;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get pickerTranslation;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Pinyin Guide'**
  String get pickerPinyinGuide;

  /// Lesson picker label.
  ///
  /// In en, this message translates to:
  /// **'Loading parts...'**
  String get pickerLoadingParts;

  /// Milestone nav bar button.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get milestonePrevious;

  /// Milestone nav bar button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get milestoneNext;

  /// Word popup: save the word to the book's list.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get wordAddToList;

  /// Word popup: the word is already saved.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get wordAdded;

  /// Trainer quit-confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Quit Session?'**
  String get trainerQuitTitle;

  /// Trainer quit-confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your current progress won\'t be saved.\nAre you sure you want to quit?'**
  String get trainerQuitBody;

  /// Trainer quit-confirm dialog cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get trainerCancel;

  /// Trainer quit-confirm dialog confirm button.
  ///
  /// In en, this message translates to:
  /// **'Yes, Quit'**
  String get trainerYesQuit;

  /// Round-end popup title for a perfect round.
  ///
  /// In en, this message translates to:
  /// **'Perfect Score! 🎉'**
  String get successPerfectTitle;

  /// Round-end popup title.
  ///
  /// In en, this message translates to:
  /// **'Session Complete!'**
  String get successCompleteTitle;

  /// Round-end popup stat label.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get successStatTasks;

  /// Round-end popup stat label.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get successStatCorrect;

  /// Round-end popup stat label.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get successStatAccuracy;

  /// Lesson flow: Translation's Next, rolls to the next lesson.
  ///
  /// In en, this message translates to:
  /// **'Next lesson'**
  String get flowNextLesson;

  /// Lesson flow: shown instead of Next lesson on a level's last lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson complete'**
  String get flowLessonComplete;

  /// Lesson flow: next-lesson confirm title.
  ///
  /// In en, this message translates to:
  /// **'Go to the next lesson?'**
  String get flowNextLessonTitle;

  /// Lesson flow: next-lesson confirm body.
  ///
  /// In en, this message translates to:
  /// **'You\'ve finished this lesson. Move on to the first part of the next lesson?'**
  String get flowNextLessonBody;

  /// Lesson flow: decline the next-lesson confirm.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get flowNotYet;

  /// Mid-session guard dialog title.
  ///
  /// In en, this message translates to:
  /// **'Session in progress'**
  String get guardTitle;

  /// Mid-session guard body when switching dashboard tabs.
  ///
  /// In en, this message translates to:
  /// **'You have an activity running. Switching tabs will end it — your answers so far are saved.'**
  String get guardBodyTab;

  /// Mid-session guard body when using the navigation.
  ///
  /// In en, this message translates to:
  /// **'You have an activity running. Leaving this page will end it — your answers so far are saved.'**
  String get guardBodyNav;

  /// Mid-session guard: keep the session.
  ///
  /// In en, this message translates to:
  /// **'Stay here'**
  String get guardStay;

  /// Mid-session guard: confirm switching tabs.
  ///
  /// In en, this message translates to:
  /// **'End and switch'**
  String get guardLeaveTab;

  /// Mid-session guard: confirm leaving the page.
  ///
  /// In en, this message translates to:
  /// **'Leave anyway'**
  String get guardLeaveNav;

  /// End-of-lesson Master Vocab confirm title.
  ///
  /// In en, this message translates to:
  /// **'Review all the lesson\'s vocabulary?'**
  String get masterVocabConfirmTitle;

  /// End-of-lesson Master Vocab confirm body.
  ///
  /// In en, this message translates to:
  /// **'Practise every word from this lesson in one session before moving on.'**
  String get masterVocabConfirmBody;

  /// End-of-lesson Master Lesson confirm title.
  ///
  /// In en, this message translates to:
  /// **'Review the whole lesson?'**
  String get masterLessonConfirmTitle;

  /// End-of-lesson Master Lesson confirm body.
  ///
  /// In en, this message translates to:
  /// **'Practise all of this lesson\'s sentences in one session before moving on.'**
  String get masterLessonConfirmBody;

  /// Master vocab trainer heading.
  ///
  /// In en, this message translates to:
  /// **'Master Vocab Trainer'**
  String get masterVocabTitle;

  /// Master lesson trainer heading.
  ///
  /// In en, this message translates to:
  /// **'Master Lesson Trainer'**
  String get masterLessonTitle;

  /// Master trainer confirm: begin.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get masterStart;

  /// Master trainer confirm / nav: skip this trainer.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get masterSkip;

  /// Lesson trainer skill.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get trainPickerSkillMeaning;

  /// Lesson trainer skill.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get trainPickerSkillReorder;

  /// Part picker: whole-lesson exam entry.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get pickerExam;

  /// Exam engine chooser subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what to practise'**
  String get examChooserSubtitle;

  /// Exam chooser option.
  ///
  /// In en, this message translates to:
  /// **'Vocab Trainer'**
  String get pickerVocabTrainer;

  /// Exam chooser option.
  ///
  /// In en, this message translates to:
  /// **'Lesson Trainer'**
  String get pickerLessonTrainer;

  /// Profile: review panel heading.
  ///
  /// In en, this message translates to:
  /// **'Practice Review'**
  String get reviewTitle;

  /// Profile review: empty title.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review yet'**
  String get reviewEmptyTitle;

  /// Profile review: empty hint.
  ///
  /// In en, this message translates to:
  /// **'Finish a practice or exam session and it will show up here.'**
  String get reviewEmptySub;

  /// Profile review: load error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your history.'**
  String get reviewFailedLoad;

  /// Profile review: question count of a session.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String reviewQuestions(int count);

  /// Profile review: back to the list.
  ///
  /// In en, this message translates to:
  /// **'Back to sessions'**
  String get reviewBackToList;

  /// Profile review: correct badge / filter.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get reviewCorrectBadge;

  /// Profile review: incorrect badge / filter.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get reviewIncorrectBadge;

  /// Profile review: result filter label.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get reviewFilterResult;

  /// Profile review: all results.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reviewResultAll;

  /// Profile review: all skills.
  ///
  /// In en, this message translates to:
  /// **'All skills'**
  String get reviewSkillAll;

  /// Profile review: the learner's answer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get reviewYourAnswer;

  /// Profile review: the right answer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get reviewCorrectAnswer;

  /// Profile review: unanswered.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get reviewNoAnswer;

  /// Profile review: question number.
  ///
  /// In en, this message translates to:
  /// **'Question {n}'**
  String reviewQuestionLabel(int n);

  /// Profile review: question removed.
  ///
  /// In en, this message translates to:
  /// **'This question is no longer in the question bank.'**
  String get reviewDetailMissing;

  /// Profile review: sort label.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get reviewSort;

  /// Profile review: newest first.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get reviewSortRecent;

  /// Profile review: oldest first.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get reviewSortOldest;

  /// Profile review: past the last page.
  ///
  /// In en, this message translates to:
  /// **'No more sessions to show.'**
  String get reviewNoMore;

  /// Profile review: page number.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String reviewPageIndicator(int page);

  /// Profile review: level filter label.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get reviewLevel;

  /// Profile review: all levels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get reviewAllLevels;

  /// Profile review: category filter label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reviewCategory;

  /// Profile review: all categories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get reviewAllCategories;

  /// Profile review: skill filter label.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get reviewSkill;

  /// Profile review: reading skill.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reviewReading;

  /// Profile review: listening skill.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get reviewListening;

  /// Profile: change-password heading / button.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// Profile: new password field.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get profileNewPassword;

  /// Profile: confirm password field.
  ///
  /// In en, this message translates to:
  /// **'Re-type New Password'**
  String get profileConfirmPassword;

  /// Profile: passwords differ.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get profilePasswordMismatch;

  /// Profile: empty new password.
  ///
  /// In en, this message translates to:
  /// **'New password is required.'**
  String get profilePasswordRequired;

  /// Profile: password request in flight.
  ///
  /// In en, this message translates to:
  /// **'Updating password...'**
  String get profilePasswordUpdating;

  /// Profile: password update failed.
  ///
  /// In en, this message translates to:
  /// **'Could not update password.'**
  String get profilePasswordFailed;

  /// Profile: password updated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get profilePasswordUpdated;

  /// Profile: avatar dialog title / button.
  ///
  /// In en, this message translates to:
  /// **'Upload Avatar'**
  String get profileUploadAvatar;

  /// Profile: open the photo picker.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get profileChooseImage;

  /// Profile: upload pressed with no image.
  ///
  /// In en, this message translates to:
  /// **'Choose an avatar file first.'**
  String get profileChooseAvatarFirst;

  /// Profile: avatar upload in flight.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get profileUploading;

  /// Profile: avatar upload failed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed.'**
  String get profileUploadFailed;

  /// Profile: avatar uploaded.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated.'**
  String get profileAvatarUpdated;

  /// Lesson sidebar: parts section heading.
  ///
  /// In en, this message translates to:
  /// **'Lesson Parts'**
  String get sidebarLessonParts;

  /// Lesson sidebar: back to the part picker.
  ///
  /// In en, this message translates to:
  /// **'Part Selection'**
  String get sidebarPartSelection;

  /// Lesson sidebar: open button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Open Sidebar'**
  String get sidebarOpen;

  /// Lesson sidebar: empty parts.
  ///
  /// In en, this message translates to:
  /// **'No parts found.'**
  String get sidebarNoParts;

  /// Lesson sidebar: parts error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load parts.'**
  String get sidebarFailedParts;

  /// Reader: stops the Auto Play sequence.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get studyStopAutoPlay;

  /// Recommend filter: all skills.
  ///
  /// In en, this message translates to:
  /// **'All Skills'**
  String get recommendAllSkills;

  /// Recommend filter label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get recommendStatus;

  /// Recommend filter: all statuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get recommendAllStatuses;

  /// Recommend multi-select bar count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item selected} other{{count} items selected}}'**
  String recommendItemsSelected(int count);

  /// Recommend multi-select bar action.
  ///
  /// In en, this message translates to:
  /// **'Start Selected'**
  String get recommendStartSelected;

  /// Recommend new-user call to action.
  ///
  /// In en, this message translates to:
  /// **'Go to Vocabulary Trainer'**
  String get recommendNewUserCta;

  /// Word summary: play every word's audio.
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get wordSummaryPlayAll;

  /// Word summary: shuffle the card order.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get wordSummaryShuffle;

  /// Word summary: pinyin column toggle.
  ///
  /// In en, this message translates to:
  /// **'Pinyin'**
  String get wordSummaryPinyin;

  /// Word summary: meaning column toggle.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get wordSummaryMeaning;
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
