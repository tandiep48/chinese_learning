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
  String get navDashboard => 'Dashboard';

  @override
  String get navLibrary => 'Library';

  @override
  String get navVocabulary => 'Vocabulary';

  @override
  String get navRecommend => 'Recommend';

  @override
  String get navSettings => 'Settings';

  @override
  String get navLogout => 'Sign Out';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsScript => 'Script';

  @override
  String get settingsFont => 'Font';

  @override
  String get settingsLangVi => 'Tiếng Việt';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsScriptSimplified => '简体 Simplified';

  @override
  String get settingsScriptTraditional => '繁體 Traditional';

  @override
  String get settingsHanziNote =>
      'Chinese text styling will apply in a future update.';

  @override
  String get settingsSaveError => 'Couldn\'t save your preference.';

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
  String get registerTitle => 'Register';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerSubmit => 'Register';

  @override
  String get registerPasswordHint => 'At least 8 characters';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get registerHere => 'Register here';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get loginHere => 'Log in here';

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
  String get homeBrowseHsk => 'Browse by HSK level';

  @override
  String get homeTabLesson => 'Lesson';

  @override
  String get homeTabReview => 'Word Review';

  @override
  String get homeTabRecommend => 'Recommend';

  @override
  String get homeReviewStub => 'Vocabulary review is coming soon.';

  @override
  String get homeRecommendStub => 'Recommended practice is coming soon.';

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
  String get libraryTabHsk => 'HSK';

  @override
  String get hskSelectLevelTitle => 'Select HSK Level';

  @override
  String get hskSelectLevelSubtitle => 'Choose a level to see its lessons';

  @override
  String get hskSelectLessonTitle => 'Select Lesson';

  @override
  String hskLessonsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons available',
      one: '1 lesson available',
    );
    return '$_temp0';
  }

  @override
  String get hskSearchPlaceholder => 'Search lessons';

  @override
  String get hskNoLessons => 'No lessons found for this level.';

  @override
  String get hskNoMatch => 'No lessons match your search.';

  @override
  String get hskOtherPassages => 'Other Passages';

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
  String get strokeAnimate => 'Animate';

  @override
  String get strokePractice => 'Practice';

  @override
  String get strokeReset => 'Reset';

  @override
  String get strokeLoadError => 'Couldn\'t load stroke order.';

  @override
  String get practiceLoading => 'Loading practice…';

  @override
  String get practiceLoadFailed => 'Could not load practice data.';

  @override
  String get practiceCompleteTitle => 'Practice Complete!';

  @override
  String get practiceSetLabel => 'Practice Set';

  @override
  String get practiceCorrectAnswers => 'Correct answers';

  @override
  String get practiceRetry => 'Retry';

  @override
  String get practiceCheck => 'Check';

  @override
  String get practiceSkip => 'Skip';

  @override
  String get practicePrevious => 'Previous';

  @override
  String get practiceSubmitting => 'Submitting...';

  @override
  String get practiceFinish => 'Finish';

  @override
  String get practiceBack => 'Back';

  @override
  String get practiceListening => 'Listening';

  @override
  String get practiceReading => 'Reading';

  @override
  String get practiceTrueLabel => 'True';

  @override
  String get practiceFalseLabel => 'False';

  @override
  String get practiceYourOrder => 'Your order (click to place):';

  @override
  String get practiceSentencesClickAdd => 'Sentences (click to add):';

  @override
  String get practiceChooseFromOptions => 'Choose from options:';

  @override
  String get practiceChooseImagePerSentence =>
      'Choose the matching image for each sentence.';

  @override
  String get practiceChooseAnswerPerSentence =>
      'Choose the answer that matches each sentence below.';

  @override
  String get practiceChooseImageForAudio =>
      'Listen to the conversation and choose the appropriate image.';

  @override
  String get practicePlayPassage => 'Play Passage';

  @override
  String get practiceCorrectExclaim => 'Correct!';

  @override
  String get practiceBack5 => 'Back 5 seconds';

  @override
  String get practiceForward5 => 'Forward 5 seconds';

  @override
  String get practiceStopAudio => 'Stop audio';

  @override
  String get practiceSeekSlider => 'Seek audio position';

  @override
  String get practiceAudioFallback => 'Audio';

  @override
  String practiceQuestionNumber(int n) {
    return 'Question $n';
  }

  @override
  String practiceQuestionsGroup(String progress) {
    return 'Questions $progress';
  }

  @override
  String practiceCorrectOrder(String order) {
    return 'Correct order: $order';
  }

  @override
  String practiceCorrectAnswerColon(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String practiceScoreCorrect(int correct, int total) {
    return '$correct / $total correct';
  }

  @override
  String practiceAudioNumbered(int n) {
    return 'Audio $n';
  }

  @override
  String practicePlayLabel(String label) {
    return 'Play $label';
  }

  @override
  String get commonLoadMore => 'Load more';

  @override
  String get dashboardTotalTime => 'Total Time';

  @override
  String get dashboardWordsMastered => 'Words Mastered';

  @override
  String get dashboardTimeLearned3days => 'Time Learned (Last 3 Days)';

  @override
  String get dashboardWordsMastered3days => 'Words Mastered (Last 3 Days)';

  @override
  String get dashboardNoChartData => 'No recent activity to chart yet.';

  @override
  String get dashboardExercise => 'Exercise';

  @override
  String get dashboardExam => 'Exam';

  @override
  String get dashboardLessonTrainer => 'Lesson Trainer';

  @override
  String get dashboardVocabTrainer => 'Vocab Trainer';

  @override
  String get dashboardLearningStatistics => 'Learning Statistics';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLearnedWords => 'Learned Words';

  @override
  String get reviewHeading => 'Your Words';

  @override
  String get reviewTabRecent => 'Recent learn word';

  @override
  String get reviewTabReview => 'Review word';

  @override
  String get reviewSubtitleRecent =>
      'The words you\'ve mastered most recently.';

  @override
  String get reviewSubtitleReview =>
      'Words to revisit — not yet mastered, or answered slowly.';

  @override
  String get reviewEmptyRecent => 'You haven\'t mastered any words yet.';

  @override
  String get reviewEmptyReview => 'Nothing to review right now.';

  @override
  String get reviewLoading => 'Loading your words...';

  @override
  String get reviewLoadFailed => 'Could not load your words. Please try again.';

  @override
  String get reviewPrevPage => 'Previous page';

  @override
  String get reviewNextPage => 'Next page';

  @override
  String reviewPageRange(int start, int end, int total) {
    return '$start-$end of $total';
  }

  @override
  String get recommendFinding => 'Finding recommendations…';

  @override
  String get recommendAnalysing => 'Analysing your vocabulary progress.';

  @override
  String get recommendErrorTitle => 'Something went wrong';

  @override
  String get recommendConnectFailed => 'Could not connect to the server.';

  @override
  String get recommendFailedLoad => 'Failed to load recommendations.';

  @override
  String get recommendEmptyTitle => 'No recommendations yet';

  @override
  String get recommendEmptySub =>
      'Keep learning vocabulary to unlock recommended practice groups!';

  @override
  String get recommendNewUserTitle => 'Welcome! You\'re just getting started.';

  @override
  String get recommendNewUserSub =>
      'You haven\'t practiced any vocabulary yet. Recommended lessons unlock automatically as you learn words — start with the Vocabulary Trainer!';

  @override
  String get recommendStart => 'Start';

  @override
  String get recommendLessonPrefix => 'Lesson';

  @override
  String get recommendStatusNotStart => 'Not start';

  @override
  String get recommendStatusFinishSuccess => 'Finish and success';

  @override
  String get recommendStatusFinishFail => 'Finish and fail';

  @override
  String recommendGroupsFound(int count) {
    return 'Found $count question group(s) ready to practice.';
  }

  @override
  String recommendQuestionCount(int count) {
    return '$count question(s)';
  }

  @override
  String recommendQuestionSingle(String n) {
    return 'Question $n';
  }

  @override
  String recommendQuestionsRange(String a, String b) {
    return 'Questions $a–$b';
  }

  @override
  String recommendNewFocus(String words) {
    return 'New focus: $words';
  }

  @override
  String get grammarTitle => 'Grammar';

  @override
  String get grammarErrorLoading => 'Error loading grammar.';

  @override
  String get grammarNoRules => 'No grammar rules for this passage.';

  @override
  String get translationTitle => 'Translation';

  @override
  String get translationFailedLoad => 'Failed to load translations.';

  @override
  String get translationEmpty => 'No translations found for this lesson.';

  @override
  String get translationInputPlaceholder => 'Type the Chinese here';

  @override
  String get translationReveal => 'Show answer';

  @override
  String get translationHide => 'Hide answer';

  @override
  String get translationShuffle => 'Shuffle';

  @override
  String get translationPrev => 'Prev';

  @override
  String get translationNext => 'Next';

  @override
  String get examChooseLevel => 'Choose an HSK set to begin your exam.';

  @override
  String get examChooseLesson => 'Choose a lesson to begin your exam.';

  @override
  String get examNoLessons => 'No lessons found.';

  @override
  String get examListeningReading => 'Listening & Reading';

  @override
  String get examLessonPrefix => 'Lesson';

  @override
  String get pinyinTitle => 'Pinyin';

  @override
  String get pinyinLessonHeading => 'HSK 1 - Lesson 1';

  @override
  String get pinyinGuideEntry => 'Pinyin Guide';

  @override
  String get numbersEntry => 'Numbers';

  @override
  String get pinyinBasic => 'Basic';

  @override
  String get pinyinAdvanced => 'Advanced';

  @override
  String get pinyinInitials => 'Initials';

  @override
  String get pinyinFinals => 'Finals';

  @override
  String get pinyinTones => 'Tones';

  @override
  String pinyinPronunciationFor(String syllable) {
    return 'Pronunciation for $syllable';
  }

  @override
  String get comingSoon => 'Coming soon';

  @override
  String milestoneStepCounter(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get milestoneStepVocabSummary => 'Vocab Summary';

  @override
  String get milestoneStepVocabLearner => 'Vocab Learner';

  @override
  String get milestoneStepVocabTrainer => 'Vocab Trainer';

  @override
  String get milestoneStepLessonSummary => 'Lesson Summary';

  @override
  String get milestoneStepLessonLearner => 'Lesson Learner';

  @override
  String get milestoneStepLessonTrainer => 'Lesson Trainer';

  @override
  String get milestoneContinue => 'Continue';

  @override
  String get milestoneQuit => 'Exit';

  @override
  String get milestoneStepComingSoon => 'This step is coming soon.';

  @override
  String trainerTaskCounter(int current, int total) {
    return 'Task $current/$total';
  }

  @override
  String trainerScore(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get trainerSkip => 'Skip';

  @override
  String get trainerCheck => 'Check';

  @override
  String get trainerNext => 'Next';

  @override
  String get trainerLoadFailed =>
      'This lesson couldn\'t be loaded. Please try again.';

  @override
  String get trainerNoTasks => 'There are no tasks for this part yet.';

  @override
  String get lessonInstructionMeaning =>
      'What is the meaning of this sentence?';

  @override
  String get lessonInstructionTyping =>
      'Type the following sentence in Chinese:';

  @override
  String get lessonInstructionReorder =>
      'Reorder the words to form the correct sentence:';

  @override
  String get lessonTypingPlaceholder => 'Type the sentence here...';

  @override
  String get lessonYourSentence => 'Your Sentence:';

  @override
  String get lessonAvailableWords => 'Available Words:';

  @override
  String get lessonCorrectAnswerLabel => 'Correct Answer:';

  @override
  String get lessonCompleteTitle => 'Lesson Complete!';

  @override
  String get lessonCompleteBody =>
      'You have successfully finished this practice.';

  @override
  String get lessonRecapTitle => 'Missed Tasks Recap';

  @override
  String get lessonTableYourAnswer => 'Your Answer';

  @override
  String get lessonTableCorrectAnswer => 'Correct Answer';

  @override
  String get lessonPerfect => 'No missed tasks this round. Excellent work!';

  @override
  String get lessonRetryMissed => 'Retry Missed';

  @override
  String get vocabInstructionTyping => 'Type each word in Chinese';

  @override
  String get vocabInstructionMatch => 'Match each word to its meaning';

  @override
  String vocabGroupCounter(int current, int total) {
    return 'Group $current/$total';
  }

  @override
  String get vocabNoWords => 'This part has no vocabulary to train.';

  @override
  String get vocabCompleteTitle => 'Vocabulary Complete!';

  @override
  String get flashTapToFlip => 'Tap to reveal';

  @override
  String get competitionTitle => 'Learn Together';

  @override
  String get competitionSubtitle => 'Compete with other learners in real time';

  @override
  String get competitionCreateRoom => 'Create Room';

  @override
  String get competitionEditSettings => 'Edit Settings';

  @override
  String get competitionMode => 'Mode';

  @override
  String get competitionModeVocab => 'Vocabulary';

  @override
  String get competitionModeLesson => 'Lesson';

  @override
  String get competitionModeBook => 'Book';

  @override
  String get competitionBook => 'Book';

  @override
  String get competitionSelectBook => 'Select a book';

  @override
  String get competitionType => 'Skill types';

  @override
  String get competitionTypeAll => 'All types';

  @override
  String get competitionTypeTyping => 'Typing';

  @override
  String get competitionTypeListening => 'Listening';

  @override
  String get competitionTypeReading => 'Reading';

  @override
  String get competitionTypeMeaning => 'Meaning';

  @override
  String get competitionTypeReorder => 'Reorder';

  @override
  String get competitionMaxUsers => 'Max learners';

  @override
  String get competitionTimeLimit => 'Time limit';

  @override
  String competitionMinutes(int n) {
    return '$n minutes';
  }

  @override
  String get competitionSaveChanges => 'Save Changes';

  @override
  String get competitionCancel => 'Cancel';

  @override
  String get competitionJoinRoom => 'Join Room';

  @override
  String get competitionRoomCode => 'Room code';

  @override
  String get competitionOpenRoomsTitle => 'Open Rooms';

  @override
  String get competitionNoOpenRooms => 'No open rooms right now.';

  @override
  String get competitionRoomFull => 'Full';

  @override
  String competitionLearnersCount(int current, int max) {
    return '$current/$max learners';
  }

  @override
  String competitionPageStatus(int current, int total) {
    return 'Page $current/$total';
  }

  @override
  String get competitionSelectHsk => 'Select HSK level';

  @override
  String get competitionSelectAll => 'Select all';

  @override
  String get competitionSelectLesson => 'Select a lesson';

  @override
  String get competitionSelectPart => 'Select a part';

  @override
  String get competitionLessonPrefix => 'Lesson';

  @override
  String get competitionPartPrefix => 'Part';

  @override
  String get competitionOtherLabel => 'Other';

  @override
  String competitionNSelected(int n) {
    return '$n selected';
  }

  @override
  String get competitionDone => 'Done';

  @override
  String get competitionSelectHskLessonPart =>
      'Please select at least one part.';

  @override
  String get competitionFailedLoadLessons => 'Failed to load lessons.';

  @override
  String get competitionNoLessonsFound => 'No lessons found.';

  @override
  String get competitionNoSavedBooks =>
      'You haven\'t saved words in any book yet.';

  @override
  String get competitionRoomLabel => 'Room';

  @override
  String get competitionLeave => 'Leave';

  @override
  String get competitionRoomSetup => 'Room Setup';

  @override
  String competitionLessonsPartsCount(int lessons, int parts) {
    return '$lessons lessons · $parts parts';
  }

  @override
  String competitionWordsCount(int count) {
    return '$count words';
  }

  @override
  String competitionTasksSourceCount(int count) {
    return '$count tasks';
  }

  @override
  String get competitionBookPoolNote => 'Word pool set when the session starts';

  @override
  String competitionUsersCount(int count, int max) {
    return '$count/$max learners';
  }

  @override
  String competitionTimeLimitValue(int n) {
    return 'Limit: $n min/section';
  }

  @override
  String get competitionStartSession => 'Start Session';

  @override
  String get competitionChat => 'Chat';

  @override
  String get competitionMessagePlaceholder => 'Type a message…';

  @override
  String get competitionSend => 'Send';

  @override
  String get competitionUserFallback => 'User';

  @override
  String competitionPoints(int n) {
    return '$n pts';
  }

  @override
  String get competitionScoreboard => 'Scoreboard';

  @override
  String get competitionNoTasks => 'No tasks for this room.';

  @override
  String get competitionNoWords => 'No words for this room.';

  @override
  String get competitionLoading => 'Loading…';

  @override
  String get competitionYouFinished => 'You finished!';

  @override
  String competitionFinishedList(String names) {
    return 'Finished: $names';
  }

  @override
  String get competitionWaitingOthers => 'Waiting for the others to finish…';

  @override
  String get competitionRanking => 'Final Ranking';

  @override
  String get competitionBackToLobby => 'Back to Lobby';

  @override
  String get competitionServerConnectFailed =>
      'Could not connect to the server.';

  @override
  String get competitionErrorFallback => 'Something went wrong.';

  @override
  String get competitionCouldNotCreateRoom => 'Could not create room.';
}
